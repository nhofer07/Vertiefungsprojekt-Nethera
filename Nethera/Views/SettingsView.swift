//
//  SettingsView.swift
//  Nethera
//
//  Created by Deniz Bernecker on 09.03.26.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.05, green: 0.2, blue: 0.25), Color.black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        SectionCard(title: "Basis Einstellungen") {
                            SettingRow(icon: "wifi", label: "WLAN-Name", value: "Nethera")
                            SettingRow(icon: "lock", label: "Passwort", value: "27N!G?4")
                            SettingRow(icon: "person.2", label: "Gastnetz Passwort", value: "0N-Gast0")
                            SettingRow(icon: "bell", label: "Meldungen", value: "aktiv")
                            SettingRow(icon: "globe", label: "Sprache", value: "standard")
                            SettingRow(icon: "moon.fill", label: "Darkmode", value: "aktiv")
                            SettingRow(icon: "network", label: "Modell", value: "Nethera-7x9")
                            SettingRow(icon: "gearshape", label: "Version", value: "Nv.1.0.1.2")
                        }
                        
                        SectionCard(title: "Erweiterte Einstellungen") {
                            SettingRow(icon: "dot.radiowaves.left.and.right", label: "Frequenz", value: "5 Ghz")
                            SettingRow(icon: "shield", label: "Firewall", value: "aktiv")
                            SettingRow(icon: "arrow.triangle.2.circlepath", label: "Firmware Update", value: "keins verfügbar")
                            SettingRow(icon: "trash", label: "Reset", value: "Nie")
                            SettingRow(icon: "network", label: "DNS-Konfiguration", value: "Automatisch")
                            SettingRow(icon: "server.rack", label: "Proxy", value: "Nie")
                            SettingRow(icon: "ipaddress", label: "IP-Adresse", value: "192.168.0.224")
                            SettingRow(icon: "rectangle.3.offgrid", label: "Netzmaske", value: "255.255.255.0")
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding()
                }
            }
            .navigationTitle("Einstellungen")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

// Wiederverwendbare SectionCard
struct SectionCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3)
                .bold()
                .foregroundColor(.white)
            
            VStack(spacing: 10) {
                content
            }
            .padding()
            .background(.white.opacity(0.08))
            .cornerRadius(26)
        }
    }
}

// Einzelne Zeile
struct SettingRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 30)
            Text(label)
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .bold))
            Spacer()
            Text(value)
                .foregroundColor(.white.opacity(0.9))
                .font(.system(size: 18))
        }
    }
}

#Preview {
    SettingsView()
}
