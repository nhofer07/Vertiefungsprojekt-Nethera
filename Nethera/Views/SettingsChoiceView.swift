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
                    colors: [Color(red: 0.05, green: 0.2, blue: 0.25), Color.black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    HStack {
                        Text("Einstellungen")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white.opacity(0.08))
                            .blur(radius: 2)
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                    )
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 20)
                    
                    GeometryReader { geometry in
                        let totalHeight = geometry.size.height
                        let tabBarHeight: CGFloat = 75
                        let spacing: CGFloat = 12
                        let cardHeight = (totalHeight - tabBarHeight - spacing) / 2
                        
                        VStack(spacing: spacing) {
                            NavigationLink(destination: SettingsView()) {
                                DashboardCard(icon: "wifi", title: "Router-Einstellungen", subtitle: "Netzwerk & WLAN")
                                    .frame(height: cardHeight)
                            }
                            
                            Spacer(minLength: 5)
                            
                            NavigationLink(destination: AccountView()) {
                                DashboardCard(icon: "person.crop.circle", title: "Kontoeinstellungen", subtitle: "Profil & Sicherheit")
                                    .frame(height: cardHeight)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.bottom, tabBarHeight)
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
    }
}

struct DashboardCard: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.white.opacity(0.9))
            
            Text(title)
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white.opacity(0.08))
                .blur(radius: 2)
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        )
    }
}

#Preview {
    SettingsChoiceView()
}
