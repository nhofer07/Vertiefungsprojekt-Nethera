import SwiftUI

struct BlacklistDashboardView: View {
    @State private var showBlacklistDetails = false
    @State private var globalBlocklist = NetheraBackend.globalBlocklist()
    @State private var newBlockedDomain = ""

    private var activePackageCount: Int {
        globalBlocklist.enabledPackageCount
    }

    private func addManualDomain() {
        let sanitized = newBlockedDomain
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !sanitized.isEmpty else { return }
        guard !globalBlocklist.manualDomains.contains(sanitized) else {
            newBlockedDomain = ""
            return
        }

        globalBlocklist.manualDomains.insert(sanitized, at: 0)
        newBlockedDomain = ""
        saveGlobalBlocklist()
    }

    private func deleteManualDomain(_ domain: String) {
        globalBlocklist.manualDomains.removeAll { $0 == domain }
        saveGlobalBlocklist()
    }

    private func saveGlobalBlocklist() {
        NetheraBackend.saveGlobalBlocklist(globalBlocklist)
    }

    private func reloadGlobalBlocklist() {
        globalBlocklist = NetheraBackend.globalBlocklist()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                dashboardBackground

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        PageHeaderView(title: "Blocklist", showBackButton: true, outerHorizontalPadding: 0)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Blocklist")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            Text("Domain-Sperren gelten für das gesamte Netzwerk.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.68))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                        .background(dashboardCardBackground)

                        statsRow
                        manualDomainsCard
                        blacklistPackagesCard

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
            reloadGlobalBlocklist()
        }
        .onReceive(NotificationCenter.default.publisher(for: .netheraBackendDidRefresh)) { _ in
            reloadGlobalBlocklist()
        }
        .onReceive(NotificationCenter.default.publisher(for: .globalBlocklistDidChange)) { _ in
            reloadGlobalBlocklist()
        }
        .onChange(of: globalBlocklist.gamblingEnabled) { _ in
            saveGlobalBlocklist()
        }
        .onChange(of: globalBlocklist.adultEnabled) { _ in
            saveGlobalBlocklist()
        }
        .onChange(of: globalBlocklist.socialEnabled) { _ in
            saveGlobalBlocklist()
        }
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            BlacklistStatCard(number: "\(globalBlocklist.manualDomains.count)", subtitle: "Individuelle Sperren")
            BlacklistStatCard(number: "\(activePackageCount)", subtitle: "Pakete aktiv")
        }
    }

    private var manualDomainsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Manuell blockierte Domains")
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 10) {
                if globalBlocklist.manualDomains.isEmpty {
                    Text("Noch keine Domains gesperrt.")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white.opacity(0.62))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                } else {
                    ForEach(globalBlocklist.manualDomains, id: \.self) { domain in
                        BlacklistDomainRow(name: domain) {
                            deleteManualDomain(domain)
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
                    addManualDomain()
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

    private var blacklistPackagesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showBlacklistDetails.toggle()
                }
            } label: {
                HStack {
                    Text("Vorgefertigte Listen")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)

                    Spacer()

                    Image(systemName: showBlacklistDetails ? "chevron.down" : "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white.opacity(0.50))
                }
            }
            .buttonStyle(.plain)

            if showBlacklistDetails {
                VStack(spacing: 10) {
                    ExpandableBlacklistRow(
                        title: "Glücksspiele",
                        domains: "bet365.com, bwin.com, tipico.de, win2day.at, royalvegas.com...",
                        moreCount: 43,
                        isOn: $globalBlocklist.gamblingEnabled
                    )

                    ExpandableBlacklistRow(
                        title: "18+ Inhalte",
                        domains: "pornhub.com, youporn.com, brazzers.com, susi.live, onlyfans.com...",
                        moreCount: 213,
                        isOn: $globalBlocklist.adultEnabled
                    )

                    ExpandableBlacklistRow(
                        title: "Social-Media",
                        domains: "facebook.com, instagram.com, tiktok.com, snapchat.com, x.com...",
                        moreCount: 13,
                        isOn: $globalBlocklist.socialEnabled
                    )
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(dashboardCardBackground)
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

private struct BlacklistStatCard: View {
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

private struct BlacklistDomainRow: View {
    let name: String
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Text(name)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
                .lineLimit(1)

            Spacer()

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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct ExpandableBlacklistRow: View {
    let title: String
    let domains: String
    let moreCount: Int
    @Binding var isOn: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)

                Spacer()

                Toggle("", isOn: $isOn)
                    .tint(Color(red: 0.35, green: 0.75, blue: 0.9))
                    .labelsHidden()
            }

            Text("\(domains) + \(moreCount) weitere")
                .font(.caption)
                .foregroundColor(.white.opacity(0.62))
                .lineLimit(2)
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    BlacklistDashboardView()
}
