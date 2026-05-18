import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit
import UserNotifications

struct ContentView: View {
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var authentication = AuthenticationManager()
    @StateObject private var notificationManager = NotificationManager()

    var body: some View {
        TabView {
            NetworkStatusTab(networkMonitor: networkMonitor, authentication: authentication)
                .tabItem {
                    Label("Status", systemImage: "network")
                }

            WiFiQRCodeTab(authentication: authentication)
                .tabItem {
                    Label("Gast-WLAN", systemImage: "qrcode")
                }

            NotificationsTab(networkMonitor: networkMonitor, notificationManager: notificationManager)
                .tabItem {
                    Label("Mitteilungen", systemImage: "bell.badge")
                }
        }
        .tint(NetheraStyle.accent)
        .onChange(of: networkMonitor.statusText) { _ in
            notificationManager.handleNetworkChange(
                statusText: networkMonitor.statusText,
                connectionType: networkMonitor.connectionType
            )
        }
        .onChange(of: networkMonitor.connectionType) { _ in
            notificationManager.handleNetworkChange(
                statusText: networkMonitor.statusText,
                connectionType: networkMonitor.connectionType
            )
        }
    }
}

struct NetworkStatusTab: View {
    @ObservedObject var networkMonitor: NetworkMonitor
    @ObservedObject var authentication: AuthenticationManager
    @State private var animateContent = false

    var body: some View {
        ScreenContainer {
            VStack(alignment: .leading, spacing: 18) {
                header
                networkStatusCard
                routerRecommendationCard
                secureAccessCard
                demoInfoCard
            }
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 14)
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.85)) {
                animateContent = true
            }
        }
    }

    private var header: some View {
        HeaderCard(
            title: "NetworkStatus",
            subtitle: "Apple Network & Security Extension",
            description: "Live-Netzwerkstatus mit Apples Network Framework und geschützte Routerdaten mit Face ID / Code.",
            icon: "network.badge.shield.half.filled"
        )
    }

    private var networkStatusCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            CardTitle("Apple Netzwerkstatus", icon: "antenna.radiowaves.left.and.right")

            HStack(spacing: 12) {
                StatusPill(
                    title: "Status",
                    value: networkMonitor.statusText,
                    icon: networkMonitor.isConnected ? "checkmark.circle.fill" : "xmark.circle.fill"
                )

                StatusPill(
                    title: "Verbindung",
                    value: networkMonitor.connectionType,
                    icon: connectionIcon
                )
            }

            VStack(spacing: 10) {
                InfoRow(
                    title: "Begrenzte Verbindung",
                    value: networkMonitor.isConstrained ? "Ja" : "Nein",
                    icon: "speedometer"
                )

                InfoRow(
                    title: "Kostenpflichtig / Hotspot",
                    value: networkMonitor.isExpensive ? "Ja" : "Nein",
                    icon: "eurosign.circle"
                )
            }
        }
        .padding(16)
        .background(NetheraStyle.cardBackground)
    }

    private var routerRecommendationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            CardTitle("Router-Hinweis", icon: "lightbulb.fill")

            Text(networkMonitor.routerHint)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(NetheraStyle.cardBackground)
    }

    private var secureAccessCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                CardTitle("Geschützte Routerdaten", icon: "faceid")
                Spacer()
                Text(authentication.message)
                    .font(.caption2.weight(.bold))
                    .foregroundColor(authentication.isUnlocked ? .black : .white.opacity(0.8))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(authentication.isUnlocked ? NetheraStyle.success : Color.white.opacity(0.10))
                    .clipShape(Capsule())
            }

            VStack(spacing: 10) {
                SecureRow(title: "WLAN-Passwort", value: DemoRouterData.wifiPassword, icon: "wifi", isUnlocked: authentication.isUnlocked)
                SecureRow(title: "Account-Passwort", value: DemoRouterData.accountPassword, icon: "person.badge.key.fill", isUnlocked: authentication.isUnlocked)
            }

            UnlockButton(authentication: authentication)
        }
        .padding(16)
        .background(NetheraStyle.cardBackground)
    }

    private var demoInfoCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.headline)
                .foregroundColor(NetheraStyle.success)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text("Ohne Developer Account nutzbar")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)

                Text("Die App nutzt Network Framework, LocalAuthentication, Core Image und UserNotifications. Es werden keine WLAN-SSID, BSSID oder Signalstärke ausgelesen.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.68))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(NetheraStyle.cardBackground)
    }

    private var connectionIcon: String {
        switch networkMonitor.connectionType {
        case "WLAN": return "wifi"
        case "Mobile Daten": return "antenna.radiowaves.left.and.right"
        case "Ethernet": return "cable.connector"
        case "Simulator / Lokal": return "desktopcomputer"
        default: return "questionmark.circle"
        }
    }
}

struct WiFiQRCodeTab: View {
    @ObservedObject var authentication: AuthenticationManager
    @State private var qrImage: UIImage?

    private let generator = WiFiQRCodeGenerator()

    var body: some View {
        ScreenContainer {
            VStack(alignment: .leading, spacing: 18) {
                HeaderCard(
                    title: "Gast-WLAN",
                    subtitle: "QR-Code mit Core Image",
                    description: "Nach Face ID wird ein WLAN-QR-Code generiert. Andere Nutzer scannen ihn mit der iPhone-Kamera und können dem Gastnetz beitreten.",
                    icon: "qrcode.viewfinder"
                )

                qrCard
                explanationCard
            }
        }
        .onAppear(perform: makeQRCode)
    }

    private var qrCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                CardTitle("Gastzugang teilen", icon: "wifi.router.fill")
                Spacer()
                Text(authentication.isUnlocked ? "Entsperrt" : "Gesperrt")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(authentication.isUnlocked ? .black : .white.opacity(0.8))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(authentication.isUnlocked ? NetheraStyle.success : Color.white.opacity(0.10))
                    .clipShape(Capsule())
            }

            VStack(spacing: 10) {
                InfoRow(title: "Netzwerk", value: DemoRouterData.guestSSID, icon: "wifi")
                SecureRow(title: "Gast-Passwort", value: DemoRouterData.guestPassword, icon: "key.fill", isUnlocked: authentication.isUnlocked)
            }

            if authentication.isUnlocked {
                qrCodeView
            } else {
                lockedQRCodePlaceholder
            }

            UnlockButton(authentication: authentication)
        }
        .padding(16)
        .background(NetheraStyle.cardBackground)
    }

    private var qrCodeView: some View {
        VStack(spacing: 12) {
            if let qrImage {
                Image(uiImage: qrImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .padding(18)
                    .frame(maxWidth: .infinity)
                    .frame(height: 260)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            } else {
                ProgressView()
                    .tint(NetheraStyle.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 260)
            }

            Text("Mit der iPhone-Kamera scannen und die angezeigte WLAN-Verbindung bestätigen.")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.68))
                .multilineTextAlignment(.center)
        }
    }

    private var lockedQRCodePlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 44, weight: .semibold))
                .foregroundColor(NetheraStyle.accent)

            Text("QR-Code geschützt")
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)

            Text("Entsperre den Gastzugang mit Face ID, Touch ID oder Gerätecode.")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.66))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 230)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var explanationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            CardTitle("Apple-Feature", icon: "apple.logo")
            Text("Der QR-Code wird lokal mit Apples Core Image Framework erzeugt. iPhones erkennen WLAN-QR-Codes direkt über die Kamera-App. Die App selbst verbindet niemanden automatisch, sondern stellt einen sicheren Gastzugang zum Scannen bereit.")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.70))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(NetheraStyle.cardBackground)
    }

    private func makeQRCode() {
        qrImage = generator.makeQRCode(
            ssid: DemoRouterData.guestSSID,
            password: DemoRouterData.guestPassword,
            encryption: "WPA"
        )
    }
}

struct NotificationsTab: View {
    @ObservedObject var networkMonitor: NetworkMonitor
    @ObservedObject var notificationManager: NotificationManager

    var body: some View {
        ScreenContainer {
            VStack(alignment: .leading, spacing: 18) {
                HeaderCard(
                    title: "Mitteilungen",
                    subtitle: "iOS UserNotifications",
                    description: "Lokale Router-Warnungen für Netzwerkänderungen, Testmeldungen und Sicherheits-Erinnerungen.",
                    icon: "bell.badge.fill"
                )

                permissionCard
                automaticWarningsCard
                testNotificationsCard
                limitationCard
            }
        }
        .onAppear {
            notificationManager.refreshAuthorizationStatus()
        }
    }

    private var permissionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                CardTitle("Mitteilungen erlauben", icon: "app.badge.fill")
                Spacer()
                Text(notificationManager.authorizationStatus)
                    .font(.caption2.weight(.bold))
                    .foregroundColor(notificationManager.isAuthorized ? .black : .white.opacity(0.8))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(notificationManager.isAuthorized ? NetheraStyle.success : Color.white.opacity(0.10))
                    .clipShape(Capsule())
            }

            Text("Damit Nethera lokale iOS-Mitteilungen anzeigen darf, muss der Nutzer die Berechtigung einmal bestätigen.")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.70))
                .fixedSize(horizontal: false, vertical: true)

            Button {
                notificationManager.requestPermission()
            } label: {
                HStack {
                    Image(systemName: "bell.badge")
                    Text("Mitteilungen aktivieren")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                }
                .font(.headline.weight(.semibold))
                .foregroundColor(.black)
                .padding(14)
                .background(NetheraStyle.accent)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(NetheraStyle.cardBackground)
    }

    private var automaticWarningsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            CardTitle("Automatische Warnungen", icon: "antenna.radiowaves.left.and.right.circle.fill")

            Toggle(isOn: $notificationManager.automaticWarningsEnabled) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Bei Netzwerkänderungen warnen")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                    Text("Sendet Hinweise, wenn die App aktiv ist oder kurzzeitig im Hintergrund weiterläuft.")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.62))
                }
            }
            .tint(NetheraStyle.accent)

            VStack(spacing: 10) {
                InfoRow(title: "Aktueller Status", value: networkMonitor.statusText, icon: networkMonitor.isConnected ? "checkmark.circle.fill" : "xmark.circle.fill")
                InfoRow(title: "Verbindung", value: networkMonitor.connectionType, icon: "network")
            }
        }
        .padding(16)
        .background(NetheraStyle.cardBackground)
    }

    private var testNotificationsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            CardTitle("Test-Mitteilungen", icon: "paperplane.fill")

            Text("Diese Buttons lösen lokale iOS-Mitteilungen aus. Für die Präsentation kannst du damit zeigen, wie Router-Warnungen aussehen würden.")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.70))
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                NotificationActionButton(title: "Offline-Warnung testen", icon: "wifi.slash") {
                    notificationManager.sendOfflineWarning()
                }

                NotificationActionButton(title: "Mobile-Daten-Hinweis testen", icon: "antenna.radiowaves.left.and.right") {
                    notificationManager.sendMobileDataWarning()
                }

                NotificationActionButton(title: "Router-Check erinnern", icon: "shield.lefthalf.filled") {
                    notificationManager.sendSecurityReminder()
                }

                NotificationActionButton(title: "Neues Gerät Demo", icon: "iphone.gen3.radiowaves.left.and.right") {
                    notificationManager.sendNewDeviceDemo()
                }
            }
        }
        .padding(16)
        .background(NetheraStyle.cardBackground)
    }

    private var limitationCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.headline)
                .foregroundColor(NetheraStyle.accent)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text("Wichtiger iOS-Hinweis")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)

                Text("Wenn die App lange im Hintergrund ist, kann iOS sie einfrieren. Dann ist eine sofortige Warnung bei WLAN-Aus nicht garantiert. Test-Mitteilungen und geplante lokale Hinweise funktionieren trotzdem.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.68))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(NetheraStyle.cardBackground)
    }
}

struct NotificationActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 24)
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
            }
            .font(.footnote.weight(.semibold))
            .foregroundColor(.white)
            .padding(12)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct ScreenContainer<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            NetheraStyle.background

            ScrollView(showsIndicators: false) {
                content
                    .padding(.horizontal, 20)
                    .padding(.top, 26)
                    .padding(.bottom, 88)
            }
        }
    }
}

struct HeaderCard: View {
    let title: String
    let subtitle: String
    let description: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(NetheraStyle.accent)
                }

                Spacer()

                Image(systemName: icon)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.black)
                    .frame(width: 46, height: 46)
                    .background(NetheraStyle.accent)
                    .clipShape(Circle())
            }

            Text(description)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.68))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(NetheraStyle.heroBackground)
    }
}

struct CardTitle: View {
    let title: String
    let icon: String

    init(_ title: String, icon: String) {
        self.title = title
        self.icon = icon
    }

    var body: some View {
        Label(title, systemImage: icon)
            .font(.headline.weight(.semibold))
            .foregroundColor(.white)
    }
}

struct StatusPill: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.headline.weight(.semibold))
                .foregroundColor(NetheraStyle.accent)

            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.58))

            Text(value)
                .font(.headline.weight(.bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(NetheraStyle.accent)
                .frame(width: 24)

            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundColor(.white.opacity(0.86))

            Spacer()

            Text(value)
                .font(.footnote.weight(.semibold))
                .foregroundColor(.white.opacity(0.66))
                .multilineTextAlignment(.trailing)
        }
        .padding(11)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct SecureRow: View {
    let title: String
    let value: String
    let icon: String
    let isUnlocked: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(NetheraStyle.accent)
                .frame(width: 24)

            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundColor(.white.opacity(0.86))

            Spacer()

            Text(isUnlocked ? value : "••••••••••")
                .font(.footnote.monospaced().weight(.semibold))
                .foregroundColor(isUnlocked ? .white : .white.opacity(0.44))
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
        .padding(11)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct UnlockButton: View {
    @ObservedObject var authentication: AuthenticationManager

    var body: some View {
        Button {
            authentication.isUnlocked ? authentication.lock() : authentication.unlock()
        } label: {
            HStack {
                Image(systemName: authentication.isUnlocked ? "lock.fill" : "faceid")
                Text(authentication.isUnlocked ? "Wieder sperren" : "Mit Face ID / Code entsperren")
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
            }
            .font(.headline.weight(.semibold))
            .foregroundColor(.black)
            .padding(14)
            .background(NetheraStyle.accent)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct WiFiQRCodeGenerator {
    private let context = CIContext()

    func makeQRCode(ssid: String, password: String, encryption: String) -> UIImage? {
        let wifiString = "WIFI:T:\(escape(encryption));S:\(escape(ssid));P:\(escape(password));;"
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(wifiString.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else { return nil }
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 12, y: 12))

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    private func escape(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: ";", with: "\\;")
            .replacingOccurrences(of: ",", with: "\\,")
            .replacingOccurrences(of: ":", with: "\\:")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }
}

enum DemoRouterData {
    static let wifiPassword = "Nethera_2026!"
    static let accountPassword = "Admin#Router26"
    static let guestSSID = "Nethera Guest"
    static let guestPassword = "Guest_2026!"
}

enum NetheraStyle {
    static let accent = Color(red: 0.35, green: 0.75, blue: 0.9)
    static let success = Color(red: 0.45, green: 0.83, blue: 0.62)

    static var background: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.11, blue: 0.15),
                    Color(red: 0.03, green: 0.04, blue: 0.07),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(accent.opacity(0.13))
                .frame(width: 230, height: 230)
                .blur(radius: 70)
                .offset(x: 150, y: -260)

            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 190, height: 190)
                .blur(radius: 70)
                .offset(x: -140, y: 280)
        }
    }

    static var heroBackground: some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.13),
                        Color.white.opacity(0.06)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.35), radius: 18, x: 0, y: 12)
    }

    static var cardBackground: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Color.white.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.28), radius: 14, x: 0, y: 9)
    }
}

#Preview {
    ContentView()
}
