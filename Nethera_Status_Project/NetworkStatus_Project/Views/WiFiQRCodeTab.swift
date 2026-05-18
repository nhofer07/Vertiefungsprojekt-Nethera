import SwiftUI
import UIKit

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
            }
        }
        .onAppear(perform: makeQRCode)
    }

    private var qrCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                CardTitle("Gastzugang teilen", icon: "wifi.router.fill")
                Spacer()
                AccessStatusBadge(
                    message: authentication.isUnlocked ? "Entsperrt" : "Gesperrt",
                    isUnlocked: authentication.isUnlocked
                )
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

    private func makeQRCode() {
        qrImage = generator.makeQRCode(
            ssid: DemoRouterData.guestSSID,
            password: DemoRouterData.guestPassword,
            encryption: "WPA"
        )
    }
}
