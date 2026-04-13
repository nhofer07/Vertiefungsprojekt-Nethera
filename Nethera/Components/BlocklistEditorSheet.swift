import SwiftUI

struct BlocklistEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let subtitle: String
    let initialProfile: BlocklistProfile
    let onSave: (BlocklistProfile) -> Void

    @State private var profile: BlocklistProfile
    @State private var newDomain = ""

    init(
        title: String,
        subtitle: String,
        initialProfile: BlocklistProfile,
        onSave: @escaping (BlocklistProfile) -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.initialProfile = initialProfile
        self.onSave = onSave
        _profile = State(initialValue: initialProfile)
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

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        VStack(spacing: 8) {
                            Text(title)
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.72))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 8)

                        packageCard
                        manualDomainsCard
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        onSave(profile)
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .presentationDragIndicator(.visible)
    }

    private var packageCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Empfohlene Listen")
                .font(.headline)
                .foregroundColor(.white)

            packageToggle(
                title: "Glücksspiel",
                subtitle: "Sperrt bekannte Wett- und Casino-Websites.",
                isOn: $profile.gamblingEnabled
            )

            packageToggle(
                title: "18+ Inhalte",
                subtitle: "Sperrt bekannte Adult-Seiten und ähnliche Inhalte.",
                isOn: $profile.adultEnabled
            )

            packageToggle(
                title: "Social Media",
                subtitle: "Blockiert klassische Social-Media-Plattformen.",
                isOn: $profile.socialEnabled
            )
        }
        .padding(18)
        .background(cardBackground)
    }

    private var manualDomainsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Manuelle Domains")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Text(profile.manualDomains.isEmpty ? "Keine" : "\(profile.manualDomains.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.75))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Capsule())
            }

            Text("Beispiel: example.com — ohne https://")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.68))

            HStack(spacing: 10) {
                TextField(
                    "example.com",
                    text: $newDomain,
                    prompt: Text("example.com").foregroundColor(.white.opacity(0.45))
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                Button {
                    addDomain()
                } label: {
                    Image(systemName: "plus")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(Color(red: 0.35, green: 0.75, blue: 0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }

            if profile.manualDomains.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "shield")
                        .foregroundColor(.white.opacity(0.55))
                    Text("Noch keine eigenen Domains hinterlegt.")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.subheadline)
                    Spacer()
                }
                .padding(.vertical, 8)
            } else {
                VStack(spacing: 10) {
                    ForEach(profile.manualDomains, id: \.self) { domain in
                        HStack(spacing: 12) {
                            Image(systemName: "nosign")
                                .foregroundColor(.white.opacity(0.75))

                            Text(domain)
                                .foregroundColor(.white)
                                .font(.subheadline.weight(.medium))

                            Spacer()

                            Button {
                                profile.manualDomains.removeAll { $0 == domain }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red.opacity(0.9))
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
        }
        .padding(18)
        .background(cardBackground)
    }

    private func packageToggle(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.68))
            }

            Spacer(minLength: 12)

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(.cyan)
        }
        .padding(14)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 22)
            .fill(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }

    private func addDomain() {
        let domain = newDomain
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !domain.isEmpty else { return }
        guard !profile.manualDomains.contains(domain) else {
            newDomain = ""
            return
        }

        profile.manualDomains.insert(domain, at: 0)
        newDomain = ""
    }
}
