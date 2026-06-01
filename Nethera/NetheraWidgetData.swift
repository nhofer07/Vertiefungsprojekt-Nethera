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
        let devices = NetheraBackend.loadDevices()
        let presets = NetheraBackend.loadPresets()
        let settings = NetheraBackend.allDeviceSettings()
        let routerSettings = NetheraBackend.loadRouterSettings()
        let selectedDeviceIDs = selectedWidgetDeviceIDs()
        let selectedDevices = devices.filter { selectedDeviceIDs.contains($0.id) }
        let widgetDevices = selectedDevices.isEmpty ? devices : selectedDevices
        let childCards = widgetDevices.map { childCard(for: $0, presets: presets, settings: settings) }
        let databaseAvailable = NetheraBackend.isDatabaseAvailable()
        let firstChildCard = childCards.first ?? NetheraChildWidgetSnapshot(
            childName: databaseAvailable ? "Kein Gerät" : "Offline",
            screenTimeLeft: "Kein Preset aktiv",
            focusStartsAt: "Keine Fokuszeit geplant",
            activePreset: "Kein Preset aktiv",
            familyAction: databaseAvailable ? "Keine Widget-Info verfügbar" : "Datenbank nicht erreichbar"
        )
        let unknownDevices = devices.filter { $0.group == "Nicht zugeordnet" || $0.group == "Neu verbunden" }.count
        let protectedDevices = devices.filter { $0.group != "Ignoriert" }.count
        let blockedThreats = estimateBlockedThreats(from: presets, settings: settings)
        let networkLoad = estimateNetworkLoad(from: devices)
        let guestName = routerSettings.wifiName.isEmpty ? "Nicht gespeichert" : "\(routerSettings.wifiName) Guest"
        let guestPassword = routerSettings.guestPassword.isEmpty ? "Nicht gespeichert" : routerSettings.guestPassword

        return NetheraWidgetSnapshot(
            unknownDevices: unknownDevices,
            protectedDevices: protectedDevices,
            blockedThreats: blockedThreats,
            networkLoad: networkLoad,
            lastScan: databaseAvailable ? (devices.isEmpty ? "Noch nicht synchronisiert" : "gerade eben") : "Datenbank nicht erreichbar",
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

    // schätzt blockierte treffer aus aktiven blocklist-regeln:
    private static func estimateBlockedThreats(from presets: [DevicePreset], settings: [String: DeviceSettings]) -> Int {
        let presetRules = presets.reduce(0) { $0 + $1.blocklist.totalRuleCount }
        let deviceRules = settings.values.reduce(0) { $0 + $1.blocklist.totalRuleCount }
        return max(0, (presetRules + deviceRules) * 12)
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
