//
//  AccountView.swift
//  Nethera
//
//  Created by Deniz Bernecker on 09.03.26.
//

import SwiftUI

struct AccountView: View {
    
    // MARK: Editable State
    @State private var name = "Max Mustermann"
    @State private var email = "max@nethera.com"
    @State private var phone = "+43 123 456789"
    @State private var password = "••••••••"
    
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
                        
                        // MARK: Profil
                        SectionCard(title: "Profil") {
                            EditableTextRow(icon: "person.crop.circle", label: "Name", text: $name)
                            EditableTextRow(icon: "envelope", label: "E-Mail", text: $email)
                            EditableTextRow(icon: "phone", label: "Telefon", text: $phone)
                            EditableSecureRow(icon: "lock", label: "Passwort", text: $password)
                            SettingRow(icon: "calendar", label: "Geburtsdatum", value: "01.01.1990", isEditable: false)
                        }
                        
                        // MARK: Sicherheit
                        SectionCard(title: "Sicherheit") {
                            SettingRow(icon: "shield.lefthalf.fill", label: "2FA", value: "aktiviert", isEditable: false)
                            SettingRow(icon: "key", label: "API-Zugriff", value: "deaktiviert", isEditable: false)
                        }
                        
                        // MARK: Kontoverwaltung
                        SectionCard(title: "Kontoverwaltung") {
                            SettingRow(icon: "power", label: "Konto deaktivieren", value: "", isEditable: false)
                            SettingRow(icon: "trash", label: "Konto löschen", value: "", isEditable: false)
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
