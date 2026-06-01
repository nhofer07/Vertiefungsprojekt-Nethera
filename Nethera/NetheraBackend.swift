import Foundation

enum NetheraBackend {
    private static let baseURLKey = "backend.baseURL"
    private static let devicesKey = "backend.devices.list"
    private static let groupsKey = "backend.devices.groups"
    private static let settingsKey = "backend.devices.settings"
    private static let presetsKey = "backend.presets"
    private static let groupBlocklistsKey = "backend.groupBlocklists"
    private static let globalBlocklistKey = "backend.globalBlocklist"
    private static let adBlockDomainsKey = "backend.adBlockDomains"
    private static let routerSettingsKey = "backend.routerSettings"
    private static let backendAvailableKey = "backend.isAvailable"
    private static let didMigrateLegacyKey = "backend.didMigrateLegacyStorage"

    struct RouterSettings: Codable, Equatable {
        var wifiName: String = ""
        var password: String = ""
        var guestPassword: String = ""
        var notifications: Bool = false
        var darkMode: Bool = false
        var frequency: String = ""
        var firewall: Bool = false
    }

    struct BackendState: Codable {
        var devices: [Device]
        var groups: [String]
        var deviceSettings: [String: DeviceSettings]
        var presets: [DevicePreset]
        var groupBlocklists: [String: BlocklistProfile]
        var globalBlocklist: BlocklistProfile?
        var adBlockDomains: [AdBlockDomain]?
        var routerSettings: RouterSettings?
    }

    // lädt aktuellen stand aus mongodb und cached ihn lokal:
    static func refreshFromMongoDB() {
        refreshFromMongoDB(using: backendBaseURLCandidates())
    }

    private static func refreshFromMongoDB(using candidates: [String]) {
        guard let candidate = candidates.first,
              let url = URL(string: "\(candidate)/api/state") else {
            markDatabaseUnavailable()
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error {
                print("NetheraBackend refresh failed for \(candidate): \(error.localizedDescription)")
                refreshFromMongoDB(using: Array(candidates.dropFirst()))
                return
            }

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                print("NetheraBackend refresh failed for \(candidate) with status \(httpResponse.statusCode)")
                refreshFromMongoDB(using: Array(candidates.dropFirst()))
                return
            }

            guard let data,
                  let state = try? JSONDecoder().decode(BackendState.self, from: data) else {
                print("NetheraBackend refresh failed for \(candidate): invalid response")
                refreshFromMongoDB(using: Array(candidates.dropFirst()))
                return
            }

            UserDefaults.standard.set(candidate, forKey: baseURLKey)
            UserDefaults.standard.set(true, forKey: backendAvailableKey)
            save(state.devices, forKey: devicesKey)
            save(state.groups, forKey: groupsKey)
            save(state.deviceSettings, forKey: settingsKey)
            save(state.presets, forKey: presetsKey)
            save(state.groupBlocklists, forKey: groupBlocklistsKey)
            if let globalBlocklist = state.globalBlocklist {
                save(globalBlocklist, forKey: globalBlocklistKey)
            }
            if let adBlockDomains = state.adBlockDomains {
                save(adBlockDomains, forKey: adBlockDomainsKey)
            }
            if let routerSettings = state.routerSettings {
                save(routerSettings, forKey: routerSettingsKey)
            }

            DispatchQueue.main.async {
                NetheraWidgetDataStore.syncSnapshot()
                NotificationCenter.default.post(name: .netheraBackendDidRefresh, object: nil)
            }
        }.resume()
    }

    static func isDatabaseAvailable() -> Bool {
        UserDefaults.standard.bool(forKey: backendAvailableKey)
    }

    static func currentBackendBaseURL() -> String {
        baseURL
    }

    static func saveBackendBaseURL(_ urlString: String) {
        let normalized = normalizeBaseURL(urlString)
        guard !normalized.isEmpty else { return }
        UserDefaults.standard.set(normalized, forKey: baseURLKey)
        refreshFromMongoDB()
    }

    // lädt geräte aus der backend-schicht:
    static func loadDevices() -> [Device] {
        migrateLegacyStorageIfNeeded()
        guard isDatabaseAvailable() else { return [] }
        let devices = load(devicesKey, as: [Device].self) ?? []
        return devices.map { device in
            var copy = device
            copy.group = normalizeGroupName(device.group)
            return copy
        }
    }

    // speichert geräte in der backend-schicht:
    static func saveDevices(_ devices: [Device]) {
        migrateLegacyStorageIfNeeded()
        guard isDatabaseAvailable() else { return }
        save(devices, forKey: devicesKey)
        push(["devices": devices], to: "/api/devices", method: "PUT")
    }

    // lädt gruppen aus der backend-schicht:
    static func loadGroups() -> [String] {
        migrateLegacyStorageIfNeeded()
        guard isDatabaseAvailable() else { return [] }
        let groups = load(groupsKey, as: [String].self) ?? []
        var cleaned: [String] = []
        for group in groups.map(normalizeGroupName) where !cleaned.contains(group) {
            cleaned.append(group)
        }
        return cleaned
    }

    // speichert gruppen in der backend-schicht:
    static func saveGroups(_ groups: [String]) {
        migrateLegacyStorageIfNeeded()
        guard isDatabaseAvailable() else { return }
        save(groups, forKey: groupsKey)
        push(["groups": groups], to: "/api/groups", method: "PUT")
    }

    // lädt router- und gast-wlan-einstellungen:
    static func loadRouterSettings() -> RouterSettings {
        migrateLegacyStorageIfNeeded()
        guard isDatabaseAvailable() else { return RouterSettings() }
        return load(routerSettingsKey, as: RouterSettings.self) ?? RouterSettings()
    }

    // speichert router- und gast-wlan-einstellungen:
    static func saveRouterSettings(_ settings: RouterSettings) {
        migrateLegacyStorageIfNeeded()
        guard isDatabaseAvailable() else { return }
        save(settings, forKey: routerSettingsKey)
        push(["routerSettings": settings], to: "/api/router-settings", method: "PUT")
        NetheraWidgetDataStore.syncSnapshot()
    }

    // lädt alle geräte-settings:
    static func allDeviceSettings() -> [String: DeviceSettings] {
        migrateLegacyStorageIfNeeded()
        guard isDatabaseAvailable() else { return [:] }
        return load(settingsKey, as: [String: DeviceSettings].self) ?? [:]
    }

    // lädt settings für ein gerät:
    static func deviceSettings(for deviceID: UUID) -> DeviceSettings {
        allDeviceSettings()[deviceID.uuidString] ?? DeviceSettings()
    }

    // speichert settings für ein gerät:
    static func saveDeviceSettings(_ settings: DeviceSettings, for deviceID: UUID) {
        guard isDatabaseAvailable() else { return }
        var all = allDeviceSettings()
        all[deviceID.uuidString] = settings
        save(all, forKey: settingsKey)
        push(["settings": settings], to: "/api/device-settings/\(deviceID.uuidString)", method: "PUT")
        NetheraWidgetDataStore.syncSnapshot()
    }

    // löscht extra-settings für ein gerät:
    static func deleteDeviceSettings(for deviceID: UUID) {
        guard isDatabaseAvailable() else { return }
        var all = allDeviceSettings()
        all.removeValue(forKey: deviceID.uuidString)
        save(all, forKey: settingsKey)
        pushEmpty(to: "/api/device-settings/\(deviceID.uuidString)", method: "DELETE")
        NetheraWidgetDataStore.syncSnapshot()
    }

    // lädt presets:
    static func loadPresets() -> [DevicePreset] {
        migrateLegacyStorageIfNeeded()
        guard isDatabaseAvailable() else { return [] }
        return load(presetsKey, as: [DevicePreset].self) ?? []
    }

    // speichert presets:
    static func savePresets(_ presets: [DevicePreset]) {
        migrateLegacyStorageIfNeeded()
        guard isDatabaseAvailable() else { return }
        save(presets, forKey: presetsKey)
        push(["presets": presets], to: "/api/presets", method: "PUT")
        NetheraWidgetDataStore.syncSnapshot()
    }

    // lädt globale blocklist für das gesamte netzwerk:
    static func globalBlocklist() -> BlocklistProfile {
        migrateLegacyStorageIfNeeded()
        return load(globalBlocklistKey, as: BlocklistProfile.self) ?? BlocklistProfile()
    }

    // speichert globale blocklist für das gesamte netzwerk:
    static func saveGlobalBlocklist(_ profile: BlocklistProfile) {
        save(profile, forKey: globalBlocklistKey)
        push(["profile": profile], to: "/api/global-blocklist", method: "PUT")
        NetheraWidgetDataStore.syncSnapshot()
        NotificationCenter.default.post(name: .globalBlocklistDidChange, object: nil)
    }

    // lädt adblock-domains für das gesamte netzwerk:
    static func adBlockDomains() -> [AdBlockDomain] {
        migrateLegacyStorageIfNeeded()
        return load(adBlockDomainsKey, as: [AdBlockDomain].self) ?? defaultAdBlockDomains()
    }

    // speichert adblock-domains für das gesamte netzwerk:
    static func saveAdBlockDomains(_ domains: [AdBlockDomain]) {
        save(domains, forKey: adBlockDomainsKey)
        push(["domains": domains], to: "/api/adblock-domains", method: "PUT")
        NetheraWidgetDataStore.syncSnapshot()
        NotificationCenter.default.post(name: .adBlockDomainsDidChange, object: nil)
    }

    // lädt alle gruppen-blocklists:
    static func allGroupBlocklists() -> [String: BlocklistProfile] {
        migrateLegacyStorageIfNeeded()
        guard isDatabaseAvailable() else { return [:] }
        return load(groupBlocklistsKey, as: [String: BlocklistProfile].self) ?? [:]
    }

    // lädt blocklist für eine gruppe:
    static func groupBlocklist(for group: String) -> BlocklistProfile {
        allGroupBlocklists()[group] ?? BlocklistProfile()
    }

    // speichert blocklist für eine gruppe:
    static func saveGroupBlocklist(_ profile: BlocklistProfile, for group: String) {
        guard isDatabaseAvailable() else { return }
        var all = allGroupBlocklists()
        if profile.hasActiveRules {
            all[group] = profile
        } else {
            all.removeValue(forKey: group)
        }
        save(all, forKey: groupBlocklistsKey)
        push(["profile": profile], to: "/api/group-blocklists/\(encodedPath(group))", method: "PUT")
        NetheraWidgetDataStore.syncSnapshot()
        NotificationCenter.default.post(name: .groupBlocklistDidChange, object: nil)
    }

    // benennt gruppen-blocklist mit der gruppe um:
    static func renameGroupBlocklist(from oldGroup: String, to newGroup: String) {
        guard isDatabaseAvailable() else { return }
        guard oldGroup != newGroup else { return }
        var all = allGroupBlocklists()
        let value = all.removeValue(forKey: oldGroup)
        if let value {
            all[newGroup] = value
            push(["profile": value], to: "/api/group-blocklists/\(encodedPath(newGroup))", method: "PUT")
        }
        save(all, forKey: groupBlocklistsKey)
        pushEmpty(to: "/api/group-blocklists/\(encodedPath(oldGroup))", method: "DELETE")
        NetheraWidgetDataStore.syncSnapshot()
        NotificationCenter.default.post(name: .groupBlocklistDidChange, object: nil)
    }

    // löscht gruppen-blocklist:
    static func deleteGroupBlocklist(for group: String) {
        guard isDatabaseAvailable() else { return }
        var all = allGroupBlocklists()
        all.removeValue(forKey: group)
        save(all, forKey: groupBlocklistsKey)
        pushEmpty(to: "/api/group-blocklists/\(encodedPath(group))", method: "DELETE")
        NetheraWidgetDataStore.syncSnapshot()
        NotificationCenter.default.post(name: .groupBlocklistDidChange, object: nil)
    }

    private static func normalizeGroupName(_ name: String) -> String {
        switch name {
        case "Gast", "Neu verbunden":
            return "Nicht zugeordnet"
        default:
            return name
        }
    }

    private static var baseURL: String {
        backendBaseURLCandidates().first ?? defaultBaseURL
    }

    private static func defaultAdBlockDomains() -> [AdBlockDomain] {
        [
            AdBlockDomain(name: "googleads.g.doubleclick.net", time: "2m"),
            AdBlockDomain(name: "connect.facebook.com", time: "4m"),
            AdBlockDomain(name: "stats.g.doubleclick.net", time: "17m"),
            AdBlockDomain(name: "adservice.google.com", time: "29m")
        ]
    }

    private static var defaultBaseURL: String {
        #if targetEnvironment(simulator)
        return "http://localhost:3001"
        #else
        return "http://10.214.9.150:3001"
        #endif
    }

    private static func backendBaseURLCandidates() -> [String] {
        let defaults = UserDefaults.standard
        let rawCandidates = [
            defaults.string(forKey: baseURLKey),
            defaultBaseURL,
            "http://localhost:3001",
            "http://127.0.0.1:3001",
            "http://10.214.9.150:3001"
        ]

        var candidates: [String] = []
        for rawCandidate in rawCandidates {
            guard let candidate = rawCandidate?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !candidate.isEmpty else { continue }
            let normalized = normalizeBaseURL(candidate)
            if !candidates.contains(normalized) {
                candidates.append(normalized)
            }
        }
        return candidates
    }

    private static func normalizeBaseURL(_ value: String) -> String {
        let trimmed = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        guard !trimmed.isEmpty else { return "" }
        if trimmed.contains("://") {
            return trimmed
        }
        return "http://\(trimmed)"
    }

    // übernimmt alte lokale daten einmalig in die neue backend-schicht:
    private static func migrateLegacyStorageIfNeeded() {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: didMigrateLegacyKey) else { return }

        copyLegacyValue(from: "devices.list", to: devicesKey)
        copyLegacyValue(from: "devices.groups", to: groupsKey)
        copyLegacyValue(from: "devices.settings", to: settingsKey)
        copyLegacyValue(from: "SavedDevicePresets", to: presetsKey)
        copyLegacyValue(from: "devices.groupBlocklists", to: groupBlocklistsKey)
        migrateLegacyRouterSettingsIfNeeded()

        defaults.set(true, forKey: didMigrateLegacyKey)
    }

    private static func migrateLegacyRouterSettingsIfNeeded() {
        let defaults = UserDefaults.standard
        guard defaults.data(forKey: routerSettingsKey) == nil else { return }

        let settings = RouterSettings(
            wifiName: defaults.string(forKey: "router.wifiName") ?? "",
            password: defaults.string(forKey: "router.password") ?? "",
            guestPassword: defaults.string(forKey: "router.guestPassword") ?? "",
            notifications: defaults.object(forKey: "router.notifications") as? Bool ?? false,
            darkMode: defaults.object(forKey: "router.darkMode") as? Bool ?? false,
            frequency: defaults.string(forKey: "router.frequency") ?? "",
            firewall: defaults.object(forKey: "router.firewall") as? Bool ?? false
        )

        save(settings, forKey: routerSettingsKey)
    }

    private static func copyLegacyValue(from oldKey: String, to newKey: String) {
        let defaults = UserDefaults.standard
        guard defaults.data(forKey: newKey) == nil,
              let oldData = defaults.data(forKey: oldKey) else { return }
        defaults.set(oldData, forKey: newKey)
    }

    private static func markDatabaseUnavailable() {
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: backendAvailableKey)

        DispatchQueue.main.async {
            NetheraWidgetDataStore.syncSnapshot()
            NotificationCenter.default.post(name: .netheraBackendDidRefresh, object: nil)
        }
    }

    private static func load<T: Decodable>(_ key: String, as type: T.Type) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private static func save<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private static func push<T: Encodable>(_ body: T, to path: String, method: String) {
        guard let url = URL(string: "\(baseURL)\(path)"),
              let data = try? JSONEncoder().encode(body) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error {
                print("NetheraBackend push failed \(method) \(path): \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                print("NetheraBackend push failed \(method) \(path): status \(httpResponse.statusCode)")
                return
            }

            UserDefaults.standard.set(true, forKey: backendAvailableKey)
            print("NetheraBackend push ok \(method) \(path)")
        }.resume()
    }

    private static func pushEmpty(to path: String, method: String) {
        guard let url = URL(string: "\(baseURL)\(path)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = method
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error {
                print("NetheraBackend push failed \(method) \(path): \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                print("NetheraBackend push failed \(method) \(path): status \(httpResponse.statusCode)")
                return
            }

            UserDefaults.standard.set(true, forKey: backendAvailableKey)
            print("NetheraBackend push ok \(method) \(path)")
        }.resume()
    }

    private static func encodedPath(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? value
    }
}

extension Notification.Name {
    static let netheraBackendDidRefresh = Notification.Name("netheraBackendDidRefresh")
}
