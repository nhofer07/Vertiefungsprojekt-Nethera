import SwiftUI

struct DevicesView: View {
    
    @State private var devices = [
        Device(name: "iPhone von Nico", type: "iphone.homebutton", onlineTime: "12h", dataUsage: "57 GB", group: "Eltern"),
        Device(name: "MacBook Nico", type: "laptopcomputer", onlineTime: "5h", dataUsage: "12 GB", group: "Eltern"),
        Device(name: "Annas iPhone", type: "iphone", onlineTime: "6h", dataUsage: "4 GB", group: "Kinder"),
        Device(name: "Smart TV", type: "tv", onlineTime: "3h", dataUsage: "8 GB", group: "Wohnzimmer"),
        Device(name: "Neues iPad", type: "ipad", onlineTime: "8m", dataUsage: "120 MB", group: "Neu verbunden")
    ]
    
    @State private var groups = ["Eltern","Kinder","Wohnzimmer","Neu verbunden"]
    
    @State private var showAddGroup = false
    @State private var newGroupName = ""
    
    @State private var selectedGroupForRename = ""
    @State private var renameGroup = ""
    @State private var showRename = false
    @State private var selectedGroupForActions: String?
    @State private var showGroupActions = false
    @State private var groupToDelete: String?
    @State private var showDeleteGroup = false

    private let fallbackGroup = "Neu verbunden"

    private func deleteGroup(_ group: String) {
        guard group != fallbackGroup else { return }
        if !groups.contains(fallbackGroup) {
            groups.append(fallbackGroup)
        }
        groups.removeAll { $0 == group }
        for index in devices.indices where devices[index].group == group {
            devices[index].group = fallbackGroup
        }
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
                    
                    List {
                        ForEach(groups, id:\.self) { group in
                            let groupDeviceIndices = devices.indices.filter { devices[$0].group == group }
                            
                            // Weißer Header als eigene View
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(group)
                                        .foregroundColor(.white)
                                        .font(.headline)

                                    Text("(\(groupDeviceIndices.count))")
                                        .foregroundColor(.white.opacity(0.6))
                                        .font(.subheadline)

                                    Spacer()

                                    Button {
                                        selectedGroupForActions = group
                                        showGroupActions = true
                                    } label: {
                                        Image(systemName: "ellipsis.circle")
                                            .foregroundColor(.white.opacity(0.85))
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.vertical, 6)
                            }
                            .listRowBackground(Color.clear)
                            
                            if groupDeviceIndices.isEmpty {
                                HStack {
                                    Image(systemName: "tray")
                                        .foregroundColor(.white.opacity(0.5))
                                    Text("Keine Geräte in dieser Gruppe")
                                        .foregroundColor(.white.opacity(0.7))
                                        .font(.subheadline)
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 0.1, green: 0.15, blue: 0.2).opacity(0.6))
                                )
                            }

                            ForEach(groupDeviceIndices, id: \.self) { index in
                                NavigationLink(destination: DeviceDetailView(device: $devices[index], groups: groups)) {
                                    HStack {
                                        Image(systemName: devices[index].type)
                                            .font(.title2)
                                            .frame(width: 35)
                                            .foregroundColor(.white)
                                        
                                        VStack(alignment: .leading) {
                                            Text(devices[index].name)
                                                .foregroundColor(.white)
                                            Text("Online")
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 0.1, green: 0.15, blue: 0.2))
                                )
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        // Gruppe hinzufügen
        .alert("Neue Gruppe", isPresented: $showAddGroup) {
            TextField("Gruppenname", text: $newGroupName)
            Button("Erstellen") {
                if !newGroupName.isEmpty && !groups.contains(newGroupName) {
                    groups.append(newGroupName)
                    newGroupName = ""
                }
            }
            Button("Abbrechen", role: .cancel) {}
        }
        // Gruppe umbenennen
        .alert("Gruppe umbenennen", isPresented: $showRename) {
            TextField("Neuer Name", text: $renameGroup)
            Button("Speichern") {
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
            }
            Button("Abbrechen", role: .cancel) {}
        }
        .confirmationDialog("Gruppenaktionen", isPresented: $showGroupActions, titleVisibility: .visible, presenting: selectedGroupForActions) { group in
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
            Button("Abbrechen", role: .cancel) {}
        }
        .alert("Gruppe entfernen", isPresented: $showDeleteGroup, presenting: groupToDelete) { group in
            Button("Entfernen", role: .destructive) {
                deleteGroup(group)
            }
            Button("Abbrechen", role: .cancel) {}
        } message: { group in
            Text("Alle Geräte aus \(group) werden in \(fallbackGroup) verschoben.")
        }
    }
}

#Preview {
    DevicesView()
}
