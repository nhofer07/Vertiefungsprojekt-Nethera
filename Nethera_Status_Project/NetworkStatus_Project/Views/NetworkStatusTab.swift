import SwiftUI

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
            CardTitle("Netzwerkstatus", icon: "antenna.radiowaves.left.and.right")

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
                AccessStatusBadge(message: authentication.message, isUnlocked: authentication.isUnlocked)
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
