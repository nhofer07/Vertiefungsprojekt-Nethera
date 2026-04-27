import SwiftUI

private struct PresetEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let confirmLabel: String
    let initialName: String
    let subtitle: String
    let onConfirm: (String) -> Void

    @State private var name: String

    init(
        title: String,
        confirmLabel: String,
        initialName: String,
        subtitle: String,
        onConfirm: @escaping (String) -> Void
    ) {
        self.title = title
        self.confirmLabel = confirmLabel
        self.initialName = initialName
        self.subtitle = subtitle
        self.onConfirm = onConfirm
        _name = State(initialValue: initialName)
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
                        Text("Preset-Name")
                            .font(.headline)
                            .foregroundColor(.white)

                        TextField(
                            "Preset Name",
                            text: $name,
                            prompt: Text("Preset Name").foregroundColor(.white.opacity(0.45))
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

struct DeviceDetailView: View {
    @Binding var device: Device
    let groups: [String]

    @State private var parentalControl = true
    @State private var prioritized = false
    @State private var timeLimitEnabled = false
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var deviceBlocklist = BlocklistProfile()
    @State private var hasOwnBlocklist = false

    @State private var showCreatePresetSheet = false
    @State private var presetToEdit: DevicePreset?
    @State private var presets: [DevicePreset] = []
    @State private var showBlocklistSheet = false
    @State private var refreshGroupBlocklistToken = UUID()

    private var activePresetLabel: String? {
        guard let preset = activeDevicePreset else { return nil }
        return "Preset aktiv: \(preset.name)"
    }

    private var groupBlocklist: BlocklistProfile {
        NetheraStorage.groupBlocklist(for: device.group)
    }

    private var effectiveBlocklist: BlocklistProfile {
        _ = refreshGroupBlocklistToken
        return hasOwnBlocklist ? deviceBlocklist : groupBlocklist
    }

    private var activeDevicePreset: DevicePreset? {
        presets.first { isActivePreset($0) }
    }

    private var currentSettings: DeviceSettings {
        DeviceSettings(
            parentalControl: parentalControl,
            prioritized: prioritized,
            timeLimitEnabled: timeLimitEnabled,
            startTime: startTime,
            endTime: endTime,
            blocklist: deviceBlocklist,
            hasOwnBlocklist: hasOwnBlocklist
        )
    }

    var body: some View {
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

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerCard
                    statsGrid
                    controlsCard
                    blocklistCard
                    presetsHintCard
                    Spacer(minLength: 20)
                }
                .padding()
            }
        }
        .onAppear {
            loadSettings()
            refreshPresets()
        }
        .onChange(of: device.id) {
            loadSettings()
            refreshPresets()
        }
        .onChange(of: parentalControl) { persistSettings() }
        .onChange(of: prioritized) { persistSettings() }
        .onChange(of: timeLimitEnabled) { persistSettings() }
        .onChange(of: startTime) { persistSettings() }
        .onChange(of: endTime) { persistSettings() }
        .onReceive(NotificationCenter.default.publisher(for: .groupBlocklistDidChange)) { _ in
            refreshGroupBlocklistToken = UUID()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: presetsPage.onAppear { refreshPresets() }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                }
            }
        }
        .sheet(isPresented: $showBlocklistSheet) {
            BlocklistEditorSheet(
                title: "Geräte-Blocklist",
                subtitle: device.name,
                initialProfile: effectiveBlocklist
            ) { profile in
                deviceBlocklist = profile
                hasOwnBlocklist = true
                persistSettings()
                refreshGroupBlocklistToken = UUID()
            }
        }
    }

    private var headerCard: some View {
        VStack(spacing: 14) {
            Image(systemName: device.type)
                .font(.system(size: 50))
                .foregroundColor(.white)
                .padding(.top, 8)

            Text(device.name)
                .font(.title.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            HStack(spacing: 8) {
                Text(device.group)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white.opacity(0.72))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Capsule())

                Text(activeDevicePreset?.name ?? "Kein Preset")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white.opacity(0.82))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(cardBackground)
    }

    private var statsGrid: some View {
        HStack(spacing: 14) {
            InfoCard(title: device.onlineTime, subtitle: "Online")
            InfoCard(title: device.dataUsage, subtitle: "Datenverbrauch")
        }
    }

    private var controlsCard: some View {
        VStack(spacing: 16) {
            cardTitle("Steuerung", icon: "switch.2")

            settingsToggle(title: "Kindersicherung", subtitle: "Zusätzlicher Schutz für dieses Gerät.", isOn: $parentalControl)
            settingsToggle(title: "Gerät priorisieren", subtitle: "Bevorzugt dieses Gerät im Netzwerk.", isOn: $prioritized)
            settingsToggle(title: "Zeitbeschränkung", subtitle: "Schränkt die Nutzung auf feste Zeiten ein.", isOn: $timeLimitEnabled)

            if timeLimitEnabled {
                VStack(spacing: 12) {
                    HStack {
                        Text("Von")
                            .foregroundColor(.white)
                        Spacer()
                        DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .tint(Color(red: 0.35, green: 0.75, blue: 0.9))
                            .colorScheme(.dark)
                    }

                    HStack {
                        Text("Bis")
                            .foregroundColor(.white)
                        Spacer()
                        DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .tint(Color(red: 0.35, green: 0.75, blue: 0.9))
                            .colorScheme(.dark)
                    }

                    Text("Internet verboten von \(startTime.formatted(date: .omitted, time: .shortened)) bis \(endTime.formatted(date: .omitted, time: .shortened))")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(14)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding()
        .background(cardBackground)
    }

    private var blocklistCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            cardTitle("Blocklist", icon: "shield.lefthalf.filled")

            VStack(alignment: .leading, spacing: 8) {
                Text(effectiveBlocklist.hasActiveRules ? effectiveBlocklist.summaryText : "Keine Regeln aktiv")
                    .font(.headline)
                    .foregroundColor(.white)

                Text(hasOwnBlocklist ? "Individuelle Abweichung nur für dieses Gerät." : "Kommt live von der Gruppe. Bearbeiten erstellt nur für dieses Gerät eine Abweichung.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
            }

            Button {
                showBlocklistSheet = true
            } label: {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                    Text("Blocklist bearbeiten")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .font(.headline.weight(.semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(Color(red: 0.35, green: 0.75, blue: 0.9))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            Button {
                resetToGroupBlocklist()
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Auf Gruppe zurücksetzen")
                    Spacer()
                }
                .font(.headline.weight(.semibold))
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding()
        .background(cardBackground)
    }

    private var presetsHintCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "slider.horizontal.3")
                .foregroundColor(.cyan)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text("Presets")
                    .font(.headline)
                    .foregroundColor(.white)

                Text("Speichere komplette Geräteeinstellungen inklusive eigener Blocklist und wende sie später mit einem Tap an.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.72))
            }

            Spacer()
        }
        .padding(14)
        .background(cardBackground)
    }

    private var presetsPage: some View {
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

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        VStack(spacing: 12) {
                            Button {
                                showCreatePresetSheet = true
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "plus")

                                    Text("Aktuelle Einstellungen als Preset speichern")
                                        .multilineTextAlignment(.leading)

                                    Spacer(minLength: 0)
                                }
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color(red: 0.35, green: 0.75, blue: 0.9))
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                            }
                            .buttonStyle(.plain)
                        }

                        VStack(alignment: .leading, spacing: 14) {
                            if presets.isEmpty {
                                VStack(spacing: 10) {
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.55))

                                    Text("Noch keine Presets gespeichert")
                                        .foregroundColor(.white.opacity(0.72))
                                        .font(.subheadline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 28)
                                .background(cardBackground)
                            } else {
                                ForEach(presets) { preset in
                                    presetRow(preset)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showCreatePresetSheet) {
            PresetEditorSheet(
                title: "Neues Preset",
                confirmLabel: "Preset speichern",
                initialName: "",
                subtitle: "Speichert die aktuellen Einstellungen inklusive eigener Blocklist."
            ) { name in
                saveCurrentAsPreset(named: name)
            }
        }
        .sheet(item: $presetToEdit) { preset in
            PresetEditorSheet(
                title: "Preset bearbeiten",
                confirmLabel: "Preset aktualisieren",
                initialName: preset.name,
                subtitle: "Name ändern und mit den aktuellen Einstellungen überschreiben."
            ) { newName in
                updatePreset(preset, withName: newName)
            }
        }
    }

    private func presetRow(_ preset: DevicePreset) -> some View {
        let isActive = isActivePreset(preset)

        return HStack(alignment: .top, spacing: 14) {
            Button {
                applyPreset(preset)
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text(preset.name)
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)

                        if isActive {
                            Text("Aktiv")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.14))
                                .clipShape(Capsule())
                        }
                    }

                    HStack(spacing: 8) {
                        presetTag(title: preset.parentalControl ? "Kindersicherung an" : "Kindersicherung aus", tint: .cyan)

                        if preset.prioritized {
                            presetTag(title: "Priorisiert", tint: .yellow)
                        }

                        if preset.blocklist.hasActiveRules {
                            presetTag(title: "Blocklist", tint: .green)
                        }
                    }

                    if preset.timeLimitEnabled {
                        Text("Zeitlimit: \(preset.startTime.formatted(date: .omitted, time: .shortened)) – \(preset.endTime.formatted(date: .omitted, time: .shortened))")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.68))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            VStack(spacing: 12) {
                Button {
                    presetToEdit = preset
                } label: {
                    Image(systemName: "pencil")
                        .foregroundColor(.white.opacity(0.86))
                }

                Button(role: .destructive) {
                    deletePreset(preset)
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(isActive ? Color.white.opacity(0.28) : Color.clear, lineWidth: 1.5)
        )
    }

    private func settingsToggle(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.headline)

                Text(subtitle)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.68))
            }

            Spacer(minLength: 12)

            Toggle("", isOn: isOn)
                .toggleStyle(SwitchToggleStyle(tint: .cyan))
                .labelsHidden()
        }
        .padding(14)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func cardTitle(_ text: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.cyan)
            Text(text)
                .font(.headline)
                .foregroundColor(.white)
            Spacer()
        }
    }

    private func presetTag(title: String, tint: Color) -> some View {
        Text(title)
            .font(.caption2.weight(.semibold))
            .foregroundColor(.white.opacity(0.70))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color.white.opacity(0.07))
            .clipShape(Capsule())
    }

    private func isActivePreset(_ preset: DevicePreset) -> Bool {
        preset.parentalControl == parentalControl &&
        preset.prioritized == prioritized &&
        preset.timeLimitEnabled == timeLimitEnabled &&
        hasOwnBlocklist &&
        preset.blocklist == deviceBlocklist &&
        (!preset.timeLimitEnabled || (
            Calendar.current.component(.hour, from: preset.startTime) == Calendar.current.component(.hour, from: startTime) &&
            Calendar.current.component(.minute, from: preset.startTime) == Calendar.current.component(.minute, from: startTime) &&
            Calendar.current.component(.hour, from: preset.endTime) == Calendar.current.component(.hour, from: endTime) &&
            Calendar.current.component(.minute, from: preset.endTime) == Calendar.current.component(.minute, from: endTime)
        ))
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 22)
            .fill(Color(red: 0.1, green: 0.15, blue: 0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }

    private func loadSettings() {
        let settings = NetheraStorage.deviceSettings(for: device.id)
        parentalControl = settings.parentalControl
        prioritized = settings.prioritized
        timeLimitEnabled = settings.timeLimitEnabled
        startTime = settings.startTime
        endTime = settings.endTime
        deviceBlocklist = settings.blocklist
        hasOwnBlocklist = settings.hasOwnBlocklist
    }

    private func persistSettings() {
        NetheraStorage.saveDeviceSettings(currentSettings, for: device.id)
    }

    private func refreshPresets() {
        presets = NetheraStorage.loadPresets()
    }

    private func saveCurrentAsPreset(named name: String) {
        var existing = NetheraStorage.loadPresets()
        existing.insert(
            DevicePreset(
                name: name,
                group: nil,
                parentalControl: parentalControl,
                prioritized: prioritized,
                timeLimitEnabled: timeLimitEnabled,
                startTime: startTime,
                endTime: endTime,
                blocklist: effectiveBlocklist
            ),
            at: 0
        )
        NetheraStorage.savePresets(existing)
        presets = existing
    }

    private func updatePreset(_ preset: DevicePreset, withName newName: String) {
        var existing = NetheraStorage.loadPresets()
        guard let index = existing.firstIndex(where: { $0.id == preset.id }) else { return }

        existing[index].name = newName
        existing[index].group = nil
        existing[index].parentalControl = parentalControl
        existing[index].prioritized = prioritized
        existing[index].timeLimitEnabled = timeLimitEnabled
        existing[index].startTime = startTime
        existing[index].endTime = endTime
        existing[index].blocklist = effectiveBlocklist

        NetheraStorage.savePresets(existing)
        presets = existing
    }

    private func applyPreset(_ preset: DevicePreset) {
        if isActivePreset(preset) {
            resetToGroupBlocklist()
        } else {
            parentalControl = preset.parentalControl
            prioritized = preset.prioritized
            timeLimitEnabled = preset.timeLimitEnabled
            startTime = preset.startTime
            endTime = preset.endTime
            deviceBlocklist = preset.blocklist
            hasOwnBlocklist = true
            persistSettings()
        }
    }

    private func resetToGroupBlocklist() {
        // Löscht nur die extra Einstellungen von diesem Gerät.
        // Danach wird wieder live die aktuelle Gruppen-Blocklist verwendet.
        parentalControl = true
        prioritized = false
        timeLimitEnabled = false
        startTime = Date()
        endTime = Date()
        deviceBlocklist = BlocklistProfile()
        hasOwnBlocklist = false
        persistSettings()
        refreshGroupBlocklistToken = UUID()
    }

    private func deletePreset(_ preset: DevicePreset) {
        var existing = NetheraStorage.loadPresets()
        existing.removeAll { $0.id == preset.id }
        NetheraStorage.savePresets(existing)
        withAnimation {
            presets = existing
        }
    }
}

#Preview {
    NavigationStack {
        DeviceDetailView(
            device: .constant(Device(
                id: UUID(),
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
