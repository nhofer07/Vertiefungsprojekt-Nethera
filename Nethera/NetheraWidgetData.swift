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
}

enum NetheraWidgetDataStore {
    static let appGroupID = "group.NicoHofer.Nethera"
    private static let snapshotKey = "widgets.snapshot"

    // schreibt aktuelle app-daten fuer die widgets:
    static func syncSnapshot() {
        save(makeSnapshot())
        WidgetCenter.shared.reloadAllTimelines()
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
        let defaults = UserDefaults.standard
        let devices = loadDevices(from: defaults)
        let presets = loadPresets(from: defaults)
        let settings = loadDeviceSettings(from: defaults)
        let activePreset = presets.first { $0.isEnabled }
        let childDevice = devices.first { $0.group == "Kinder" } ?? devices.first
        let unknownDevices = devices.filter { $0.group == "Nicht zugeordnet" || $0.group == "Neu verbunden" }.count
        let protectedDevices = devices.filter { $0.group != "Ignoriert" }.count
        let blockedThreats = estimateBlockedThreats(from: presets, settings: settings)
        let networkLoad = estimateNetworkLoad(from: devices)
        let guestName = defaults.string(forKey: "router.wifiName").map { "\($0) Guest" } ?? "Nethera Guest"
        let guestPassword = defaults.string(forKey: "router.guestPassword") ?? "In der App speichern"

        return NetheraWidgetSnapshot(
            unknownDevices: unknownDevices,
            protectedDevices: protectedDevices,
            blockedThreats: blockedThreats,
            networkLoad: networkLoad,
            lastScan: "gerade eben",
            nextNetworkAction: networkAction(for: unknownDevices, devices: devices),
            guestNetworkName: guestName,
            guestPassword: guestPassword,
            guestTimeLeft: "Gastzugang aus den Einstellungen",
            childName: shortChildName(from: childDevice?.name),
            screenTimeLeft: timeLeftText(from: activePreset),
            focusStartsAt: focusText(from: activePreset),
            activePreset: activePreset?.name ?? "Kein Preset aktiv",
            familyAction: familyActionText(from: activePreset, childName: shortChildName(from: childDevice?.name))
        )
    }

    // lädt die geräte aus dem geräte-tab:
    private static func loadDevices(from defaults: UserDefaults) -> [Device] {
        guard let data = defaults.data(forKey: "devices.list"),
              let decoded = try? JSONDecoder().decode([Device].self, from: data) else {
            return [
                Device(id: UUID(), name: "iPhone von Nico", type: "iphone.homebutton", onlineTime: "12h", dataUsage: "57 GB", group: "Eltern"),
                Device(id: UUID(), name: "MacBook Nico", type: "laptopcomputer", onlineTime: "5h", dataUsage: "12 GB", group: "Eltern"),
                Device(id: UUID(), name: "Annas iPhone", type: "iphone", onlineTime: "6h", dataUsage: "4 GB", group: "Kinder"),
                Device(id: UUID(), name: "Smart TV", type: "tv", onlineTime: "3h", dataUsage: "8 GB", group: "Wohnzimmer"),
                Device(id: UUID(), name: "Tobis iPad", type: "ipad", onlineTime: "8m", dataUsage: "120 MB", group: "Nicht zugeordnet")
            ]
        }
        return decoded
    }

    // lädt die gespeicherten presets:
    private static func loadPresets(from defaults: UserDefaults) -> [DevicePreset] {
        guard let data = defaults.data(forKey: "SavedDevicePresets"),
              let decoded = try? JSONDecoder().decode([DevicePreset].self, from: data) else {
            return []
        }
        return decoded
    }

    // lädt extra-einstellungen pro gerät:
    private static func loadDeviceSettings(from defaults: UserDefaults) -> [String: DeviceSettings] {
        guard let data = defaults.data(forKey: "devices.settings"),
              let decoded = try? JSONDecoder().decode([String: DeviceSettings].self, from: data) else {
            return [:]
        }
        return decoded
    }

    // schätzt blockierte treffer aus aktiven blocklist-regeln:
    private static func estimateBlockedThreats(from presets: [DevicePreset], settings: [String: DeviceSettings]) -> Int {
        let presetRules = presets.reduce(0) { $0 + $1.blocklist.totalRuleCount }
        let deviceRules = settings.values.reduce(0) { $0 + $1.blocklist.totalRuleCount }
        return max(0, (presetRules + deviceRules) * 12)
    }

    // schätzt die last anhand der aktiven geräte:
    private static func estimateNetworkLoad(from devices: [Device]) -> Int {
        min(99, max(8, devices.filter { $0.group != "Ignoriert" }.count * 14))
    }

    // formuliert die wichtigste netzwerk-aktion:
    private static func networkAction(for unknownDevices: Int, devices: [Device]) -> String {
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
        guard let deviceName else { return "Kind" }
        if deviceName.contains("Anna") { return "Anna" }
        if deviceName.contains("Nico") { return "Nico" }
        if deviceName.contains("Tobi") { return "Tobi" }
        return deviceName.components(separatedBy: " ").first ?? deviceName
    }

    // berechnet den restzeit-text aus dem aktiven preset:
    private static func timeLeftText(from preset: DevicePreset?) -> String {
        guard let preset, preset.timeLimitEnabled else {
            return "Kein Zeitlimit aktiv"
        }
        let minutes = max(0, Int(preset.endTime.timeIntervalSince(Date()) / 60))
        if minutes == 0 { return "Zeitlimit erreicht" }
        if minutes < 60 { return "\(minutes) Minuten übrig" }
        return "\(minutes / 60) Stunden \(minutes % 60) Minuten übrig"
    }

    // formatiert die nächste fokuszeit:
    private static func focusText(from preset: DevicePreset?) -> String {
        guard let preset, preset.timeLimitEnabled else {
            return "Keine Fokuszeit geplant"
        }
        return "heute um \(timeFormatter.string(from: preset.startTime)) Uhr"
    }

    // beschreibt was das aktive familien-preset gerade macht:
    private static func familyActionText(from preset: DevicePreset?, childName: String) -> String {
        guard let preset else {
            return "Für \(childName) ist kein Preset aktiv"
        }
        if preset.blocklist.hasActiveRules {
            return "\(preset.blocklist.summaryText) bleibt blockiert"
        }
        if preset.parentalControl {
            return "\(preset.name) schützt \(childName)"
        }
        return "\(preset.name) ist aktiv"
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
