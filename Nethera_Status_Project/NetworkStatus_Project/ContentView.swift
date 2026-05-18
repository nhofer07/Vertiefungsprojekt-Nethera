import SwiftUI

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
            handleNetworkChange()
        }
        .onChange(of: networkMonitor.connectionType) { _ in
            handleNetworkChange()
        }
    }

    private func handleNetworkChange() {
        notificationManager.handleNetworkChange(
            statusText: networkMonitor.statusText,
            connectionType: networkMonitor.connectionType
        )
    }
}

#Preview {
    ContentView()
}
