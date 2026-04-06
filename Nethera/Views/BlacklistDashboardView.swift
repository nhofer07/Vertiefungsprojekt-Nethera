//
//  BlacklistDashboardView.swift
//  Nethera
//
//  Created by Deniz Bernecker on 08.03.26.
//

import Foundation


import SwiftUI

private enum BlacklistTypography {
    static let sectionTitle: Font = .title3.weight(.semibold)
    static let rowTitle: Font = .subheadline.weight(.semibold)
    static let rowBody: Font = .subheadline
    static let statNumber: Font = .system(size: 30, weight: .bold)
    static let caption: Font = .caption
}

struct BlacklistDashboardView: View {
    @State private var showBlacklistDetails = false
    @State private var gamblingEnabled = true
    @State private var adultEnabled = true
    @State private var socialEnabled = true
    @State private var manualDomains = [
        "win2day.at",
        "htl-leonding.at",
        "edufs.edu.htl-leonding.at",
        "figma.com"
    ]
    @State private var newBlockedDomain = ""

    private func addManualDomain() {
        let sanitized = newBlockedDomain
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !sanitized.isEmpty else { return }
        guard !manualDomains.contains(sanitized) else {
            newBlockedDomain = ""
            return
        }

        manualDomains.insert(sanitized, at: 0)
        newBlockedDomain = ""
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.2, blue: 0.25),
                        Color.black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        PageHeaderView(title: "Blacklist", showBackButton: true)

                        VStack(spacing: 20) {
                            statsRow
                            manualDomainsCard
                            blacklistPackagesCard
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    

        private var blacklistPackagesCard: some View {
        VStack(spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showBlacklistDetails.toggle()
                }
            } label: {
                ZStack {
                    Text("Vorgefertigte Listen")
                        .font(BlacklistTypography.sectionTitle)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)

                    HStack {
                        Spacer()
                        Image(systemName: showBlacklistDetails ? "chevron.down" : "chevron.right")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)

            if showBlacklistDetails {
                VStack(spacing: 12) {
                    ExpandableBlacklistRow(
                        title: "Glücksspiele",
                        domains: "bet365.com, bwin.com, tipico.de, win2day.at, royalvegas.com...",
                        moreCount: 43,
                        isOn: $gamblingEnabled
                    )

                    ExpandableBlacklistRow(
                        title: "18+ Inhalte",
                        domains: "pornhub.com, youporn.com, brazzers.com, susi.live, onlyfans.com...",
                        moreCount: 213,
                        isOn: $adultEnabled
                    )

                    ExpandableBlacklistRow(
                        title: "Social-Media",
                        domains: "facebook.com, instagram.com, tiktok.com, snapchat.com, x.com...",
                        moreCount: 13,
                        isOn: $socialEnabled
                    )
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white.opacity(0.14))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
        )
        .cornerRadius(28)
    }
    
    private var manualDomainsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            Text("Manuell blockierte Domains:")
                .font(BlacklistTypography.sectionTitle)
                .foregroundColor(.white)

            manualDomainList
            manualDomainEntry
        }
        .padding()
        .background(.white.opacity(0.08))
        .cornerRadius(28)
    }

    private var manualDomainList: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(manualDomains, id: \.self) { domain in
                DomainItem(name: domain)
            }
        }
    }

    private var manualDomainEntry: some View {
        VStack(spacing: 10) {
            Text("Gib eine Domain ein, z. B. example.com (ohne https://).")
                .font(BlacklistTypography.caption)
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)

            domainTextField
            blockButton
        }
        .buttonStyle(.plain)
    }

    private var domainTextField: some View {
        TextField(
            "",
            text: $newBlockedDomain,
            prompt: Text("example.com").foregroundColor(.white.opacity(0.55))
        )
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .foregroundColor(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.12))
        .cornerRadius(12)
    }

    private var blockButton: some View {
        Button {
            addManualDomain()
        } label: {
            Text("Blockieren")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.35))
                )
        }
    }
    
    private var statsRow: some View {
        HStack(spacing: 16) {
            
            StatMiniCard(
                icon: "nosign",
                number: "\(manualDomains.count)",
                subtitle: "Individuelle Sperren"
            )
            
            StatMiniCard(
                icon: "list.bullet",
                number: "3",
                subtitle: "Blacklist-Pakete aktiv"
            )
        }
    }
    
    // Wiederverwendbare Structs:
    
    // ListenItem:
    
    struct DomainItem: View {
        let name: String
        
        var body: some View {
            HStack(spacing: 12) {
                
                Image(systemName: "nosign")
                    .foregroundColor(.white.opacity(0.8))
                
                Text(name)
                    .foregroundColor(.white)
                    .font(BlacklistTypography.rowBody.weight(.semibold))
                
                Spacer()
            }
            .font(.subheadline)
        }
    }
    
    // Glasfenster mit 3 Infos:
    
    struct StatMiniCard: View {
        let icon: String
        let number: String
        let subtitle: String
        
        var body: some View {
            VStack(spacing: 14) {
                
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                
                Text(number)
                    .font(BlacklistTypography.statNumber)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(BlacklistTypography.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
                
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.white.opacity(0.1))
            .cornerRadius(26)
        }
    }

    struct ExpandableBlacklistRow: View {
        let title: String
        let domains: String
        let moreCount: Int
        @Binding var isOn: Bool

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title)
                        .font(BlacklistTypography.rowTitle)
                        .foregroundColor(.white)

                    Spacer()

                    Toggle("", isOn: $isOn)
                        .tint(.blue)
                        .labelsHidden()
                }

                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.white.opacity(0.7))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Blockierte Domains:")
                            .font(BlacklistTypography.caption)
                            .foregroundColor(.white.opacity(0.8))

                        Text("\(domains) + \(moreCount) weitere")
                            .font(BlacklistTypography.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                            .truncationMode(.tail)
                    }
                }
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.14))
                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

#Preview {
    BlacklistDashboardView()
}
