import SwiftUI

struct DevicesView: View {
    
    @State private var devices = [
        Device(name: "iPhone von Nico", type: "iphone.homebutton", onlineTime: "12h", dataUsage: "57 GB", group: "Eltern"),
        Device(name: "MacBook Nico", type: "laptopcomputer", onlineTime: "5h", dataUsage: "12 GB", group: "Eltern"),
        Device(name: "Annas iPhone", type: "iphone", onlineTime: "6h", dataUsage: "4 GB", group: "Kinder"),
        Device(name: "Smart TV", type: "tv", onlineTime: "3h", dataUsage: "8 GB", group: "Wohnzimmer")
    ]
    
    @State private var groups = ["Eltern","Kinder","Wohnzimmer"]
    
    @State private var showAddGroup = false
    @State private var newGroupName = ""
    
    @State private var renameGroup = ""
    @State private var showRename = false
    
    var groupedDevices: [String: [Device]] {
        Dictionary(grouping: devices, by: { $0.group })
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
                    // Weißer Titel links
                    HStack {
                        Text("Geräte")
                            .foregroundColor(.white)
                            .font(.largeTitle.bold())
                        Spacer()
                        
                        // Plus Button rechts oben
                        Button {
                            showAddGroup = true
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    List {
                        ForEach(groups, id:\.self) { group in
                            
                            // Weißer Header als eigene View
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(group)
                                        .foregroundColor(.white)
                                        .font(.headline)
                                    Spacer()
                                }
                                .padding(.vertical, 6)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    renameGroup = group
                                    showRename = true
                                }
                            }
                            .listRowBackground(Color.clear)
                            
                            ForEach(groupedDevices[group] ?? []) { device in
                                NavigationLink(destination: DeviceDetailView(device: device)) {
                                    HStack {
                                        Image(systemName: device.type)
                                            .font(.title2)
                                            .frame(width: 35)
                                            .foregroundColor(.white)
                                        
                                        VStack(alignment: .leading) {
                                            Text(device.name)
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
                if !renameGroup.isEmpty && !groups.contains(renameGroup) {
                    if let oldIndex = groups.firstIndex(of: renameGroup) {
                        groups[oldIndex] = renameGroup
                    }
                }
            }
            Button("Abbrechen", role: .cancel) {}
        }
    }
}

#Preview {
    DevicesView()
}
