//
//  SettingsView.swift
//  Nethera
//
//  Created by Deniz Bernecker on 09.03.26.
//

import SwiftUI

struct SettingsView: View {
    
    @State private var wifiName = "Nethera"
    @State private var password = "27N!G?4"
    @State private var guestPassword = "0N-Gast0"
    
    @State private var notifications = true
    @State private var darkMode = true
    
    @State private var frequency = "5 GHz"
    @State private var firewall = true

    @State private var savedWifiName = "Nethera"
    @State private var savedPassword = "27N!G?4"
    @State private var savedGuestPassword = "0N-Gast0"
    @State private var savedNotifications = true
    @State private var savedDarkMode = true
    @State private var savedFrequency = "5 GHz"
    @State private var savedFirewall = true
    @State private var showSavedMessage = false

    private var hasUnsavedChanges: Bool {
        wifiName != savedWifiName ||
        password != savedPassword ||
        guestPassword != savedGuestPassword ||
        notifications != savedNotifications ||
        darkMode != savedDarkMode ||
        frequency != savedFrequency ||
        firewall != savedFirewall
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
                        PageHeaderView(title: "Router-Einstellungen", showBackButton: true) {
                            Button {
                                saveSettings()
                            } label: {
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
                            Text("Einstellungen gespeichert")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(Color(red: 0.35, green: 0.75, blue: 0.9))
                        }
                        
                        VStack(spacing: 20) {
                            SectionCard(title: "Basis Einstellungen") {
                                
                                EditableTextRow(icon: "wifi", label: "WLAN-Name", text: $wifiName)
                                EditableSecureRow(icon: "lock", label: "Passwort", text: $password)
                                EditableSecureRow(icon: "person.2", label: "Gastnetz (PW)", text: $guestPassword)
                                ToggleRow(icon: "bell", label: "Meldungen", isOn: $notifications)
                                ToggleRow(icon: "moon.fill", label: "Darkmode", isOn: $darkMode)
                                
                                SettingRow(icon: "network", label: "Modell", value: "Nethera-7x9", isEditable: false)
                                SettingRow(icon: "gearshape", label: "Version", value: "Nv.1.0.1.2", isEditable: false)
                            }
                            
                            // Erweiterte Einstellungen
                            SectionCard(title: "Erweiterte Einstellungen") {
                                
                                PickerRow(icon: "dot.radiowaves.left.and.right", label: "Frequenz", selection: $frequency, options: ["2.4 GHz", "5 GHz", "Auto"])
                                ToggleRow(icon: "shield", label: "Firewall", isOn: $firewall)
                                
                                SettingRow(icon: "arrow.triangle.2.circlepath", label: "Firmware Update", value: "keins verfügbar", isEditable: true)
                                SettingRow(icon: "trash", label: "Reset", value: "Nie", isEditable: true)
                                SettingRow(icon: "network", label: "DNS-Konfiguration", value: "Automatisch", isEditable: true)
                                SettingRow(icon: "server.rack", label: "Proxy", value: "Nie", isEditable: true)
                                SettingRow(icon: "ipaddress", label: "IP-Adresse", value: "192.168.0.224", isEditable: false)
                                SettingRow(icon: "rectangle.3.offgrid", label: "Netzmaske", value: "255.255.255.0", isEditable: false)
                            }
                            
                            Spacer(minLength: 100)
                        }
                        .padding()
                    }
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            loadSettings()
        }
    }
    
    func saveSettings() {
        UserDefaults.standard.set(wifiName, forKey: "router.wifiName")
        UserDefaults.standard.set(password, forKey: "router.password")
        UserDefaults.standard.set(guestPassword, forKey: "router.guestPassword")
        UserDefaults.standard.set(notifications, forKey: "router.notifications")
        UserDefaults.standard.set(darkMode, forKey: "router.darkMode")
        UserDefaults.standard.set(frequency, forKey: "router.frequency")
        UserDefaults.standard.set(firewall, forKey: "router.firewall")

        savedWifiName = wifiName
        savedPassword = password
        savedGuestPassword = guestPassword
        savedNotifications = notifications
        savedDarkMode = darkMode
        savedFrequency = frequency
        savedFirewall = firewall

        showSavedMessage = true

        print("Einstellungen gespeichert:")
        print("WLAN-Name: \(wifiName)")
        print("Passwort: \(password)")
        print("Gastnetz: \(guestPassword)")
        print("Meldungen: \(notifications)")
        print("Darkmode: \(darkMode)")
        print("Frequenz: \(frequency)")
        print("Firewall: \(firewall)")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            showSavedMessage = false
        }
    }

    func loadSettings() {
        let loadedWifiName = UserDefaults.standard.string(forKey: "router.wifiName") ?? wifiName
        let loadedPassword = UserDefaults.standard.string(forKey: "router.password") ?? password
        let loadedGuestPassword = UserDefaults.standard.string(forKey: "router.guestPassword") ?? guestPassword
        let loadedFrequency = UserDefaults.standard.string(forKey: "router.frequency") ?? frequency

        wifiName = loadedWifiName
        password = loadedPassword
        guestPassword = loadedGuestPassword
        notifications = UserDefaults.standard.object(forKey: "router.notifications") as? Bool ?? notifications
        darkMode = UserDefaults.standard.object(forKey: "router.darkMode") as? Bool ?? darkMode
        frequency = loadedFrequency
        firewall = UserDefaults.standard.object(forKey: "router.firewall") as? Bool ?? firewall

        savedWifiName = wifiName
        savedPassword = password
        savedGuestPassword = guestPassword
        savedNotifications = notifications
        savedDarkMode = darkMode
        savedFrequency = frequency
        savedFirewall = firewall
    }
}

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

struct SettingRow: View {
    let icon: String
    let label: String
    let value: String
    var isEditable: Bool = true
    
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
                .foregroundColor(isEditable ? .white.opacity(0.9) : .white.opacity(0.6))
                .font(.system(size: 18))
        }
        .padding(10)
        .background(isEditable ? Color.white.opacity(0.15) : Color.clear)
        .cornerRadius(12)
    }
}

struct EditableTextRow: View {
    let icon: String
    let label: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 30)
            
            Text(label)
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .bold))
            
            Spacer()
            
            TextField("", text: $text)
                .multilineTextAlignment(.trailing)
                .foregroundColor(.white)
        }
        .padding(10)
        .background(Color.white.opacity(0.15))
        .cornerRadius(12)
    }
}

struct EditableSecureRow: View {
    let icon: String
    let label: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 30)
            
            Text(label)
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .bold))
            
            Spacer()
            
            SecureField("", text: $text)
                .multilineTextAlignment(.trailing)
                .foregroundColor(.white)
        }
        .padding(10)
        .background(Color.white.opacity(0.15))
        .cornerRadius(12)
    }
}

struct ToggleRow: View {
    let icon: String
    let label: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 30)
                
                Text(label)
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .bold))
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: .teal))
        .padding(10)
        .background(Color.white.opacity(0.15))
        .cornerRadius(12)
    }
}

struct PickerRow: View {
    let icon: String
    let label: String
    @Binding var selection: String
    let options: [String]
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 30)
            
            Text(label)
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .bold))
            
            Spacer()
            
            Picker("", selection: $selection) {
                ForEach(options, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.menu)
            .tint(.white)
        }
        .padding(10)
        .background(Color.white.opacity(0.15))
        .cornerRadius(12)
    }
}

#Preview {
    SettingsView()
}

