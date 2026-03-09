//
//  SettingsChoiceView.swift
//  Nethera
//
//  Created by Deniz Bernecker on 09.03.26.
//

import SwiftUI

struct SettingsChoiceView: View {
    
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
                
                VStack(spacing: 20) {
                    
                    // Router Einstellungen
                    NavigationLink(destination: SettingsView()) {
                        ChoiceCard(title: "Router-Einstellungen", subtitle: "Netzwerk & WLAN")
                    }
                    
                    // Konto Einstellungen
                    NavigationLink(destination: AccountView()) {
                        ChoiceCard(title: "Kontoeinstellungen", subtitle: "Profil & Sicherheit")
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Einstellungen")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

// Wiederverwendbare Card
struct ChoiceCard: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title3)
                .bold()
                .foregroundColor(.white)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.white.opacity(0.12))
        .cornerRadius(26)
    }
}

#Preview {
    SettingsChoiceView()
}
