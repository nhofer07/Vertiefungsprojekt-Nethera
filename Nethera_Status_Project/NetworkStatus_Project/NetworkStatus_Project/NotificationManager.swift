import Foundation
import Combine
import UserNotifications

final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var authorizationStatus = "Nicht gefragt"
    @Published var isAuthorized = false
    @Published var automaticWarningsEnabled = true

    private var lastStatusText = ""
    private var lastConnectionType = ""

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        refreshAuthorizationStatus()
    }

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.refreshAuthorizationStatus()
            }
        }
    }

    func refreshAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
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

    func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }
}
