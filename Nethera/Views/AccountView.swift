//
//  AccountView.swift
//  Nethera
//
//  Created by Deniz Bernecker on 09.03.26.
//
import SwiftUI

struct AccountView: View {
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
                        
                        SectionCard(title: "Profil") {
                            SettingRow(icon: "person.crop.circle", label: "Name", value: "Max Mustermann")
                            SettingRow(icon: "envelope", label: "E-Mail", value: "max@nethera.com")
                            SettingRow(icon: "phone", label: "Telefon", value: "+43 123 456789")
                            SettingRow(icon: "calendar", label: "Geburtsdatum", value: "01.01.1990")
                        }
                        
                        SectionCard(title: "Sicherheit") {
                            SettingRow(icon: "lock", label: "Passwort ändern", value: "••••••••")
                            SettingRow(icon: "shield.lefthalf.fill", label: "2FA", value: "aktiviert")
                            SettingRow(icon: "key", label: "API-Zugriff", value: "deaktiviert")
                        }
                        
                        SectionCard(title: "Kontoverwaltung") {
                            SettingRow(icon: "power", label: "Konto deaktivieren", value: "")
                            SettingRow(icon: "trash", label: "Konto löschen", value: "")
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding()
                }
            }
            .navigationTitle("Konto")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

#Preview {
    AccountView()
}
