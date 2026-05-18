import SwiftUI

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
                AccessStatusBadge(
                    message: notificationManager.authorizationStatus,
                    isUnlocked: notificationManager.isAuthorized
                )
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

}
