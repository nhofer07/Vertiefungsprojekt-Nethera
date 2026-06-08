//
//  AccountView.swift
//  Nethera
//
//  Created by Deniz Bernecker on 09.03.26.
//

import SwiftUI

struct AccountView: View {
    var showBackButton = true

    @StateObject private var authentication = AuthenticationManager()
    
    // unsere Muster-Variablen + neuen gespeicherten:
    
    // MARK: Editable State
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var birthDate = ""
    @State private var isLoggedIn = false
    @State private var authMode = ""

    @State private var savedName = ""
    @State private var savedEmail = ""
    @State private var savedPhone = ""
    @State private var savedPassword = ""
    @State private var savedBirthDate = ""
    @State private var savedIsLoggedIn = false
    @State private var savedAuthMode = ""
    @State private var showSavedMessage = false
    @State private var authMessage = ""
    @State private var showDeleteConfirmation = false

    
    
    // unsaved check:
    
    private var hasUnsavedChanges: Bool {
        name != savedName ||
        email != savedEmail ||
        phone != savedPhone ||
        password != savedPassword ||
        birthDate != savedBirthDate ||
        isLoggedIn != savedIsLoggedIn ||
        authMode != savedAuthMode
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
                        PageHeaderView(title: "Konto", showBackButton: showBackButton) {
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
                            SectionCard(title: "Sitzung", icon: "person.badge.key") {
                                HStack(spacing: 12) {
                                    Image(systemName: isLoggedIn ? "checkmark.seal.fill" : "person.badge.key.fill")
                                        .font(.headline.weight(.bold))
                                        .foregroundColor(isLoggedIn ? .black : .white)
                                        .frame(width: 34, height: 34)
                                        .background(isLoggedIn ? Color(red: 0.45, green: 0.83, blue: 0.62) : Color.white.opacity(0.12))
                                        .clipShape(Circle())

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(isLoggedIn ? "Aktiv" : "Nicht angemeldet")
                                            .font(.headline.weight(.semibold))
                                            .foregroundColor(.white)

                                        Text(isLoggedIn ? "Dein Konto ist mit Nethera verbunden." : "Melde dich über das Login-Fenster an.")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.66))
                                    }

                                    Spacer()
                                }
                                .padding(12)
                                .background(Color.white.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                                if isLoggedIn {
                                    AccountActionButton(
                                        title: "Abmelden",
                                        icon: "rectangle.portrait.and.arrow.right",
                                        foregroundColor: .white,
                                        backgroundColor: Color.white.opacity(0.08),
                                        borderColor: Color.white.opacity(0.14)
                                    ) {
                                        logout()
                                    }
                                } else {
                                    Text("Melde dich über das Login-Fenster an.")
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(.white.opacity(0.66))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }

                                if !authMessage.isEmpty {
                                    Text(authMessage)
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(Color(red: 0.35, green: 0.75, blue: 0.9))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }

                            // MARK: Profil
                            SectionCard(title: "Profil") {
                                EditableTextRow(icon: "person.crop.circle", label: "Name", text: $name)
                                EditableTextRow(icon: "envelope", label: "E-Mail", text: $email)
                                EditableTextRow(icon: "phone", label: "Telefon", text: $phone)
                                AccountPasswordRow(authentication: authentication, password: $password)

                                SettingRow(icon: "calendar", label: "Geburtsdatum", value: birthDate, isEditable: false)
                            }
                            
                            // MARK: Kontoverwaltung
                            SectionCard(title: "Kontoverwaltung") {
                                AccountActionButton(
                                    title: "Konto löschen",
                                    icon: "trash",
                                    foregroundColor: .white,
                                    backgroundColor: Color(red: 0.95, green: 0.27, blue: 0.27).opacity(0.9)
                                ) {
                                    showDeleteConfirmation = true
                                }
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
            NetheraBackend.refreshFromMongoDB()
        }
        .onReceive(NotificationCenter.default.publisher(for: .netheraBackendDidRefresh)) { _ in
            loadAccountSettings()
        }
        .onReceive(NotificationCenter.default.publisher(for: .accountSettingsDidChange)) { _ in
            loadAccountSettings()
        }
        .alert("Konto wirklich löschen?", isPresented: $showDeleteConfirmation) {
            Button("Abbrechen", role: .cancel) { }
            Button("Konto löschen", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("Deine Kontodaten werden aus der Datenbank entfernt und du wirst abgemeldet.")
        }
    }

    
    // saven:
    
    private func saveAccountSettings() {
        let settings = NetheraBackend.AccountSettings(
            name: name,
            email: email,
            phone: phone,
            password: password,
            birthDate: birthDate,
            twoFactorStatus: "",
            apiAccessStatus: "",
            isLoggedIn: isLoggedIn,
            authMode: authMode
        )

        NetheraBackend.saveAccountSettings(settings)

        savedName = name
        savedEmail = email
        savedPhone = phone
        savedPassword = password
        savedBirthDate = birthDate
        savedIsLoggedIn = isLoggedIn
        savedAuthMode = authMode

        showSavedMessage = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            showSavedMessage = false
        }
    }

    private func logout() {
        isLoggedIn = false
        authMode = "Abgemeldet"
        authMessage = "Abgemeldet und in der Datenbank gespeichert"
        saveAccountSettings()
    }

    private func deleteAccount() {
        NetheraBackend.deleteAccountSettings()

        name = ""
        email = ""
        phone = ""
        password = ""
        birthDate = ""
        isLoggedIn = false
        authMode = ""

        savedName = ""
        savedEmail = ""
        savedPhone = ""
        savedPassword = ""
        savedBirthDate = ""
        savedIsLoggedIn = false
        savedAuthMode = ""
    }

    // neuen anzeigen beim nächsten mal:
    private func loadAccountSettings() {
        let settings = NetheraBackend.loadAccountSettings()

        name = settings.name
        email = settings.email
        phone = settings.phone
        password = settings.password
        birthDate = settings.birthDate
        isLoggedIn = settings.isLoggedIn
        authMode = settings.authMode

        savedName = name
        savedEmail = email
        savedPhone = phone
        savedPassword = password
        savedBirthDate = birthDate
        savedIsLoggedIn = isLoggedIn
        savedAuthMode = authMode
    }
}

#Preview {
    AccountView()
}

private struct AccountPasswordRow: View {
    @ObservedObject var authentication: AuthenticationManager
    @Binding var password: String

    var body: some View {
        if authentication.isUnlocked {
            EditableTextRow(icon: "lock.open", label: "Passwort", text: $password)
        } else {
            Button {
                authentication.unlock()
            } label: {
                HStack {
                    Image(systemName: "faceid")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color(red: 0.35, green: 0.75, blue: 0.9))
                        .frame(width: 30)

                    Text("Passwort")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))

                    Spacer()

                    Text("Anzeigen")
                        .foregroundColor(.white.opacity(0.62))
                        .font(.system(size: 15, weight: .semibold))

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white.opacity(0.45))
                }
                .padding(12)
                .background(Color.white.opacity(0.12))
                .cornerRadius(16)
            }
            .buttonStyle(.plain)
        }
    }
}

private struct AccountActionButton: View {
    let title: String
    let icon: String
    var foregroundColor: Color = .black
    var backgroundColor: Color = Color(red: 0.35, green: 0.75, blue: 0.9)
    var borderColor: Color = .clear
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption.weight(.bold))

                Text(title)
                    .font(.caption.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
