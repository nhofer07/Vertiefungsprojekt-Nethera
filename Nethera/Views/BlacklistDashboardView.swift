//
//  BlacklistDashboardView.swift
//  Nethera
//
//  Created by Deniz Bernecker on 08.03.26.
//

import Foundation


import SwiftUI

struct BlacklistDashboardView: View {
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

            VStack(spacing: 20) {
                
                blacklistCard
                
                ManageBlocklistButton
                
                domainListCard

                statsRow

            }
            .padding()
        }
    }
}

// MARK: Components

extension BlacklistDashboardView {

    var blacklistCard: some View {
        RoundedRectangle(cornerRadius: 26)
            .fill(.white.opacity(0.12))
            .frame(height: 100)
            .overlay(
                HStack(spacing: 20) {

                    Image(systemName: "list.bullet")
                        .font(.system(size: 32))
                        .foregroundColor(.white)

                    Text("Deine Blacklists")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)

                }
            )
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

            Button("hinzufügen") {}
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(.white.opacity(0.15))
                .cornerRadius(20)
                .foregroundColor(.white)

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
                subtitle: "Individuelle Sperren eingestellt"
            )

            StatMiniCard(
                icon: "arrow.down.circle",
                number: "3",
                subtitle: "Blacklist-Pakete aktiv"
            )
        }
    }
    
    
    var ManageBlocklistButton: some View {
        HStack(spacing: 16) {
            ManageBlocklists(
                icon: "puzzlepiece",
                text: "Blocklists verwalten"
            )
        }
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

struct ManageBlocklists: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            
            Spacer()
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 35))
                
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
