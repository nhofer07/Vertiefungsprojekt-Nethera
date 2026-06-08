import SwiftUI

struct AdBlockDashboardView: View {
    @State private var blockedDomains = NetheraBackend.adBlockDomains()
    @State private var stats = NetheraBackend.loadAdBlockStats()
    @State private var newBlockedDomain = ""

    private func addBlockedDomain() {
        let sanitized = newBlockedDomain
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !sanitized.isEmpty else { return }
        guard !blockedDomains.contains(where: { $0.name == sanitized }) else {
            newBlockedDomain = ""
            return
        }

        blockedDomains.insert(AdBlockDomain(name: sanitized, time: "jetzt"), at: 0)
        newBlockedDomain = ""
        saveBlockedDomains()
    }

    private func deleteBlockedDomain(_ domain: AdBlockDomain) {
        blockedDomains.removeAll { $0.id == domain.id }
        saveBlockedDomains()
    }

    private func saveBlockedDomains() {
        NetheraBackend.saveAdBlockDomains(blockedDomains)
    }

    private func reloadBlockedDomains() {
        blockedDomains = NetheraBackend.adBlockDomains()
        stats = NetheraBackend.loadAdBlockStats()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                dashboardBackground

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        PageHeaderView(title: "Geblockte Werbung", showBackButton: true, outerHorizontalPadding: 0)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("AdBlock")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            Text("Werbe- und Trackingfilter gelten für das gesamte Netzwerk.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.68))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                        .background(dashboardCardBackground)

                        statsRow
                        blockedDomainsCard
                        protectionCard

                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            NetheraBackend.refreshFromMongoDB()
            reloadBlockedDomains()
        }
        .onReceive(NotificationCenter.default.publisher(for: .netheraBackendDidRefresh)) { _ in
            reloadBlockedDomains()
        }
        .onReceive(NotificationCenter.default.publisher(for: .adBlockDomainsDidChange)) { _ in
            reloadBlockedDomains()
        }
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            AdBlockStatCard(number: display(stats.blockedToday), subtitle: "Heute geblockt")
            AdBlockStatCard(number: display(stats.blockedTotal), subtitle: "Gesamt geblockt")
        }
    }

    private var blockedDomainsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Zuletzt geblockte Domains")
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)

            VStack(spacing: 10) {
                if blockedDomains.isEmpty {
                    Text("Noch keine Domains geblockt.")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white.opacity(0.62))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                } else {
                    ForEach(blockedDomains) { domain in
                        AdBlockDomainRow(name: domain.name, time: domain.time) {
                            deleteBlockedDomain(domain)
                        }
                    }
                }
            }

            VStack(spacing: 10) {
                Text("Gib eine Domain ein, z. B. example.com (ohne https://).")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.68))
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextField(
                    "",
                    text: $newBlockedDomain,
                    prompt: Text("example.com").foregroundColor(.white.opacity(0.50))
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                Button {
                    addBlockedDomain()
                } label: {
                    Text("Blockieren")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(red: 0.35, green: 0.75, blue: 0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(dashboardCardBackground)
    }

    private var protectionCard: some View {
        HStack(spacing: 14) {
            Text(display(stats.blockedPercent))
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 3) {
                Text("Anfragen blockiert")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)

                Text("Basierend auf den aktuellen Filterregeln.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.62))
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(dashboardCardBackground)
    }

    private func display(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Keine Daten" : value
    }

    private var dashboardBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 0.04, green: 0.11, blue: 0.15),
                Color(red: 0.03, green: 0.04, blue: 0.07),
                Color.black
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var dashboardCardBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(Color.white.opacity(0.07))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.16), radius: 12, x: 0, y: 6)
    }
}

private struct AdBlockStatCard: View {
    let number: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(number)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(subtitle)
                .font(.caption.weight(.semibold))
                .foregroundColor(.white.opacity(0.66))
        }
        .frame(maxWidth: .infinity, minHeight: 82, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

private struct AdBlockDomainRow: View {
    let name: String
    let time: String
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Text(name)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
                .lineLimit(1)

            Spacer()

            Text(time)
                .font(.caption.weight(.semibold))
                .foregroundColor(.white.opacity(0.58))

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white.opacity(0.64))
                    .frame(width: 26, height: 26)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(name) löschen")
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    AdBlockDashboardView()
}
