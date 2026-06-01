import SwiftUI

struct PresetsView: View {
    @State private var presets: [DevicePreset] = []
    @State private var showCreateSheet = false
    @State private var presetToEdit: DevicePreset?
    @State private var swipedPresetID: UUID?

    var body: some View {
        NavigationStack {
            ZStack {
                background

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Zentrale Vorlagen")
                                .font(.title2.bold())
                                .foregroundColor(.white)

                            Text("Erstelle hier Vorlagen und wende sie später auf der Geräte-Detailseite mit einem Tap an.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.72))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)

                        Button {
                            showCreateSheet = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                Text("Preset erstellen")
                                    .font(.headline.weight(.semibold))
                                Spacer()
                            }
                            .foregroundColor(.black)
                            .padding(16)
                            .background(Color(red: 0.35, green: 0.75, blue: 0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)

                        if presets.isEmpty {
                            emptyCard
                                .padding(.horizontal, 20)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(presets) { preset in
                                    presetCard(preset)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 28)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear(perform: loadPresets)
            .onReceive(NotificationCenter.default.publisher(for: .netheraBackendDidRefresh)) { _ in
                loadPresets()
            }
            .sheet(isPresented: $showCreateSheet) {
                PresetFormSheet(mode: .create) { preset in
                    presets.insert(preset, at: 0)
                    NetheraBackend.savePresets(presets)
                }
            }
            .sheet(item: $presetToEdit) { preset in
                PresetFormSheet(mode: .edit(preset)) { updatedPreset in
                    guard let index = presets.firstIndex(where: { $0.id == preset.id }) else { return }
                    presets[index] = updatedPreset
                    NetheraBackend.savePresets(presets)
                }
            }
        }
    }

    private var emptyCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "slider.horizontal.3")
                .font(.largeTitle)
                .foregroundColor(.white.opacity(0.55))

            Text("Noch keine Presets")
                .font(.headline)
                .foregroundColor(.white)

            Text("Tippe auf „Preset erstellen“, um eine Vorlage für Kindersicherung, Priorisierung, Zeitlimit und Blocklist anzulegen.")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.68))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(22)
        .background(cardBackground)
    }

    private func presetCard(_ preset: DevicePreset) -> some View {
        let isOpen = swipedPresetID == preset.id

        return ZStack(alignment: .trailing) {
            HStack(spacing: 0) {
                Button {
                    swipedPresetID = nil
                    presetToEdit = preset
                } label: {
                    swipeActionContent(icon: "pencil", title: "Bearbeiten", background: Color.white.opacity(0.14))
                }
                .buttonStyle(.plain)

                Button(role: .destructive) {
                    swipedPresetID = nil
                    deletePreset(preset)
                } label: {
                    swipeActionContent(icon: "trash.fill", title: "Löschen", background: Color.red.opacity(0.72))
                }
                .buttonStyle(.plain)
            }
            .frame(width: 184)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.cyan)
                        .padding(.top, 2)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(preset.name)
                            .font(.headline)
                            .foregroundColor(.white)

                        Text(summary(for: preset))
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.68))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()
                }

                HStack(spacing: 8) {
                    miniTag(preset.parentalControl ? "Kindersicherung" : "Ohne Schutz")
                    if preset.prioritized { miniTag("Priorisiert") }
                    if preset.timeLimitEnabled { miniTag("Zeitlimit") }
                    if preset.blocklist.hasActiveRules { miniTag("Blocklist") }
                }
            }
            .padding(16)
            .background(cardBackground)
            .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .offset(x: isOpen ? -184 : 0)
            .animation(.spring(response: 0.30, dampingFraction: 0.88), value: swipedPresetID)
            .onTapGesture {
                if isOpen {
                    swipedPresetID = nil
                } else {
                    presetToEdit = preset
                }
            }
            .gesture(
                DragGesture(minimumDistance: 18)
                    .onEnded { value in
                        let horizontal = value.translation.width
                        let vertical = abs(value.translation.height)
                        guard abs(horizontal) > vertical else { return }

                        if horizontal < -42 {
                            swipedPresetID = preset.id
                        } else if horizontal > 32, isOpen {
                            swipedPresetID = nil
                        }
                    }
            )
        }
        .clipped()
    }

    private func swipeActionContent(icon: String, title: String, background: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
            Text(title)
                .font(.caption2.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .foregroundColor(.white.opacity(0.96))
        .frame(width: 92)
        .frame(maxHeight: .infinity)
        .background(background)
    }

    private func miniTag(_ text: String) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundColor(.white.opacity(0.78))
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.08))
            .clipShape(Capsule())
    }

    private func summary(for preset: DevicePreset) -> String {
        var parts: [String] = []
        if preset.timeLimitEnabled {
            parts.append("Zeit: \(preset.startTime.formatted(date: .omitted, time: .shortened))–\(preset.endTime.formatted(date: .omitted, time: .shortened))")
        }
        if preset.blocklist.hasActiveRules {
            parts.append(preset.blocklist.summaryText)
        }
        if parts.isEmpty {
            return "Standard-Vorlage ohne Zeitlimit und ohne Blocklist."
        }
        return parts.joined(separator: " • ")
    }

    private func loadPresets() {
        presets = NetheraBackend.loadPresets()
    }

    private func deletePreset(_ preset: DevicePreset) {
        withAnimation {
            presets.removeAll { $0.id == preset.id }
        }
        NetheraBackend.savePresets(presets)
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(red: 0.08, green: 0.18, blue: 0.22),
                Color(red: 0.02, green: 0.02, blue: 0.05)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 22)
            .fill(Color(red: 0.1, green: 0.15, blue: 0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

private struct PresetFormSheet: View {
    enum Mode {
        case create
        case edit(DevicePreset)

        var title: String {
            switch self {
            case .create: return "Preset erstellen"
            case .edit: return "Preset bearbeiten"
            }
        }

        var buttonTitle: String {
            switch self {
            case .create: return "Preset speichern"
            case .edit: return "Änderungen speichern"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss

    let mode: Mode
    let onSave: (DevicePreset) -> Void

    @State private var name = ""
    @State private var parentalControl = true
    @State private var prioritized = false
    @State private var timeLimitEnabled = false
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var blocklist = BlocklistProfile()
    @State private var newDomain = ""

    init(mode: Mode, onSave: @escaping (DevicePreset) -> Void) {
        self.mode = mode
        self.onSave = onSave

        if case .edit(let preset) = mode {
            _name = State(initialValue: preset.name)
            _parentalControl = State(initialValue: preset.parentalControl)
            _prioritized = State(initialValue: preset.prioritized)
            _timeLimitEnabled = State(initialValue: preset.timeLimitEnabled)
            _startTime = State(initialValue: preset.startTime)
            _endTime = State(initialValue: preset.endTime)
            _blocklist = State(initialValue: preset.blocklist)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                background

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Name")
                                .font(.headline)
                                .foregroundColor(.white)

                            TextField("z.B. Schulzeit", text: $name, prompt: Text("z.B. Schulzeit").foregroundColor(.white.opacity(0.45)))
                                .foregroundColor(.white)
                                .padding(14)
                                .background(Color.white.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(16)
                        .background(cardBackground)

                        VStack(spacing: 12) {
                            settingsToggle(title: "Kindersicherung", subtitle: "Schutz für das Gerät aktivieren.", isOn: $parentalControl)
                            settingsToggle(title: "Gerät priorisieren", subtitle: "Gerät im Netzwerk bevorzugen.", isOn: $prioritized)
                            settingsToggle(title: "Zeitbeschränkung", subtitle: "Nutzung auf bestimmte Uhrzeiten begrenzen.", isOn: $timeLimitEnabled)

                            if timeLimitEnabled {
                                HStack {
                                    Text("Von")
                                        .foregroundColor(.white)
                                    Spacer()
                                    DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                }

                                HStack {
                                    Text("Bis")
                                        .foregroundColor(.white)
                                    Spacer()
                                    DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                }
                            }
                        }
                        .padding(16)
                        .background(cardBackground)

                        blocklistEditor

                        Button {
                            save()
                        } label: {
                            Text(mode.buttonTitle)
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color(red: 0.35, green: 0.75, blue: 0.9))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding()
                }
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
        .presentationDragIndicator(.visible)
    }

    private var blocklistEditor: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Blocklist")
                .font(.headline)
                .foregroundColor(.white)

            settingsToggle(title: "Glücksspiel", subtitle: "Bekannte Wett- und Casino-Seiten sperren.", isOn: $blocklist.gamblingEnabled)
            settingsToggle(title: "18+ Inhalte", subtitle: "Adult-Seiten und ähnliche Inhalte sperren.", isOn: $blocklist.adultEnabled)
            settingsToggle(title: "Social Media", subtitle: "Klassische Social-Media-Plattformen blockieren.", isOn: $blocklist.socialEnabled)

            HStack(spacing: 10) {
                TextField("example.com", text: $newDomain, prompt: Text("example.com").foregroundColor(.white.opacity(0.45)))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                Button {
                    addDomain()
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.black)
                        .frame(width: 42, height: 42)
                        .background(Color(red: 0.35, green: 0.75, blue: 0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }

            ForEach(blocklist.manualDomains, id: \.self) { domain in
                HStack {
                    Text(domain)
                        .foregroundColor(.white)
                    Spacer()
                    Button {
                        blocklist.manualDomains.removeAll { $0 == domain }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.65))
                    }
                }
                .font(.subheadline)
                .padding(12)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    private func settingsToggle(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.68))
            }

            Spacer()

            Toggle("", isOn: isOn)
                .toggleStyle(SwitchToggleStyle(tint: .cyan))
                .labelsHidden()
        }
        .padding(12)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func addDomain() {
        let trimmed = newDomain
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "/", with: "")

        guard !trimmed.isEmpty, !blocklist.manualDomains.contains(trimmed) else { return }
        blocklist.manualDomains.append(trimmed)
        newDomain = ""
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let id: UUID
        let isEnabled: Bool
        if case .edit(let preset) = mode {
            id = preset.id
            isEnabled = preset.isEnabled
        } else {
            id = UUID()
            isEnabled = false
        }

        let preset = DevicePreset(
            id: id,
            name: trimmedName,
            isEnabled: isEnabled,
            group: nil,
            parentalControl: parentalControl,
            prioritized: prioritized,
            timeLimitEnabled: timeLimitEnabled,
            startTime: startTime,
            endTime: endTime,
            blocklist: blocklist
        )

        onSave(preset)
        dismiss()
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(red: 0.08, green: 0.18, blue: 0.22),
                Color(red: 0.02, green: 0.02, blue: 0.05)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 22)
            .fill(Color(red: 0.1, green: 0.15, blue: 0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

#Preview {
    PresetsView()
}
