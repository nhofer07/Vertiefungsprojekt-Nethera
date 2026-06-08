import Foundation
import WidgetKit

struct NetheraWidgetSnapshot: Codable {
    var unknownDevices: Int
    var protectedDevices: Int
    var blockedThreats: Int
    var networkLoad: Int
    var lastScan: String
    var nextNetworkAction: String
    var guestNetworkName: String
    var guestPassword: String
    var guestTimeLeft: String
    var childName: String
    var screenTimeLeft: String
    var focusStartsAt: String
    var activePreset: String
    var familyAction: String
    var childCards: [NetheraChildWidgetSnapshot]
}

struct NetheraChildWidgetSnapshot: Codable {
    var childName: String
    var screenTimeLeft: String
    var focusStartsAt: String
    var activePreset: String
    var familyAction: String
}

enum NetheraWidgetDataStore {
    static let appGroupID = "group.NicoHofer.Nethera"
    private static let snapshotKey = "widgets.snapshot"
    private static let childSelectionKey = "widgets.childDeviceIDs"

    // schreibt aktuelle app-daten fuer die widgets:
    static func syncSnapshot() {
        save(makeSnapshot())
        WidgetCenter.shared.reloadAllTimelines()
    }

    // lädt die geräte, die im widget rotieren sollen:
    static func selectedWidgetDeviceIDs() -> Set<UUID> {
        guard let data = UserDefaults.standard.data(forKey: childSelectionKey),
              let ids = try? JSONDecoder().decode([UUID].self, from: data) else {
            return []
        }
        return Set(ids)
    }

    // speichert die auswahl fuer das widget:
    static func saveSelectedWidgetDeviceIDs(_ ids: Set<UUID>) {
        guard let data = try? JSONEncoder().encode(Array(ids)) else { return }
        UserDefaults.standard.set(data, forKey: childSelectionKey)
        syncSnapshot()
    }

    // speichert den snapshot in der app group:
    private static func save(_ snapshot: NetheraWidgetSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        widgetDefaults.set(data, forKey: snapshotKey)
    }

    private static var widgetDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    // baut aus gespeicherten app-werten die widget-anzeige:
    private static func makeSnapshot() -> NetheraWidgetSnapshot {
        guard NetheraBackend.isDatabaseAvailable() else {
            return offlineSnapshot()
        }

        guard NetheraBackend.loadAccountSettings().isLoggedIn else {
            return loggedOutSnapshot()
        }

        let devices = NetheraBackend.loadDevices()
        let presets = NetheraBackend.loadPresets()
        let settings = NetheraBackend.allDeviceSettings()
        let routerSettings = NetheraBackend.loadRouterSettings()
        let adBlockStats = NetheraBackend.loadAdBlockStats()
        let selectedDeviceIDs = selectedWidgetDeviceIDs()
        let selectedDevices = devices.filter { selectedDeviceIDs.contains($0.id) }
        let widgetDevices = selectedDevices.isEmpty ? devices : selectedDevices
        let childCards = widgetDevices.map { childCard(for: $0, presets: presets, settings: settings) }
        let firstChildCard = childCards.first ?? NetheraChildWidgetSnapshot(
            childName: "Kein Gerät",
            screenTimeLeft: "Kein Preset aktiv",
            focusStartsAt: "Keine Fokuszeit geplant",
            activePreset: "Kein Preset aktiv",
            familyAction: "Keine Widget-Info verfügbar"
        )
        let unknownDevices = devices.filter { $0.group == "Nicht zugeordnet" || $0.group == "Neu verbunden" }.count
        let protectedDevices = devices.filter { $0.group != "Ignoriert" }.count
        let blockedThreats = metricValue(from: adBlockStats.blockedToday)
        let networkLoad = estimateNetworkLoad(from: devices)
        let guestName = routerSettings.wifiName.isEmpty ? "Nicht gespeichert" : "\(routerSettings.wifiName) Guest"
        let guestPassword = routerSettings.guestPassword.isEmpty ? "Nicht gespeichert" : routerSettings.guestPassword

        return NetheraWidgetSnapshot(
            unknownDevices: unknownDevices,
            protectedDevices: protectedDevices,
            blockedThreats: blockedThreats,
            networkLoad: networkLoad,
            lastScan: devices.isEmpty ? "Noch nicht synchronisiert" : "gerade eben",
            nextNetworkAction: networkAction(for: unknownDevices, devices: devices),
            guestNetworkName: guestName,
            guestPassword: guestPassword,
            guestTimeLeft: routerSettings.guestPassword.isEmpty ? "Kein Gastzugang gespeichert" : "Gastzugang aus dem Backend",
            childName: firstChildCard.childName,
            screenTimeLeft: firstChildCard.screenTimeLeft,
            focusStartsAt: firstChildCard.focusStartsAt,
            activePreset: firstChildCard.activePreset,
            familyAction: firstChildCard.familyAction,
            childCards: childCards
        )
    }

    private static func offlineSnapshot() -> NetheraWidgetSnapshot {
        let offlineCard = NetheraChildWidgetSnapshot(
            childName: "Backend offline",
            screenTimeLeft: "Keine Daten verfügbar",
            focusStartsAt: "Keine Verbindung",
            activePreset: "Datenbank nicht erreichbar",
            familyAction: "Backend starten und Nethera öffnen"
        )

        return NetheraWidgetSnapshot(
            unknownDevices: 0,
            protectedDevices: 0,
            blockedThreats: 0,
            networkLoad: 0,
            lastScan: "Datenbank nicht erreichbar",
            nextNetworkAction: "Backend-Verbindung prüfen",
            guestNetworkName: "Nicht verfügbar",
            guestPassword: "Nicht verfügbar",
            guestTimeLeft: "Datenbank nicht erreichbar",
            childName: offlineCard.childName,
            screenTimeLeft: offlineCard.screenTimeLeft,
            focusStartsAt: offlineCard.focusStartsAt,
            activePreset: offlineCard.activePreset,
            familyAction: offlineCard.familyAction,
            childCards: [offlineCard]
        )
    }

    private static func loggedOutSnapshot() -> NetheraWidgetSnapshot {
        let lockedCard = NetheraChildWidgetSnapshot(
            childName: "Abgemeldet",
            screenTimeLeft: "Bitte anmelden",
            focusStartsAt: "Keine Daten sichtbar",
            activePreset: "Nicht angemeldet",
            familyAction: "In Nethera anmelden"
        )

        return NetheraWidgetSnapshot(
            unknownDevices: 0,
            protectedDevices: 0,
            blockedThreats: 0,
            networkLoad: 0,
            lastScan: "Nicht angemeldet",
            nextNetworkAction: "In Nethera anmelden",
            guestNetworkName: "Nicht angemeldet",
            guestPassword: "Nicht angemeldet",
            guestTimeLeft: "Bitte zuerst anmelden",
            childName: lockedCard.childName,
            screenTimeLeft: lockedCard.screenTimeLeft,
            focusStartsAt: lockedCard.focusStartsAt,
            activePreset: lockedCard.activePreset,
            familyAction: lockedCard.familyAction,
            childCards: [lockedCard]
        )
    }

    // baut die familien-widget-daten fuer ein einzelnes kind:
    private static func childCard(
        for device: Device,
        presets: [DevicePreset],
        settings: [String: DeviceSettings]
    ) -> NetheraChildWidgetSnapshot {
        let deviceSettings = settings[device.id.uuidString]
        let activePreset = deviceSettings?.activePresetID.flatMap { activeID in
            presets.first { $0.id == activeID }
        }
        let childName = shortChildName(from: device.name)

        return NetheraChildWidgetSnapshot(
            childName: childName,
            screenTimeLeft: presetStatusText(from: activePreset),
            focusStartsAt: focusText(from: activePreset),
            activePreset: activePreset?.name ?? "Kein Preset aktiv",
            familyAction: childInfoText(from: activePreset)
        )
    }

    // macht aus backend-statistiken eine zahl fuer das widget:
    private static func metricValue(from value: String) -> Int {
        let normalized = value.replacingOccurrences(of: ",", with: ".").uppercased()
        let multiplier = normalized.contains("K") ? 1_000.0 : 1.0
        let numeric = normalized.filter { $0.isNumber || $0 == "." }
        return Int((Double(numeric) ?? 0) * multiplier)
    }

    // schätzt die last anhand der aktiven geräte:
    private static func estimateNetworkLoad(from devices: [Device]) -> Int {
        guard !devices.isEmpty else { return 0 }
        return min(99, max(8, devices.filter { $0.group != "Ignoriert" }.count * 14))
    }

    // formuliert die wichtigste netzwerk-aktion:
    private static func networkAction(for unknownDevices: Int, devices: [Device]) -> String {
        guard !devices.isEmpty else {
            return "App öffnen und Backend synchronisieren"
        }
        if unknownDevices == 0 {
            return "Alle Geräte sind zugeordnet"
        }
        if unknownDevices == 1 {
            return "Ein unbekanntes Gerät prüfen"
        }
        return "\(unknownDevices) unbekannte Geräte prüfen"
    }

    // macht aus gerätenamen einen kurzen anzeigenamen:
    private static func shortChildName(from deviceName: String?) -> String {
        guard let deviceName else { return "Kein Kind" }
        if deviceName.contains("Anna") { return "Anna" }
        if deviceName.contains("Nico") { return "Nico" }
        if deviceName.contains("Tobi") { return "Tobi" }
        return deviceName.components(separatedBy: " ").first ?? deviceName
    }

    // zeigt im widget welches preset gerade gilt:
    private static func presetStatusText(from preset: DevicePreset?) -> String {
        guard let preset else {
            return "Kein Preset aktiv"
        }
        return "\(preset.name): aktiv"
    }

    // formatiert die nächste fokuszeit:
    private static func focusText(from preset: DevicePreset?) -> String {
        guard let preset, preset.timeLimitEnabled else {
            return "Keine Fokuszeit geplant"
        }
        return "heute um \(timeFormatter.string(from: preset.startTime)) Uhr"
    }

    // kurze info fuer auffaellige oder gesperrte aktivitaet:
    private static func childInfoText(from preset: DevicePreset?) -> String {
        guard let preset else {
            return "Keine verbotene Anfrage erkannt"
        }
        if preset.blocklist.hasActiveRules {
            return "Anfrage auf verbotene Seite blockiert"
        }
        if preset.parentalControl {
            return "Keine verbotene Anfrage erkannt"
        }
        return "Schutz ist momentan reduziert"
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
