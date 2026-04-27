//
//  AdBlockDashboardView.swift
//  Nethera
//
//  Created by Deniz Bernecker on 08.03.26.
//

import Foundation

import SwiftUI

struct AdBlockDashboardView: View {
    // dummydaten:
    @State private var blockedDomains = [
        BlockedDomain(name: "googleads.g.doubleclick.net", time: "2m"),
        BlockedDomain(name: "connect.facebook.com", time: "4m"),
        BlockedDomain(name: "stats.g.doubleclick.net", time: "17m"),
        BlockedDomain(name: "adservice.google.com", time: "29m")
    ]
    
    @State private var newBlockedDomain = ""

    
    // neue domain holen:
    private func addBlockedDomain() {
        let sanitized = newBlockedDomain
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !sanitized.isEmpty else { return }
        guard !blockedDomains.contains(where: { $0.name == sanitized }) else {
            newBlockedDomain = ""
            return
        }

        blockedDomains.insert(BlockedDomain(name: sanitized, time: "jetzt"), at: 0)
        newBlockedDomain = ""
    }
    
    var body: some View {
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
            
            VStack(spacing: 10) {
                PageHeaderView(title: "Geblockte Werbung", showBackButton: true)
                
                VStack(spacing: 20) {
                    statsRow
                    blockedDomainsCard
                    SingleStatBoxCard
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                Spacer()
                
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    var statsRow: some View {
        HStack(spacing: 16) {
            StatBox(
                icon: "shield.fill",
                number: "138",
                subtitle: "Heute geblockt:"
            )
            
            StatBox(
                icon: "chart.bar.fill",
                number: "12,4K",
                subtitle: "Gesamt geblockt:"
            )
        }
    }
    
    var blockedDomainsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            HStack(spacing: 8) {
                Image(systemName: "globe")
                    .foregroundColor(.white.opacity(0.9))
                Text("Zuletzt geblockte Domains:")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            // alle domains zeigen:
            VStack(spacing: 12) {
                ForEach(blockedDomains) { domain in
                    DomainRow(name: domain.name, time: domain.time)
                }
            }

            VStack(spacing: 10) {
                Text("Gib eine Domain ein, z. B. example.com (ohne https://).")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)

                // textfeld mit newBlockedDomain als "class":
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

                Button {
                    addBlockedDomain()
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
            .buttonStyle(.plain)
        }
        .padding()
        .background(.white.opacity(0.08))
        .cornerRadius(24)
    }
    

    struct BlockedDomain: Identifiable {
        let id = UUID()
        let name: String
        let time: String
    }
    var SingleStatBoxCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SingleStatBox(
                icon: "checkmark.shield.fill",
                text: "Sie haben 97% aller Anfragen blockiert!"
            )
        }
        .padding()
        .background(.white.opacity(0.08))
        .cornerRadius(24)
    }
    
   
    
}


// Wiederverwendbare Structs:

// Glasbox mit Info:

struct StatBox: View {
    let icon: String
    let number: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Image(systemName: icon)
                .foregroundColor(.white)
            
            Text(number)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.footnote)
                .multilineTextAlignment(.leading)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.white.opacity(0.1))
        .cornerRadius(22)
    }
}

// Reihe in der Liste der geblockten Domains:

struct DomainRow: View {
    let name: String
    let time: String
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "nosign")
                    .foregroundColor(.white.opacity(0.85))
                Text(name)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .font(.title3)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "clock")
                Text(time)
            }
            .foregroundColor(.white.opacity(0.7))
        }
        .font(.subheadline)
    }
}

struct SingleStatBox: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            
            Spacer()
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 42))
                
                Text(text)
                    .font(.system(size: 22, weight: .bold))
            }
            .foregroundColor(.white)
            
            Spacer()
        }
        .frame(maxWidth: 400)
        .padding()
        .background(.white.opacity(0.1))
        .cornerRadius(22)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    AdBlockDashboardView()
}
