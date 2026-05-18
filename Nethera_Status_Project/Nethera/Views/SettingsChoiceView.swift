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
                        Color(red: 0.06, green: 0.22, blue: 0.28),
                        Color(red: 0.02, green: 0.03, blue: 0.08)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 14) {
                  

                    GeometryReader { geometry in
                        let spacing: CGFloat = 14
                        let verticalInset: CGFloat = 18
                        let cardHeight = (geometry.size.height - spacing - verticalInset) / 2

                        VStack(spacing: spacing) {
                            NavigationLink(destination: SettingsView()) {
                                SettingsChoiceCard(
                                    icon: "wifi.router",
                                    title: "Router-Einstellungen",
                                    subtitle: "Netzwerk, WLAN und Sicherheit",
                                    accentColor: Color.cyan.opacity(0.85)
                                )
                                .frame(maxHeight: .infinity)
                            }
                            .buttonStyle(.plain)
                            .frame(height: cardHeight)

                            NavigationLink(destination: AccountView()) {
                                SettingsChoiceCard(
                                    icon: "person.crop.circle",
                                    title: "Kontoeinstellungen",
                                    subtitle: "Profil, Passwort und Account",
                                    accentColor: Color.mint.opacity(0.85)
                                )
                                .frame(maxHeight: .infinity)
                            }
                            .buttonStyle(.plain)
                            .frame(height: cardHeight)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
    }
}

struct SettingsChoiceCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 0)

            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.22))
                    .frame(width: 64, height: 64)

                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(spacing: 6) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.78))
                    .multilineTextAlignment(.center)
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.22), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    SettingsChoiceView()
}
