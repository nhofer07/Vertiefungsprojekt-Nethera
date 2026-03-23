import SwiftUI

struct DeviceDetailView: View {

    @Binding var device: Device
    let groups: [String]
    
    @State private var parentalControl = true
    @State private var prioritized = false
    @State private var timeLimitEnabled = false
    @State private var startTime = Date()
    @State private var endTime = Date()
    
    struct DevicePreset: Codable, Identifiable, Equatable {
        let id: UUID
        var name: String
        var group: String
        var parentalControl: Bool
        var prioritized: Bool
        var timeLimitEnabled: Bool
        var startTime: Date
        var endTime: Date
    }

    private let presetsKey = "SavedDevicePresets"

    @State private var showPresetSheet = false
    @State private var presetName: String = ""
    @State private var saveErrorMessage: String?
    @State private var presets: [DevicePreset] = []

    private func loadPresets() -> [DevicePreset] {
        guard let data = UserDefaults.standard.data(forKey: presetsKey) else { return [] }
        do {
            return try JSONDecoder().decode([DevicePreset].self, from: data)
        } catch {
            return []
        }
    }

    private func savePresets(_ presets: [DevicePreset]) {
        do {
            let data = try JSONEncoder().encode(presets)
            UserDefaults.standard.set(data, forKey: presetsKey)
        } catch {
            saveErrorMessage = "Konnte Presets nicht speichern."
        }
    }

    private func saveCurrentAsPreset(named name: String) {
        var existingPresets = loadPresets()
        let newPreset = DevicePreset(
            id: UUID(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            group: device.group,
            parentalControl: parentalControl,
            prioritized: prioritized,
            timeLimitEnabled: timeLimitEnabled,
            startTime: startTime,
            endTime: endTime
        )
        existingPresets.append(newPreset)
        savePresets(existingPresets)
        presets = existingPresets
    }

    private func applyPreset(_ preset: DevicePreset) {
        device.group = preset.group
        parentalControl = preset.parentalControl
        prioritized = preset.prioritized
        timeLimitEnabled = preset.timeLimitEnabled
        startTime = preset.startTime
        endTime = preset.endTime
    }

    private func deletePreset(_ preset: DevicePreset) {
        var existingPresets = loadPresets()
        existingPresets.removeAll { $0.id == preset.id }
        savePresets(existingPresets)
        withAnimation {
            presets = existingPresets
        }
    }

    private func refreshPresets() {
        presets = loadPresets()
    }

    var body: some View {
        
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.08, green: 0.18, blue: 0.22),
                         Color(red: 0.02, green: 0.02, blue: 0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    Image(systemName: device.type)
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .padding()
                    
                    Text(device.name)
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    
                    InfoCard(title: device.onlineTime, subtitle: "Online")
                    InfoCard(title: device.dataUsage, subtitle: "Datenverbrauch")
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Gerätegruppe")
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        Picker("Gruppe: \(device.group)", selection: $device.group) {
                            ForEach(groups, id:\.self) { g in
                                Text(g)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(red: 0.1, green: 0.15, blue: 0.2))
                    )
                    
                    VStack(spacing: 15) {
                        
                        Toggle("Kindersicherung", isOn: $parentalControl)
                            .toggleStyle(SwitchToggleStyle(tint: .cyan))
                            .foregroundColor(.white)
                        
                        Toggle("Gerät priorisieren", isOn: $prioritized)
                            .toggleStyle(SwitchToggleStyle(tint: .cyan))
                            .foregroundColor(.white)
                        
                        Toggle("Zeitbeschränkung", isOn: $timeLimitEnabled)
                            .toggleStyle(SwitchToggleStyle(tint: .cyan))
                            .foregroundColor(.white)
                        
                        if timeLimitEnabled {
                            VStack(spacing: 12) {
                                
                                HStack {
                                    Text("Von").foregroundColor(.white)
                                    Spacer()
                                    DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .tint(Color(red: 0.35, green: 0.75, blue: 0.9))
                                        .colorScheme(.dark)
                                }
                                
                                HStack {
                                    Text("Bis").foregroundColor(.white)
                                    Spacer()
                                    DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .tint(Color(red: 0.35, green: 0.75, blue: 0.9))
                                        .colorScheme(.dark)
                                }
                                
                                Text("Internet verboten von \(startTime.formatted(date: .omitted, time: .shortened)) bis \(endTime.formatted(date: .omitted, time: .shortened))")
                                    .font(.footnote)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .colorScheme(.dark)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(red: 0.1, green: 0.15, blue: 0.2))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 0.35, green: 0.75, blue: 0.9).opacity(0.25), lineWidth: 1)
                    )
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
        }
        .onAppear {
            refreshPresets()
        }
        .onChange(of: device.id) { _ in
            refreshPresets()
        }
        .onChange(of: showPresetSheet) { isPresented in
            if isPresented {
                refreshPresets()
            }
        }
        .toolbar {
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    refreshPresets()
                    showPresetSheet = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Gerät entfernen") {
                    print("Gerät entfernt")
                }
                .foregroundColor(.white)
            }
        }
        
        .sheet(isPresented: $showPresetSheet) {
            NavigationStack {
                
                ZStack {
                    
                    LinearGradient(
                        colors: [Color(red: 0.08, green: 0.18, blue: 0.22),
                                 Color(red: 0.02, green: 0.02, blue: 0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            
                            Text("Presets")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                
                                Text("Neues Preset")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                ZStack(alignment: .leading) {
                                    
                                    if presetName.isEmpty {
                                        Text("Preset Name")
                                            .foregroundColor(.white.opacity(0.5))
                                            .padding(.horizontal, 14)
                                    }

                                    TextField("", text: $presetName)
                                        .padding()
                                        .foregroundColor(.white)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 0.12, green: 0.17, blue: 0.22))
                                )
                                
                                Button {
                                    let name = presetName.trimmingCharacters(in: .whitespacesAndNewlines)
                                    guard !name.isEmpty else { return }
                                    saveCurrentAsPreset(named: name)
                                    presetName = ""
                                } label: {
                                    Text("Preset speichern")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 14)
                                                .fill(Color(red: 0.35, green: 0.75, blue: 0.9))
                                        )
                                        .foregroundColor(.black)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color(red: 0.1, green: 0.15, blue: 0.2))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color(red: 0.35, green: 0.75, blue: 0.9).opacity(0.25), lineWidth: 1)
                            )
                            
                            VStack(alignment: .leading, spacing: 14) {
                                
                                Text("Gespeicherte Presets")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                ForEach(presets) { preset in
                                    
                                    HStack {
                                        
                                        Button {
                                            applyPreset(preset)
                                            showPresetSheet = false
                                        } label: {
                                            
                                            VStack(alignment: .leading, spacing: 6) {
                                                
                                                Text(preset.name)
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                
                                                Text("Gruppe: \(preset.group)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white.opacity(0.7))
                                                
                                                HStack {
                                                    
                                                    Label(
                                                        preset.parentalControl ? "Kindersicherung An" : "Kindersicherung Aus",
                                                        systemImage: preset.parentalControl ? "lock.fill" : "lock.open"
                                                    )
                                                    
                                                    Spacer()
                                                    
                                                    if preset.prioritized {
                                                        Label("Priorisiert", systemImage: "bolt.fill")
                                                    }
                                                }
                                                .font(.footnote)
                                                .foregroundColor(.white.opacity(0.7))
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Button {
                                            deletePreset(preset)
                                        } label: {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(red: 0.1, green: 0.15, blue: 0.2))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color(red: 0.35, green: 0.75, blue: 0.9).opacity(0.25), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding()
                    }
                }
                .onAppear {
                    refreshPresets()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Fertig") {
                            showPresetSheet = false
                        }
                        .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DeviceDetailView(
            device: .constant(Device(
                name: "iPhone von Nico",
                type: "iphone.homebutton",
                onlineTime: "12h",
                dataUsage: "57 GB",
                group: "Eltern"
            )),
            groups: ["Eltern", "Kinder", "Wohnzimmer", "Neu verbunden"]
        )
    }
}
