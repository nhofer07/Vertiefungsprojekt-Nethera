//
//  AccountView.swift
//  Nethera
//
//  Created by Deniz Bernecker on 09.03.26.
//

import SwiftUI

struct AccountView: View {
    
    // unsere Muster-Variablen + neuen gespeicherten:
    
    // MARK: Editable State
    @State private var name = "Max Mustermann"
    @State private var email = "max@nethera.com"
    @State private var phone = "+43 123 456789"
    @State private var password = "••••••••"

    @State private var savedName = "Max Mustermann"
    @State private var savedEmail = "max@nethera.com"
    @State private var savedPhone = "+43 123 456789"
    @State private var savedPassword = "••••••••"
    @State private var showSavedMessage = false

    
    
    // unsaved check:
    
    private var hasUnsavedChanges: Bool {
        name != savedName ||
        email != savedEmail ||
        phone != savedPhone ||
        password != savedPassword
    }
    
    
    
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
                        PageHeaderView(title: "Konto", showBackButton: true) {
                            Button {
                                saveAccountSettings()
                            } label: {
                                // check ob man speichern muss:
                                Image(systemName: hasUnsavedChanges ? "checkmark.circle.fill" : "checkmark.circle")
                                    .font(.title2.weight(.bold))
                                    .foregroundColor(hasUnsavedChanges ? Color(red: 0.35, green: 0.75, blue: 0.9) : .white.opacity(0.45))
                                    .frame(width: 30, height: 30)
                                    .background(Color.white.opacity(hasUnsavedChanges ? 0.14 : 0.08))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            .disabled(!hasUnsavedChanges)
                        }

                        if showSavedMessage {
                            Text("Kontodaten gespeichert")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(Color(red: 0.35, green: 0.75, blue: 0.9))
                        }
                        
                        // alle Felder, die man so sieht:
                        
                        VStack(spacing: 20) {
                            // MARK: Profil
                            SectionCard(title: "Profil") {
                                EditableTextRow(icon: "person.crop.circle", label: "Name", text: $name)
                                EditableTextRow(icon: "envelope", label: "E-Mail", text: $email)
                                EditableTextRow(icon: "phone", label: "Telefon", text: $phone)
                                EditableSecureRow(icon: "lock", label: "Passwort", text: $password)
                                SettingRow(icon: "calendar", label: "Geburtsdatum", value: "01.01.1990", isEditable: false)
                            }
                            
                            // Sicherheit
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
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear {
            loadAccountSettings()
        }
    }

    
    // saven:
    
    private func saveAccountSettings() {
        UserDefaults.standard.set(name, forKey: "account.name")
        UserDefaults.standard.set(email, forKey: "account.email")
        UserDefaults.standard.set(phone, forKey: "account.phone")
        UserDefaults.standard.set(password, forKey: "account.password")

        savedName = name
        savedEmail = email
        savedPhone = phone
        savedPassword = password

        showSavedMessage = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            showSavedMessage = false
        }
    }

    // neuen anzeigen beim nächsten mal:
    private func loadAccountSettings() {
        name = UserDefaults.standard.string(forKey: "account.name") ?? name
        email = UserDefaults.standard.string(forKey: "account.email") ?? email
        phone = UserDefaults.standard.string(forKey: "account.phone") ?? phone
        password = UserDefaults.standard.string(forKey: "account.password") ?? password

        savedName = name
        savedEmail = email
        savedPhone = phone
        savedPassword = password
    }
}

#Preview {
    AccountView()
}
