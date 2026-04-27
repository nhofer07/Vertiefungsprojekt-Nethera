import SwiftUI
import UniformTypeIdentifiers

private struct DeviceDragItem: Codable, Transferable {
    let id: UUID

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}

private struct GroupEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let subtitle: String
    let confirmLabel: String
    let initialName: String
    let onConfirm: (String) -> Void

    @State private var name: String

    init(
        title: String,
        subtitle: String,
        confirmLabel: String,
        initialName: String = "",
        onConfirm: @escaping (String) -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.confirmLabel = confirmLabel
        self.initialName = initialName
        self.onConfirm = onConfirm
        _name = State(initialValue: initialName)
    }

    // gruppe adden:
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.18, blue: 0.22),
                        Color(red: 0.02, green: 0.02, blue: 0.05)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text(title)
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Name")
                            .font(.headline)
                            .foregroundColor(.white)

                        TextField(
                            "Gruppenname",
                            text: $name,
                            prompt: Text("Gruppenname").foregroundColor(.white.opacity(0.45))
                        )
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                    )

                    Button {
                        confirm()
                    } label: {
                        Text(confirmLabel)
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(red: 0.35, green: 0.75, blue: 0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Spacer()
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Zurück", systemImage: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .presentationDragIndicator(.visible)
    }

    private func confirm() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onConfirm(trimmed)
        dismiss()
    }
}

struct DevicesView: View {
    private static let devicesKey = "devices.list"
    private static let groupsKey = "devices.groups"

    // dummydaten:
    private static let defaultDevices = [
        Device(id: UUID(), name: "iPhone von Nico", type: "iphone.homebutton", onlineTime: "12h", dataUsage: "57 GB", group: "Eltern"),
        Device(id: UUID(), name: "MacBook Nico", type: "laptopcomputer", onlineTime: "5h", dataUsage: "12 GB", group: "Eltern"),
        Device(id: UUID(), name: "Annas iPhone", type: "iphone", onlineTime: "6h", dataUsage: "4 GB", group: "Kinder"),
        Device(id: UUID(), name: "Smart TV", type: "tv", onlineTime: "3h", dataUsage: "8 GB", group: "Wohnzimmer"),
        Device(id: UUID(), name: "Tobis iPad", type: "ipad", onlineTime: "8m", dataUsage: "120 MB", group: "Gast")
    ]

    private static let defaultGroups = ["Eltern", "Kinder", "Wohnzimmer", "Gast"]

    @State private var devices: [Device] = Self.loadDevices()
    @State private var groups: [String] = Self.loadGroups()

    @State private var showGroupSheet = false
    @State private var groupSheetMode: GroupSheetMode = .create

    @State private var groupToDelete: String?
    @State private var showDeleteGroup = false
    @State private var targetedDropGroup: String?

    @State private var groupBlocklistTarget: GroupBlocklistTarget?
    @State private var showMoveInfoBanner = true
    @State private var refreshGroupsToken = UUID()

    private struct GroupBlocklistTarget: Identifiable {
        let id = UUID()
        let group: String
    }

    private let fallbackGroup = "Neu verbunden"

    private enum GroupSheetMode {
        case create
        case rename(String)

        var title: String {
            switch self {
            case .create:
                return "Neue Gruppe"
            case .rename:
                return "Gruppe umbenennen"
            }
        }

        var subtitle: String {
            switch self {
            case .create:
                return "Lege eine neue Gerätegruppe an."
            case .rename:
                return "Passe den Namen deiner Gruppe an."
            }
        }

        var confirmLabel: String {
            switch self {
            case .create:
                return "Gruppe erstellen"
            case .rename:
                return "Änderung speichern"
            }
        }

        var initialName: String {
            switch self {
            case .create:
                return ""
            case .rename(let oldName):
                return oldName
            }
        }
    }

    private static func loadDevices() -> [Device] {
        guard let data = UserDefaults.standard.data(forKey: devicesKey),
              let decoded = try? JSONDecoder().decode([Device].self, from: data) else {
            return defaultDevices
        }
        return decoded
    }

    private static func loadGroups() -> [String] {
        guard let data = UserDefaults.standard.data(forKey: groupsKey),
              let decoded = try? JSONDecoder().decode([String].self, from: data) else {
            return defaultGroups
        }
        return decoded
    }

    private func saveDevices() {
        guard let data = try? JSONEncoder().encode(devices) else { return }
        UserDefaults.standard.set(data, forKey: Self.devicesKey)
    }

    private func saveGroups() {
        guard let data = try? JSONEncoder().encode(groups) else { return }
        UserDefaults.standard.set(data, forKey: Self.groupsKey)
    }

    private func ensureFallbackGroupExists() {
        if !groups.contains(fallbackGroup) {
            groups.append(fallbackGroup)
            saveGroups()
        }
    }

    private func moveDevice(withID deviceID: UUID, to group: String) {
        guard let index = devices.firstIndex(where: { $0.id == deviceID }) else { return }
        guard devices[index].group != group else { return }

        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
            devices[index].group = group
        }

        saveDevices()
    }

    private func openCreateGroupSheet() {
        groupSheetMode = .create
        showGroupSheet = true
    }

    private func openRenameGroupSheet(for group: String) {
        groupSheetMode = .rename(group)
        showGroupSheet = true
    }

    private func submitGroupName(_ name: String) {
        switch groupSheetMode {
        case .create:
            guard !groups.contains(name) else { return }
            groups.append(name)
            saveGroups()

        case .rename(let oldName):
            guard let oldIndex = groups.firstIndex(of: oldName) else { return }
            guard name == oldName || !groups.contains(name) else { return }

            groups[oldIndex] = name

            for index in devices.indices where devices[index].group == oldName {
                devices[index].group = name
            }

            NetheraStorage.renameGroupBlocklist(from: oldName, to: name)
            saveGroups()
            saveDevices()
        }
    }

    private func deleteGroup(_ group: String) {
        guard group != fallbackGroup else { return }

        ensureFallbackGroupExists()
        groups.removeAll { $0 == group }

        for index in devices.indices where devices[index].group == group {
            devices[index].group = fallbackGroup
        }

        NetheraStorage.deleteGroupBlocklist(for: group)
        saveGroups()
        saveDevices()
    }

    private func deviceSettings(for device: Device) -> DeviceSettings {
        NetheraStorage.deviceSettings(for: device.id)
    }

    private func activePreset(for device: Device) -> DevicePreset? {
        let settings = deviceSettings(for: device)

        guard settings.hasOwnBlocklist else { return nil }

        return NetheraStorage.loadPresets().first { preset in
            preset.parentalControl == settings.parentalControl &&
            preset.prioritized == settings.prioritized &&
            preset.timeLimitEnabled == settings.timeLimitEnabled &&
            preset.blocklist == settings.blocklist &&
            (!preset.timeLimitEnabled || (
                // Vergleicht, ob die Minuten von zwei Zeiten gleich sind
                Calendar.current.component(.hour, from: preset.startTime) == Calendar.current.component(.hour, from: settings.startTime) &&
                Calendar.current.component(.minute, from: preset.startTime) == Calendar.current.component(.minute, from: settings.startTime) &&
                Calendar.current.component(.hour, from: preset.endTime) == Calendar.current.component(.hour, from: settings.endTime) &&
                Calendar.current.component(.minute, from: preset.endTime) == Calendar.current.component(.minute, from: settings.endTime)
            ))
        }
    }

    private func blocklistProfile(for group: String) -> BlocklistProfile {
        NetheraStorage.groupBlocklist(for: group)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.18, blue: 0.22),
                        Color(red: 0.02, green: 0.02, blue: 0.05)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            if showMoveInfoBanner {
                                infoBanner
                            }

                            LazyVStack(spacing: 14) {
                                ForEach(groups, id: \.self) { group in
                                    groupSection(for: group)
                                }
                            }
                            .id(refreshGroupsToken)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                    }
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            openCreateGroupSheet()
                        } label: {
                            Image(systemName: "folder.badge.plus")
                                .font(.title2.weight(.semibold))
                                .foregroundColor(.black)
                                .frame(width: 56, height: 56)
                                .background(Color(red: 0.35, green: 0.75, blue: 0.9).opacity(0.86))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.28), radius: 12, x: 0, y: 6)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            ensureFallbackGroupExists()
        }
        .onReceive(NotificationCenter.default.publisher(for: .groupBlocklistDidChange)) { _ in
            refreshGroupsToken = UUID()
        }
        .sheet(isPresented: $showGroupSheet) {
            GroupEditorSheet(
                title: groupSheetMode.title,
                subtitle: groupSheetMode.subtitle,
                confirmLabel: groupSheetMode.confirmLabel,
                initialName: groupSheetMode.initialName,
                onConfirm: submitGroupName
            )
        }
        .sheet(item: $groupBlocklistTarget) { target in
            BlocklistEditorSheet(
                title: "Gruppen-Blocklist",
                subtitle: target.group,
                initialProfile: blocklistProfile(for: target.group)
            ) { profile in
                NetheraStorage.saveGroupBlocklist(profile, for: target.group)
                refreshGroupsToken = UUID()
            }
        }
        .alert("Gruppe entfernen", isPresented: $showDeleteGroup, presenting: groupToDelete) { group in
            Button("Entfernen", role: .destructive) {
                deleteGroup(group)
            }

            Button("Abbrechen", role: .cancel) { }
        } message: { group in
            Text("Alle Geräte aus \(group) werden in \(fallbackGroup) verschoben.")
        }
    }

    // infobanner:
    private var infoBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "hand.tap")
                .foregroundColor(.cyan)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text("Halte ein Gerät links am Griff und ziehe es direkt in eine andere Gruppe.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.72))
            }

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.18)) {
                    showMoveInfoBanner = false
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white.opacity(0.86))
                    .frame(width: 28, height: 28)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.08))
        )
    }

    // Erlaubt mehrere Views in einer Funktion/Property zu kombinieren (ohne return)
    @ViewBuilder
    private func groupSection(for group: String) -> some View {
        let groupDevices = devices.filter { $0.group == group }
        let isDropTarget = targetedDropGroup == group
        let groupBlocklist = blocklistProfile(for: group)

        VStack(alignment: .leading, spacing: 10) {
            groupHeader(
                for: group,
                deviceCount: groupDevices.count,
                isDropTarget: isDropTarget,
                groupBlocklist: groupBlocklist
            )

            if groupDevices.isEmpty {
                emptyGroupState
            } else {
                ForEach(groupDevices) { device in
                    if let index = devices.firstIndex(where: { $0.id == device.id }) {
                        deviceRow(at: index)
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    isDropTarget
                    ? Color(red: 0.14, green: 0.22, blue: 0.28)
                    : Color(red: 0.07, green: 0.11, blue: 0.16)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            isDropTarget
                            ? Color.cyan.opacity(0.8)
                            : Color.white.opacity(0.08),
                            lineWidth: 1
                        )
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 18))
        .dropDestination(for: DeviceDragItem.self) { items, _ in
            guard let draggedDevice = items.first else { return false }
            moveDevice(withID: draggedDevice.id, to: group)
            targetedDropGroup = nil
            return true
        } isTargeted: { isTargeted in
            if isTargeted {
                targetedDropGroup = group
            } else if targetedDropGroup == group {
                targetedDropGroup = nil
            }
        }
    }

    private func groupHeader(
        for group: String,
        deviceCount: Int,
        isDropTarget: Bool,
        groupBlocklist: BlocklistProfile
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(group)
                            .foregroundColor(.white)
                            .font(.headline)

                        Text("\(deviceCount)")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Capsule())
                    }

                    if groupBlocklist.hasActiveRules {
                        Label(groupBlocklist.summaryText, systemImage: "shield.lefthalf.filled")
                            .font(.caption)
                            .foregroundColor(.cyan.opacity(0.95))
                    }
                }

                Spacer()

                Menu {
                    Button {
                        groupBlocklistTarget = GroupBlocklistTarget(group: group)
                    } label: {
                        Label("Blocklist bearbeiten", systemImage: "shield")
                    }

                    Button {
                        openRenameGroupSheet(for: group)
                    } label: {
                        Label("Umbenennen", systemImage: "pencil")
                    }

                    if group != fallbackGroup {
                        Button(role: .destructive) {
                            groupToDelete = group
                            showDeleteGroup = true
                        } label: {
                            Label("Gruppe löschen", systemImage: "trash")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.white.opacity(0.85))
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }

            if isDropTarget {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.down.doc")
                        .foregroundColor(.cyan)

                    Text("Hier ablegen zum Verschieben")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.footnote)

                    Spacer()
                }
                .transition(.opacity)
            }
        }
    }

    private var emptyGroupState: some View {
        HStack {
            Image(systemName: "tray")
                .foregroundColor(.white.opacity(0.5))

            Text("Keine Geräte in dieser Gruppe")
                .foregroundColor(.white.opacity(0.7))
                .font(.subheadline)

            Spacer()
        }
        .padding(.vertical, 8)
    }

    private func deviceRow(at index: Int) -> some View {
        let activePreset = activePreset(for: devices[index])

        return NavigationLink(destination:
            DeviceDetailView(device: $devices[index], groups: groups)
                .onDisappear {
                    refreshGroupsToken = UUID()
                }
        ) {
            HStack(spacing: 12) {
                Image(systemName: "line.3.horizontal")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.55))
                    .frame(width: 22, height: 44)
                    .contentShape(Rectangle())
                    .draggable(DeviceDragItem(id: devices[index].id))

                Image(systemName: devices[index].type)
                    .font(.title2)
                    .frame(width: 35)
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 5) {
                    Text(devices[index].name)
                        .foregroundColor(.white)
                        .font(.body.weight(.medium))

                    Text(activePreset == nil ? "Kein Preset aktiv" : "Preset: \(activePreset!.name)")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.cyan.opacity(0.9))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(red: 0.1, green: 0.15, blue: 0.2))
            )
        }
        .buttonStyle(.plain)
    }

    private func infoChip(label: String, icon: String, tint: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
            Text(label)
        }
        .font(.caption2.weight(.semibold))
        .foregroundColor(tint.opacity(0.78))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tint.opacity(0.08))
        .clipShape(Capsule())
    }
}

#Preview {
    DevicesView()
}
