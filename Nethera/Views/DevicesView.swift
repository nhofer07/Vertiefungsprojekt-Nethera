import SwiftUI
import UniformTypeIdentifiers

private struct DeviceDragItem: Codable, Transferable {
    let id: UUID

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}

struct DevicesView: View {

    private static let devicesKey = "devices.list"
    private static let groupsKey = "devices.groups"

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

    @State private var showAddGroup = false
    @State private var newGroupName = ""

    @State private var selectedGroupForRename = ""
    @State private var renameGroup = ""
    @State private var showRename = false

    @State private var groupToDelete: String?
    @State private var showDeleteGroup = false
    @State private var targetedDropGroup: String?

    private let fallbackGroup = "Neu verbunden"

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

        withAnimation {
            devices[index].group = group
        }

        saveDevices()
    }

    private func renameSelectedGroup() {
        let newName = renameGroup.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !newName.isEmpty,
              let oldIndex = groups.firstIndex(of: selectedGroupForRename) else { return }

        if newName != selectedGroupForRename && groups.contains(newName) {
            return
        }

        groups[oldIndex] = newName

        for index in devices.indices where devices[index].group == selectedGroupForRename {
            devices[index].group = newName
        }

        saveGroups()
        saveDevices()
    }

    private func deleteGroup(_ group: String) {
        guard group != fallbackGroup else { return }

        ensureFallbackGroupExists()
        groups.removeAll { $0 == group }

        for index in devices.indices where devices[index].group == group {
            devices[index].group = fallbackGroup
        }

        saveGroups()
        saveDevices()
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
                    PageHeaderView(title: "Geräte", showBackButton: true) {
                        Button {
                            showAddGroup = true
                        } label: {
                            Label("Gruppe", systemImage: "folder.badge.plus")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                    }

                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(groups, id: \.self) { group in
                                groupSection(for: group)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            ensureFallbackGroupExists()
        }
        .alert("Neue Gruppe", isPresented: $showAddGroup) {
            TextField("Gruppenname", text: $newGroupName)

            Button("Erstellen") {
                let name = newGroupName.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !name.isEmpty, !groups.contains(name) else { return }

                groups.append(name)
                newGroupName = ""
                saveGroups()
            }

            Button("Abbrechen", role: .cancel) { }
        }
        .alert("Gruppe umbenennen", isPresented: $showRename) {
            TextField("Neuer Name", text: $renameGroup)

            Button("Speichern") {
                renameSelectedGroup()
            }

            Button("Abbrechen", role: .cancel) { }
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

    @ViewBuilder
    private func groupSection(for group: String) -> some View {
        let groupDevices = devices.filter { $0.group == group }
        let isDropTarget = targetedDropGroup == group

        VStack(alignment: .leading, spacing: 10) {
            groupHeader(for: group, deviceCount: groupDevices.count, isDropTarget: isDropTarget)

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
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    isDropTarget
                    ? Color(red: 0.14, green: 0.22, blue: 0.28)
                    : Color(red: 0.07, green: 0.11, blue: 0.16)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isDropTarget
                            ? Color.cyan.opacity(0.8)
                            : Color.white.opacity(0.08),
                            lineWidth: 1
                        )
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 16))
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

    private func groupHeader(for group: String, deviceCount: Int, isDropTarget: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(group)
                    .foregroundColor(.white)
                    .font(.headline)

                Text("(\(deviceCount))")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.subheadline)

                Spacer()

                Menu {
                    Button("Umbenennen") {
                        selectedGroupForRename = group
                        renameGroup = group
                        showRename = true
                    }

                    if group != fallbackGroup {
                        Button("Gruppe löschen", role: .destructive) {
                            groupToDelete = group
                            showDeleteGroup = true
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.white.opacity(0.85))
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
        NavigationLink(destination: DeviceDetailView(device: $devices[index], groups: groups)) {
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

                VStack(alignment: .leading, spacing: 4) {
                    Text(devices[index].name)
                        .foregroundColor(.white)

                    Text("Online • \(devices[index].onlineTime)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.1, green: 0.15, blue: 0.2))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DevicesView()
}
