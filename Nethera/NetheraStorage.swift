import Foundation


// Gemeinsame Datenmodelle und Änderungs-Benachrichtigungen.

extension Notification.Name {
    static let groupBlocklistDidChange = Notification.Name("groupBlocklistDidChange")
    static let globalBlocklistDidChange = Notification.Name("globalBlocklistDidChange")
    static let adBlockDomainsDidChange = Notification.Name("adBlockDomainsDidChange")
    static let accountSettingsDidChange = Notification.Name("accountSettingsDidChange")
}

struct AdBlockDomain: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var time: String

    init(id: UUID = UUID(), name: String, time: String) {
        self.id = id
        self.name = name
        self.time = time
    }
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
    var activePresetID: UUID?
    var parentalControl: Bool
    var prioritized: Bool
    var timeLimitEnabled: Bool
    var startTime: Date
    var endTime: Date
    var blocklist: BlocklistProfile
    var hasOwnBlocklist: Bool

    init(
        activePresetID: UUID? = nil,
        parentalControl: Bool = true,
        prioritized: Bool = false,
        timeLimitEnabled: Bool = false,
        startTime: Date = Date(),
        endTime: Date = Date(),
        blocklist: BlocklistProfile = BlocklistProfile(),
        hasOwnBlocklist: Bool = false
    ) {
        self.activePresetID = activePresetID
        self.parentalControl = parentalControl
        self.prioritized = prioritized
        self.timeLimitEnabled = timeLimitEnabled
        self.startTime = startTime
        self.endTime = endTime
        self.blocklist = blocklist
        self.hasOwnBlocklist = hasOwnBlocklist
    }

    private enum CodingKeys: String, CodingKey {
        case activePresetID, parentalControl, prioritized, timeLimitEnabled, startTime, endTime, blocklist, hasOwnBlocklist
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        activePresetID = try container.decodeIfPresent(UUID.self, forKey: .activePresetID)
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
    var isEnabled: Bool
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
        isEnabled: Bool = true,
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
        self.isEnabled = isEnabled
        self.group = group
        self.parentalControl = parentalControl
        self.prioritized = prioritized
        self.timeLimitEnabled = timeLimitEnabled
        self.startTime = startTime
        self.endTime = endTime
        self.blocklist = blocklist
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, isEnabled, group, parentalControl, prioritized, timeLimitEnabled, startTime, endTime, blocklist
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
        group = try container.decodeIfPresent(String.self, forKey: .group)
        parentalControl = try container.decodeIfPresent(Bool.self, forKey: .parentalControl) ?? true
        prioritized = try container.decodeIfPresent(Bool.self, forKey: .prioritized) ?? false
        timeLimitEnabled = try container.decodeIfPresent(Bool.self, forKey: .timeLimitEnabled) ?? false
        startTime = try container.decodeIfPresent(Date.self, forKey: .startTime) ?? Date()
        endTime = try container.decodeIfPresent(Date.self, forKey: .endTime) ?? Date()
        blocklist = try container.decodeIfPresent(BlocklistProfile.self, forKey: .blocklist) ?? BlocklistProfile()
    }
}
