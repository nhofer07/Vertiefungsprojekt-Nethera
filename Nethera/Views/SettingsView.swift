//
//  SettingsView.swift
//  Nethera
//
//  Created by Deniz Bernecker on 09.03.26.
//

import SwiftUI
import UIKit

struct SettingsView: View {
    @StateObject private var authentication = AuthenticationManager()
    @StateObject private var notificationManager = NotificationManager.shared

    @State private var wifiName = ""
    @State private var password = ""
    @State private var guestPassword = ""

    @State private var notifications = false
    @State private var frequency = ""
    @State private var firewall = false
    @State private var model = ""
    @State private var version = ""
    @State private var firmwareUpdate = ""
    @State private var dnsConfiguration = ""
    @State private var proxy = ""
    @State private var ipAddress = ""
    @State private var netmask = ""
    @State private var savedWifiName = ""
    @State private var savedPassword = ""
    @State private var savedGuestPassword = ""
    @State private var savedNotifications = false
    @State private var savedFrequency = ""
    @State private var savedFirewall = false
    @State private var savedModel = ""
    @State private var savedVersion = ""
    @State private var savedFirmwareUpdate = ""
    @State private var savedDnsConfiguration = ""
    @State private var savedProxy = ""
    @State private var savedIpAddress = ""
    @State private var savedNetmask = ""
    @State private var showSavedMessage = false
    @State private var qrImage: UIImage?
    @State private var notificationDebugTapCount = 0
    @State private var showNotificationTests = false

    private let qrGenerator = WiFiQRCodeGenerator()
    private let accentColor = Color(red: 0.35, green: 0.75, blue: 0.9)

    private var hasUnsavedChanges: Bool {
        wifiName != savedWifiName ||
        password != savedPassword ||
        guestPassword != savedGuestPassword ||
        notifications != savedNotifications ||
        frequency != savedFrequency ||
        firewall != savedFirewall ||
        model != savedModel ||
        version != savedVersion ||
        firmwareUpdate != savedFirmwareUpdate ||
        dnsConfiguration != savedDnsConfiguration ||
        proxy != savedProxy ||
        ipAddress != savedIpAddress ||
        netmask != savedNetmask
    }

    var body: some View {
        ZStack {
            settingsBackground

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    PageHeaderView(title: "Router-Einstellungen", showBackButton: true) {
                        Button {
                            saveSettings()
                        } label: {
                            Image(systemName: hasUnsavedChanges ? "checkmark.circle.fill" : "checkmark.circle")
                                .font(.title2.weight(.bold))
                                .foregroundColor(hasUnsavedChanges ? accentColor : .white.opacity(0.45))
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
                            .foregroundColor(accentColor)
                    }

                    VStack(spacing: 18) {
                        SettingsHeroCard(isUnlocked: authentication.isUnlocked, notificationsEnabled: notifications)

                        SectionCard(title: "Basis", icon: "wifi") {

                            EditableTextRow(icon: "wifi", label: "WLAN-Name", text: $wifiName)
                            SettingRow(icon: "network", label: "Modell", value: model, isEditable: false)
                            SettingRow(icon: "gearshape", label: "Version", value: version, isEditable: false)
                        }

                        SectionCard(title: "Sensible Routerdaten", icon: "lock.shield") {
                            SensitiveAccessCard(authentication: authentication)

                            if authentication.isUnlocked {
                                EditableTextRow(icon: "lock.open", label: "Router-Passwort", text: $password)
                                EditableTextRow(icon: "person.2", label: "Gastnetz-PW", text: $guestPassword)
                            } else {
                                LockedSensitiveRow(icon: "lock", label: "Router-Passwort")
                                LockedSensitiveRow(icon: "person.2", label: "Gastnetz-PW")
                            }
                        }

                        SectionCard(title: "Gast-WLAN", icon: "qrcode") {
                            GuestWiFiShareCard(
                                ssid: wifiName + " Guest",
                                password: guestPassword,
                                qrImage: qrImage,
                                isUnlocked: authentication.isUnlocked
                            )
                        }

                        SectionCard(title: "Mitteilungen", icon: "bell.badge") {
                            ToggleRow(icon: "bell", label: "Meldungen", isOn: $notifications)
                                .onChange(of: notifications) {
                                    notificationManager.automaticWarningsEnabled = notifications
                                    if notifications {
                                        notificationManager.requestPermission()
                                    }
                                }

                            NotificationPermissionRow(notificationManager: notificationManager)
                                .onTapGesture {
                                    revealNotificationTestsIfNeeded()
                                }

                            if showNotificationTests {
                                NotificationTestPanel(notificationManager: notificationManager)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }

                        SectionCard(title: "Netzwerk", icon: "slider.horizontal.3") {
                            FrequencyRow(selection: $frequency)
                            ToggleRow(icon: "shield", label: "Firewall", isOn: $firewall)
                            SettingRow(icon: "network", label: "DNS", value: dnsConfiguration, isEditable: false)
                            SettingRow(icon: "server.rack", label: "Proxy", value: proxy, isEditable: false)
                            SettingRow(icon: "number.circle", label: "IP-Adresse", value: ipAddress, isEditable: false)
                            SettingRow(icon: "rectangle.3.offgrid", label: "Netzmaske", value: netmask, isEditable: false)
                        }

                        SectionCard(title: "System", icon: "arrow.triangle.2.circlepath") {
                            SettingRow(icon: "arrow.triangle.2.circlepath", label: "Firmware Update", value: firmwareUpdate, isEditable: false)
                        }

                        Spacer(minLength: 100)
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .clipped()
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSettings()
            notificationManager.refreshAuthorizationStatus()
            makeGuestQRCode()
        }
        .onChange(of: wifiName) {
            makeGuestQRCode()
        }
        .onChange(of: guestPassword) {
            makeGuestQRCode()
        }
        .onReceive(NotificationCenter.default.publisher(for: .netheraBackendDidRefresh)) { _ in
            loadSettings()
            makeGuestQRCode()
        }
    }

    private var settingsBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.12, blue: 0.15),
                    Color(red: 0.02, green: 0.03, blue: 0.07),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(accentColor.opacity(0.13))
                .frame(width: 230, height: 230)
                .blur(radius: 72)
                .offset(x: 150, y: -260)

            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 180, height: 180)
                .blur(radius: 70)
                .offset(x: -150, y: 320)
        }
    }

    // Bündelt alle editierbaren Router-Felder in einem Backend-Update.
    func saveSettings() {
        let wasFirewallEnabled = savedFirewall
        let currentSettings = NetheraBackend.loadRouterSettings()

        let settings = NetheraBackend.RouterSettings(
            wifiName: wifiName,
            password: password,
            guestPassword: guestPassword,
            notifications: notifications,
            darkMode: currentSettings.darkMode,
            frequency: frequency,
            firewall: firewall,
            model: model,
            version: version,
            firmwareUpdate: firmwareUpdate,
            resetStatus: currentSettings.resetStatus,
            dnsConfiguration: dnsConfiguration,
            proxy: proxy,
            ipAddress: ipAddress,
            netmask: netmask
        )

        NetheraBackend.saveRouterSettings(settings)
        notificationManager.automaticWarningsEnabled = notifications
        notificationManager.handleFirewallChange(wasEnabled: wasFirewallEnabled, isEnabled: firewall)

        savedWifiName = wifiName
        savedPassword = password
        savedGuestPassword = guestPassword
        savedNotifications = notifications
        savedFrequency = frequency
        savedFirewall = firewall
        savedModel = model
        savedVersion = version
        savedFirmwareUpdate = firmwareUpdate
        savedDnsConfiguration = dnsConfiguration
        savedProxy = proxy
        savedIpAddress = ipAddress
        savedNetmask = netmask
        showSavedMessage = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            showSavedMessage = false
        }
    }

    func loadSettings() {
        let settings = NetheraBackend.loadRouterSettings()

        wifiName = settings.wifiName
        password = settings.password
        guestPassword = settings.guestPassword
        notifications = settings.notifications
        frequency = settings.frequency
        firewall = settings.firewall
        model = settings.model
        version = settings.version
        firmwareUpdate = settings.firmwareUpdate
        dnsConfiguration = settings.dnsConfiguration
        proxy = settings.proxy
        ipAddress = settings.ipAddress
        netmask = settings.netmask

        savedWifiName = wifiName
        savedPassword = password
        savedGuestPassword = guestPassword
        savedNotifications = notifications
        savedFrequency = frequency
        savedFirewall = firewall
        savedModel = model
        savedVersion = version
        savedFirmwareUpdate = firmwareUpdate
        savedDnsConfiguration = dnsConfiguration
        savedProxy = proxy
        savedIpAddress = ipAddress
        savedNetmask = netmask
        notificationManager.automaticWarningsEnabled = notifications
    }

    private func makeGuestQRCode() {
        qrImage = qrGenerator.makeQRCode(
            ssid: wifiName + " Guest",
            password: guestPassword,
            encryption: "WPA"
        )
    }

    private func revealNotificationTestsIfNeeded() {
        notificationDebugTapCount += 1

        if notificationDebugTapCount >= 2 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                showNotificationTests.toggle()
            }
            notificationDebugTapCount = 0
        }
    }
}

struct SectionCard<Content: View>: View {
    let title: String
    let icon: String?
    let content: Content

    init(title: String, icon: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(spacing: 9) {
                if let icon {
                    Image(systemName: icon)
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(Color(red: 0.35, green: 0.75, blue: 0.9))
                        .frame(width: 28, height: 28)
                        .background(Color.white.opacity(0.10))
                        .clipShape(Circle())
                }

                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)
            }

            VStack(spacing: 10) {
                content
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 7)
        )
    }
}

struct SettingsHeroCard: View {
    let isUnlocked: Bool
    let notificationsEnabled: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "wifi.router.fill")
                .font(.title2.weight(.semibold))
                .foregroundColor(.black)
                .frame(width: 48, height: 48)
                .background(Color(red: 0.35, green: 0.75, blue: 0.9))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 8) {
                Text("Nethera Router")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    statusBadge(
                        text: isUnlocked ? "Entsperrt" : "Geschützt",
                        icon: isUnlocked ? "lock.open.fill" : "lock.fill",
                        tint: isUnlocked ? Color(red: 0.45, green: 0.83, blue: 0.62) : Color(red: 0.95, green: 0.71, blue: 0.3)
                    )

                    statusBadge(
                        text: notificationsEnabled ? "Meldungen an" : "Meldungen aus",
                        icon: notificationsEnabled ? "bell.badge.fill" : "bell.slash.fill",
                        tint: Color(red: 0.35, green: 0.75, blue: 0.9)
                    )
                }
            }

            Spacer()
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.14), Color.white.opacity(0.06)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    private func statusBadge(text: String, icon: String, tint: Color) -> some View {
        Label(text, systemImage: icon)
            .font(.caption.weight(.bold))
            .foregroundColor(.white)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(tint.opacity(0.22))
            .clipShape(Capsule())
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
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Color(red: 0.35, green: 0.75, blue: 0.9))
                .frame(width: 30)

            Text(label)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .semibold))

            Spacer()

            Text(value)
                .foregroundColor(isEditable ? .white.opacity(0.9) : .white.opacity(0.6))
                .font(.system(size: 16, weight: .medium))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(12)
        .background(isEditable ? Color.white.opacity(0.12) : Color.white.opacity(0.045))
        .cornerRadius(16)
    }
}

struct EditableTextRow: View {
    let icon: String
    let label: String
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Color(red: 0.35, green: 0.75, blue: 0.9))
                .frame(width: 30)

            Text(label)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .semibold))

            Spacer()

            TextField("", text: $text)
                .multilineTextAlignment(.trailing)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))
        }
        .padding(12)
        .background(Color.white.opacity(0.12))
        .cornerRadius(16)
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
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color(red: 0.35, green: 0.75, blue: 0.9))
                    .frame(width: 30)

                Text(label)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.35, green: 0.75, blue: 0.9)))
        .padding(12)
        .background(Color.white.opacity(0.12))
        .cornerRadius(16)
    }
}

struct FrequencyRow: View {
    @Binding var selection: String

    private let options = ["2.4 GHz", "5 GHz", "Auto"]
    private let accentColor = Color(red: 0.35, green: 0.75, blue: 0.9)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(accentColor)
                    .frame(width: 30)

                Text("Frequenz")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))

                Spacer()
            }

            HStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button {
                        selection = option
                    } label: {
                        Text(option)
                            .font(.caption.weight(.bold))
                            .foregroundColor(selection == option ? .black : .white.opacity(0.72))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                            .background(selection == option ? accentColor : Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.12))
        .cornerRadius(16)
    }
}

struct SensitiveAccessCard: View {
    @ObservedObject var authentication: AuthenticationManager

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: authentication.isUnlocked ? "lock.open.fill" : "faceid")
                .font(.title3.weight(.semibold))
                .foregroundColor(authentication.isUnlocked ? .black : .white)
                .frame(width: 42, height: 42)
                .background(authentication.isUnlocked ? Color(red: 0.45, green: 0.83, blue: 0.62) : Color.white.opacity(0.14))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(authentication.isUnlocked ? "Sensible Daten entsperrt" : "Sensible Daten gesperrt")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)

                Text(authentication.isUnlocked ? "Passwörter können jetzt bearbeitet werden." : "Zum Bearbeiten Face ID, Touch ID oder Gerätecode bestätigen.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.68))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Button {
                authentication.isUnlocked ? authentication.lock() : authentication.unlock()
            } label: {
                Image(systemName: authentication.isUnlocked ? "lock.fill" : "chevron.right")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.black)
                    .frame(width: 34, height: 34)
                    .background(Color(red: 0.35, green: 0.75, blue: 0.9))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color.white.opacity(0.10))
        .cornerRadius(16)
    }
}

struct LockedSensitiveRow: View {
    let icon: String
    let label: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white.opacity(0.55))
                .frame(width: 30)

            Text(label)
                .foregroundColor(.white.opacity(0.72))
                .font(.system(size: 16, weight: .semibold))

            Spacer()

            Text("••••••••")
                .foregroundColor(.white.opacity(0.42))
                .font(.system(size: 16, weight: .semibold, design: .monospaced))

            Image(systemName: "lock.fill")
                .font(.caption.weight(.bold))
                .foregroundColor(.white.opacity(0.44))
        }
        .padding(12)
        .background(Color.white.opacity(0.07))
        .cornerRadius(16)
    }
}

struct GuestWiFiShareCard: View {
    let ssid: String
    let password: String
    let qrImage: UIImage?
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 12) {
            SettingRow(icon: "wifi.router", label: "Netzwerk", value: ssid, isEditable: false)

            if isUnlocked {
                SettingRow(icon: "key.fill", label: "Passwort", value: password, isEditable: false)
                qrCode
            } else {
                LockedSensitiveRow(icon: "key.fill", label: "Passwort")
                lockedQRCode
            }
        }
    }

    private var qrCode: some View {
        Group {
            if let qrImage {
                Image(uiImage: qrImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                ProgressView()
                    .tint(Color(red: 0.35, green: 0.75, blue: 0.9))
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
            }
        }
    }

    private var lockedQRCode: some View {
        VStack(spacing: 10) {
            Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 36, weight: .semibold))
                .foregroundColor(Color(red: 0.35, green: 0.75, blue: 0.9))

            Text("QR-Code ist geschützt")
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)

            Text("Entsperre sensible Daten, um das Gast-WLAN zu teilen.")
                .font(.caption)
                .foregroundColor(.white.opacity(0.66))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 190)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct NotificationPermissionRow: View {
    @ObservedObject var notificationManager: NotificationManager

    var body: some View {
        HStack {
            Image(systemName: notificationManager.isAuthorized ? "bell.badge.fill" : "bell.slash.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(notificationManager.isAuthorized ? Color(red: 0.35, green: 0.75, blue: 0.9) : .white.opacity(0.62))
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 3) {
                Text("iOS-Berechtigung")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
            }

            Spacer()

            Text(notificationManager.authorizationStatus)
                .foregroundColor(notificationManager.isAuthorized ? Color(red: 0.45, green: 0.83, blue: 0.62) : .white.opacity(0.7))
                .font(.system(size: 15, weight: .bold))
        }
        .padding(12)
        .background(Color.white.opacity(0.12))
        .cornerRadius(16)
    }
}

struct NotificationTestPanel: View {
    @ObservedObject var notificationManager: NotificationManager

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Label("Interne Tests", systemImage: "hammer.fill")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white.opacity(0.72))

                Spacer()
            }

            notificationButton(title: "Offline-Warnung", icon: "wifi.slash") {
                notificationManager.sendOfflineWarning()
            }

            notificationButton(title: "Mobile-Daten-Hinweis", icon: "antenna.radiowaves.left.and.right") {
                notificationManager.sendMobileDataWarning()
            }

            notificationButton(title: "Router-Check", icon: "shield.lefthalf.filled") {
                notificationManager.sendSecurityReminder()
            }

            notificationButton(title: "Neues Gerät Demo", icon: "iphone.gen3.radiowaves.left.and.right") {
                notificationManager.sendNewDeviceDemo()
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.075))
        .cornerRadius(16)
    }

    private func notificationButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 24)
                Text(title)
                Spacer()
                Image(systemName: "paperplane.fill")
                    .font(.caption.weight(.bold))
            }
            .font(.footnote.weight(.semibold))
            .foregroundColor(.white)
            .padding(11)
            .background(Color.white.opacity(0.09))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
}
