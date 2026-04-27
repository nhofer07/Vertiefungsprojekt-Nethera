import Foundation

extension Notification.Name {
    static let groupBlocklistDidChange = Notification.Name("groupBlocklistDidChange")
}

struct BlocklistProfile: Codable, Equatable {
    var gamblingEnabled: Bool
    var adultEnabled: Bool
    var socialEnabled: Bool
    var manualDomains: [String]

    init(
        gamblingEnabled: Bool = false,
        adultEnabled: Bool = false,
        socialEnabled: Bool = false,
        manualDomains: [String] = []
    ) {
        self.gamblingEnabled = gamblingEnabled
        self.adultEnabled = adultEnabled
        self.socialEnabled = socialEnabled
        self.manualDomains = manualDomains
    }

    var enabledPackageCount: Int {
        [gamblingEnabled, adultEnabled, socialEnabled].filter { $0 }.count
    }

    var totalRuleCount: Int {
        enabledPackageCount + manualDomains.count
    }

    var hasActiveRules: Bool {
        totalRuleCount > 0
    }

    var summaryText: String {
        var parts: [String] = []
        if gamblingEnabled { parts.append("Glücksspiel") }
        if adultEnabled { parts.append("18+") }
        if socialEnabled { parts.append("Social") }

        if !manualDomains.isEmpty {
            let countText = manualDomains.count == 1 ? "1 Domain" : "\(manualDomains.count) Domains"
            parts.append(countText)
        }

        if parts.isEmpty {
            return "Keine Regeln aktiv"
        }

        return parts.joined(separator: " • ")
    }

    private enum CodingKeys: String, CodingKey {
        case gamblingEnabled, adultEnabled, socialEnabled, manualDomains
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        gamblingEnabled = try container.decodeIfPresent(Bool.self, forKey: .gamblingEnabled) ?? false
        adultEnabled = try container.decodeIfPresent(Bool.self, forKey: .adultEnabled) ?? false
        socialEnabled = try container.decodeIfPresent(Bool.self, forKey: .socialEnabled) ?? false
        manualDomains = try container.decodeIfPresent([String].self, forKey: .manualDomains) ?? []
    }
}

struct DeviceSettings: Codable, Equatable {
    var parentalControl: Bool
    var prioritized: Bool
    var timeLimitEnabled: Bool
    var startTime: Date
    var endTime: Date
    var blocklist: BlocklistProfile
    var hasOwnBlocklist: Bool

    init(
        parentalControl: Bool = true,
        prioritized: Bool = false,
        timeLimitEnabled: Bool = false,
        startTime: Date = Date(),
        endTime: Date = Date(),
        blocklist: BlocklistProfile = BlocklistProfile(),
        hasOwnBlocklist: Bool = false
    ) {
        self.parentalControl = parentalControl
        self.prioritized = prioritized
        self.timeLimitEnabled = timeLimitEnabled
        self.startTime = startTime
        self.endTime = endTime
        self.blocklist = blocklist
        self.hasOwnBlocklist = hasOwnBlocklist
    }

    private enum CodingKeys: String, CodingKey {
        case parentalControl, prioritized, timeLimitEnabled, startTime, endTime, blocklist, hasOwnBlocklist
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        parentalControl = try container.decodeIfPresent(Bool.self, forKey: .parentalControl) ?? true
        prioritized = try container.decodeIfPresent(Bool.self, forKey: .prioritized) ?? false
        timeLimitEnabled = try container.decodeIfPresent(Bool.self, forKey: .timeLimitEnabled) ?? false
        startTime = try container.decodeIfPresent(Date.self, forKey: .startTime) ?? Date()
        endTime = try container.decodeIfPresent(Date.self, forKey: .endTime) ?? Date()
        blocklist = try container.decodeIfPresent(BlocklistProfile.self, forKey: .blocklist) ?? BlocklistProfile()
        hasOwnBlocklist = try container.decodeIfPresent(Bool.self, forKey: .hasOwnBlocklist) ?? blocklist.hasActiveRules
    }
}

struct DevicePreset: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var group: String?
    var parentalControl: Bool
    var prioritized: Bool
    var timeLimitEnabled: Bool
    var startTime: Date
    var endTime: Date
    var blocklist: BlocklistProfile

    init(
        id: UUID = UUID(),
        name: String,
        group: String? = nil,
        parentalControl: Bool,
        prioritized: Bool,
        timeLimitEnabled: Bool,
        startTime: Date,
        endTime: Date,
        blocklist: BlocklistProfile = BlocklistProfile()
    ) {
        self.id = id
        self.name = name
        self.group = group
        self.parentalControl = parentalControl
        self.prioritized = prioritized
        self.timeLimitEnabled = timeLimitEnabled
        self.startTime = startTime
        self.endTime = endTime
        self.blocklist = blocklist
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, group, parentalControl, prioritized, timeLimitEnabled, startTime, endTime, blocklist
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        group = try container.decodeIfPresent(String.self, forKey: .group)
        parentalControl = try container.decodeIfPresent(Bool.self, forKey: .parentalControl) ?? true
        prioritized = try container.decodeIfPresent(Bool.self, forKey: .prioritized) ?? false
        timeLimitEnabled = try container.decodeIfPresent(Bool.self, forKey: .timeLimitEnabled) ?? false
        startTime = try container.decodeIfPresent(Date.self, forKey: .startTime) ?? Date()
        endTime = try container.decodeIfPresent(Date.self, forKey: .endTime) ?? Date()
        blocklist = try container.decodeIfPresent(BlocklistProfile.self, forKey: .blocklist) ?? BlocklistProfile()
    }
}

enum NetheraStorage {
    private static let deviceSettingsKey = "devices.settings"
    private static let presetsKey = "SavedDevicePresets"
    private static let groupBlocklistsKey = "devices.groupBlocklists"

    private static func loadDictionary<T: Decodable>(forKey key: String, as type: T.Type) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private static func saveEncodable<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func allDeviceSettings() -> [String: DeviceSettings] {
        loadDictionary(forKey: deviceSettingsKey, as: [String: DeviceSettings].self) ?? [:]
    }

    static func deviceSettings(for deviceID: UUID) -> DeviceSettings {
        allDeviceSettings()[deviceID.uuidString] ?? DeviceSettings()
    }

    static func saveDeviceSettings(_ settings: DeviceSettings, for deviceID: UUID) {
        var all = allDeviceSettings()
        all[deviceID.uuidString] = settings
        saveEncodable(all, forKey: deviceSettingsKey)
    }

    static func deleteDeviceSettings(for deviceID: UUID) {
        var all = allDeviceSettings()
        all.removeValue(forKey: deviceID.uuidString)
        saveEncodable(all, forKey: deviceSettingsKey)
    }

    static func loadPresets() -> [DevicePreset] {
        loadDictionary(forKey: presetsKey, as: [DevicePreset].self) ?? []
    }

    static func savePresets(_ presets: [DevicePreset]) {
        saveEncodable(presets, forKey: presetsKey)
    }

    static func allGroupBlocklists() -> [String: BlocklistProfile] {
        loadDictionary(forKey: groupBlocklistsKey, as: [String: BlocklistProfile].self) ?? [:]
    }

    static func groupBlocklist(for group: String) -> BlocklistProfile {
        allGroupBlocklists()[group] ?? BlocklistProfile()
    }

    static func saveGroupBlocklist(_ profile: BlocklistProfile, for group: String) {
        var all = allGroupBlocklists()
        if profile.hasActiveRules {
            all[group] = profile
        } else {
            all.removeValue(forKey: group)
        }
        saveEncodable(all, forKey: groupBlocklistsKey)
        NotificationCenter.default.post(name: .groupBlocklistDidChange, object: nil)
    }

    static func renameGroupBlocklist(from oldGroup: String, to newGroup: String) {
        guard oldGroup != newGroup else { return }
        var all = allGroupBlocklists()
        let value = all.removeValue(forKey: oldGroup)
        if let value {
            all[newGroup] = value
        }
        saveEncodable(all, forKey: groupBlocklistsKey)
        NotificationCenter.default.post(name: .groupBlocklistDidChange, object: nil)
    }

    static func deleteGroupBlocklist(for group: String) {
        var all = allGroupBlocklists()
        all.removeValue(forKey: group)
        saveEncodable(all, forKey: groupBlocklistsKey)
        NotificationCenter.default.post(name: .groupBlocklistDidChange, object: nil)
    }
}
