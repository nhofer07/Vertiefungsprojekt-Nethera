//
//  BlacklistDashboardView.swift
//  Nethera
//
//  Created by Deniz Bernecker on 08.03.26.
//

import Foundation


import SwiftUI

struct BlacklistDashboardView: View {
    @State private var showBlacklistDetails = false
    @State private var gamblingEnabled = true
    @State private var adultEnabled = true
    @State private var socialEnabled = true

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
                            blacklistExpandableCard
                            domainListCard
                            statsRow
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
    


    var blacklistExpandableCard: some View {
        DisclosureGroup(isExpanded: $showBlacklistDetails) {
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
            .padding(.top, 8)
        } label: {
            HStack {
                Text("Blacklists anzeigen")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
        }
        .tint(.white)
        .padding(20)
        .background(.white.opacity(0.08))
        .cornerRadius(28)
    }
    
    var domainListCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            Text("Manuell blockierte Domains:")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 10) {
                DomainItem(name: "win2day.at")
                DomainItem(name: "htl-leonding.at")
                DomainItem(name: "edufs.edu.htl-leonding...")
                DomainItem(name: "figma.com")
            }
            
            NavigationLink(destination: AddDomainView()) {
                Text("Hinzufügen")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.blue.opacity(0.3))
                            .shadow(
                                color: Color.blue.opacity(0.3),
                                radius: 6,
                                x: 0,
                                y: 4
                            )
                    )
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(.white.opacity(0.08))
        .cornerRadius(28)
    }
    
    var statsRow: some View {
        HStack(spacing: 16) {
            
            StatMiniCard(
                icon: "arrow.down.circle",
                number: "7",
                subtitle: "Individuelle Sperren"
            )
            
            StatMiniCard(
                icon: "arrow.down.circle",
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
                    .font(.system(size: 22, weight: .bold))
                
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
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.footnote)
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
                        .font(.headline)
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
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))

                        Text("\(domains) + \(moreCount) weitere")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                            .truncationMode(.tail)
                    }
                }
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.08))
                .blur(radius: 1)
                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 4))
        }
    }
}

#Preview {
    BlacklistDashboardView()
}
