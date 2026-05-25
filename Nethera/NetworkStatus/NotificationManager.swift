import Foundation
import Combine
import Network
import UserNotifications

@MainActor
final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    @Published var authorizationStatus = "Nicht gefragt"
    @Published var isAuthorized = false
    @Published var automaticWarningsEnabled = true

    private var lastStatusText = ""
    private var lastConnectionType = ""
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "nethera.network.monitor")
    private var isMonitoringNetwork = false

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        automaticWarningsEnabled = UserDefaults.standard.object(forKey: "router.notifications") as? Bool ?? true
        refreshAuthorizationStatus()
    }

    // fragt ob man mitteilungen senden darf
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] _, _ in
            Task { @MainActor in
                self?.refreshAuthorizationStatus()
            }
        }
    }

    func refreshAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            Task { @MainActor in
                switch settings.authorizationStatus {
                case .authorized:
                    self?.authorizationStatus = "Erlaubt"
                    self?.isAuthorized = true
                case .provisional:
                    self?.authorizationStatus = "Vorläufig"
                    self?.isAuthorized = true
                case .denied:
                    self?.authorizationStatus = "Blockiert"
                    self?.isAuthorized = false
                case .notDetermined:
                    self?.authorizationStatus = "Nicht gefragt"
                    self?.isAuthorized = false
                case .ephemeral:
                    self?.authorizationStatus = "Temporär"
                    self?.isAuthorized = true
                @unknown default:
                    self?.authorizationStatus = "Unbekannt"
                    self?.isAuthorized = false
                }
            }
        }
    }

    // startet echte netzwerk-überwachung:
    func startAutomaticMonitoring() {
        guard !isMonitoringNetwork else { return }
        isMonitoringNetwork = true

        monitor.pathUpdateHandler = { [weak self] path in
            let statusText = path.status == .satisfied ? "Online" : "Offline"
            let connectionType: String

            if path.usesInterfaceType(.wifi) {
                connectionType = "WLAN"
            } else if path.usesInterfaceType(.cellular) {
                connectionType = "Mobile Daten"
            } else if path.status == .satisfied {
                connectionType = "Andere Verbindung"
            } else {
                connectionType = "Keine Verbindung"
            }

            Task { @MainActor in
                self?.handleNetworkChange(statusText: statusText, connectionType: connectionType)
            }
        }

        monitor.start(queue: monitorQueue)
    }

    // tracked den network state
    func handleNetworkChange(statusText: String, connectionType: String) {
        guard automaticWarningsEnabled else {
            lastStatusText = statusText
            lastConnectionType = connectionType
            return
        }

        guard !lastStatusText.isEmpty || !lastConnectionType.isEmpty else {
            lastStatusText = statusText
            lastConnectionType = connectionType
            return
        }

        if statusText == "Offline" && lastStatusText != "Offline" {
            sendOfflineWarning()
        } else if connectionType == "Mobile Daten" && lastConnectionType != "Mobile Daten" {
            sendMobileDataWarning()
        } else if connectionType == "WLAN" && lastConnectionType == "Mobile Daten" {
            sendNotification(
                title: "Nethera Verbindung",
                body: "Du bist wieder über WLAN verbunden. Routerfunktionen sind wieder sinnvoll verfügbar."
            )
        }

        lastStatusText = statusText
        lastConnectionType = connectionType
    }

    // meldet neue unbekannte geräte:
    func handleDeviceListChange(_ devices: [Device]) {
        guard automaticWarningsEnabled else { return }

        let unknownNames = Set(
            devices
                .filter { $0.group == "Nicht zugeordnet" || $0.group == "Neu verbunden" }
                .map(\.name)
        )
        let key = "notifications.knownUnknownDevices"
        let knownNames = Set(UserDefaults.standard.stringArray(forKey: key) ?? [])

        guard !knownNames.isEmpty else {
            UserDefaults.standard.set(Array(unknownNames), forKey: key)
            return
        }

        let newNames = unknownNames.subtracting(knownNames)
        if let deviceName = newNames.sorted().first {
            sendNewDeviceWarning(deviceName: deviceName)
        }

        UserDefaults.standard.set(Array(unknownNames), forKey: key)
    }

    // meldet direkt wenn ein gerät manuell in nicht zugeordnet landet:
    func handleDeviceMovedToUnassigned(deviceName: String) {
        guard automaticWarningsEnabled else { return }
        sendNewDeviceWarning(deviceName: deviceName)

        let key = "notifications.knownUnknownDevices"
        var knownNames = Set(UserDefaults.standard.stringArray(forKey: key) ?? [])
        knownNames.insert(deviceName)
        UserDefaults.standard.set(Array(knownNames), forKey: key)
    }

    // meldet wenn die firewall deaktiviert wird:
    func handleFirewallChange(wasEnabled: Bool, isEnabled: Bool) {
        guard automaticWarningsEnabled else { return }
        if wasEnabled && !isEnabled {
            sendSecurityReminder()
        }
    }

    // alle types
    
    func sendOfflineWarning() {
        sendNotification(
            title: "Nethera Warnung",
            body: "Deine Verbindung ist offline. Bitte prüfe deinen Router oder dein WLAN."
        )
    }

    func sendMobileDataWarning() {
        sendNotification(
            title: "Nethera Hinweis",
            body: "Du bist über mobile Daten verbunden. Routerfunktionen könnten eingeschränkt sein."
        )
    }

    func sendSecurityReminder() {
        sendNotification(
            title: "Nethera Sicherheitscheck",
            body: "Prüfe regelmäßig unbekannte Geräte und ändere dein WLAN-Passwort bei Bedarf."
        )
    }

    func sendNewDeviceDemo() {
        sendNotification(
            title: "Nethera Gerät erkannt",
            body: "Demo: Ein neues Gerät wurde im Netzwerk gefunden: iPhone von Gast."
        )
    }

    func sendNewDeviceWarning(deviceName: String) {
        sendNotification(
            title: "Nethera Gerät erkannt",
            body: "Ein neues unbekanntes Gerät wurde gefunden: \(deviceName)."
        )
    }

    func sendNotification(title: String, body: String) {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                self?.scheduleNotification(title: title, body: body)
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    Task { @MainActor in
                        self?.refreshAuthorizationStatus()
                        if granted {
                            self?.scheduleNotification(title: title, body: body)
                        }
                    }
                }
            case .denied:
                Task { @MainActor in
                    self?.authorizationStatus = "Blockiert"
                    self?.isAuthorized = false
                }
            @unknown default:
                Task { @MainActor in
                    self?.authorizationStatus = "Unbekannt"
                    self?.isAuthorized = false
                }
            }
        }
    }

    private nonisolated func scheduleNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        // da wirds dann schlussendlich geworfen
        UNUserNotificationCenter.current().add(request)
    }

    // auch wenns geöffnet ist als banner
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }
}
