import SwiftUI
import Combine
import NetworkExtension
import CoreLocation

struct ConnectedWifiInfo: Equatable {
    var ssid: String
    var bssid: String
    var quality: Double
    var lastUpdate: Date

    var percent: Int {
        Int((min(max(quality, 0), 1) * 100).rounded())
    }

    var estimatedDBM: Int {
        // iOS liefert über NEHotspotNetwork nur einen normalisierten Wert von 0.0 bis 1.0.
        // Für die Anzeige wird daraus ein grober dBm-Schätzwert berechnet.
        Int((-90 + (min(max(quality, 0), 1) * 55)).rounded())
    }

    var label: String {
        switch estimatedDBM {
        case -55...0: return "Sehr stark"
        case -67...(-56): return "Stark"
        case -75...(-68): return "Okay"
        default: return "Schwach"
        }
    }

    var recommendation: String {
        switch estimatedDBM {
        case -55...0: return "Sehr guter Standort. Hier ist das WLAN-Signal stabil."
        case -67...(-56): return "Guter Standort. Streaming und normales Arbeiten sollten gut funktionieren."
        case -75...(-68): return "Noch brauchbar, aber für Videocalls oder Gaming eventuell instabil."
        default: return "Schwacher Standort. Näher zum Router oder Access Point gehen."
        }
    }
}

@MainActor
final class ConnectedWifiSignalViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var wifiInfo: ConnectedWifiInfo?
    @Published var isRefreshing = false
    @Published var permissionText = ""
    @Published var errorText: String?

    private let locationManager = CLLocationManager()
    private var timer: Timer?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func start() {
        requestLocationPermissionIfNeeded()
        refresh()
        startTimer()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func refresh() {
        isRefreshing = true
        errorText = nil

        NEHotspotNetwork.fetchCurrent { [weak self] network in
            Task { @MainActor in
                guard let self else { return }
                self.isRefreshing = false

                guard let network else {
                    self.wifiInfo = nil
                    self.errorText = "Kein verbundenes WLAN gefunden oder Berechtigung fehlt. Auf dem Simulator funktioniert diese Anzeige nicht. Bitte auf einem echten iPhone testen und Standort/WLAN-Info erlauben."
                    return
                }

                self.wifiInfo = ConnectedWifiInfo(
                    ssid: network.ssid,
                    bssid: network.bssid,
                    quality: network.signalStrength,
                    lastUpdate: Date()
                )
            }
        }
    }

    func requestLocationPermissionIfNeeded() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            permissionText = "Standortfreigabe wird benötigt, damit iOS Informationen zum verbundenen WLAN freigibt."
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            permissionText = "Standort ist deaktiviert. Bitte in den iPhone-Einstellungen erlauben, damit das verbundene WLAN angezeigt werden kann."
        case .authorizedAlways, .authorizedWhenInUse:
            permissionText = "Live-Messung aktiv. Bewege dich im Haus und beobachte die Signaländerung."
        @unknown default:
            permissionText = "Berechtigungsstatus unbekannt."
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            requestLocationPermissionIfNeeded()
            refresh()
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
    }
}

struct ConnectedWifiSignalView: View {
    @StateObject private var viewModel = ConnectedWifiSignalViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                background

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        header
                            .padding(.horizontal, 20)
                            .padding(.top, 12)

                        liveSignalCard
                            .padding(.horizontal, 20)

                        permissionCard
                            .padding(.horizontal, 20)

                        explanationCard
                            .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 32)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear { viewModel.start() }
            .onDisappear { viewModel.stop() }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("WLAN Live-Signal")
                .font(.largeTitle.bold())
                .foregroundColor(.white)

            Text("Misst die Stärke des aktuell verbundenen WLANs")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.65))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var liveSignalCard: some View {
        VStack(spacing: 18) {
            HStack {
                Label("Aktuelles WLAN", systemImage: "wifi")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)

                Spacer()

                Button {
                    viewModel.refresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.black)
                        .rotationEffect(.degrees(viewModel.isRefreshing ? 360 : 0))
                        .animation(viewModel.isRefreshing ? .linear(duration: 0.8).repeatForever(autoreverses: false) : .default, value: viewModel.isRefreshing)
                        .frame(width: 38, height: 38)
                        .background(Color(red: 0.35, green: 0.75, blue: 0.9))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            if let info = viewModel.wifiInfo {
                VStack(spacing: 18) {
                    signalMeter(info)

                    VStack(spacing: 5) {
                        Text(info.ssid.isEmpty ? "Unbekanntes WLAN" : info.ssid)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text("BSSID: \(info.bssid.isEmpty ? "nicht verfügbar" : info.bssid)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.45))
                    }

                    HStack(spacing: 10) {
                        valueBox(title: "Qualität", value: "\(info.percent)%")
                        valueBox(title: "ca. dBm", value: "\(info.estimatedDBM)")
                        valueBox(title: "Status", value: info.label)
                    }

                    Text(info.recommendation)
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.72))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Aktualisiert: \(info.lastUpdate.formatted(date: .omitted, time: .standard))")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.42))
                }
            } else {
                VStack(spacing: 14) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))

                    Text("Kein Live-WLAN verfügbar")
                        .font(.title3.bold())
                        .foregroundColor(.white)

                    Text(viewModel.errorText ?? "Verbinde dich mit einem WLAN und teste auf einem echten iPhone.")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.66))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 12)
            }
        }
        .padding(18)
        .background(cardBackground)
    }

    private func signalMeter(_ info: ConnectedWifiInfo) -> some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 18)

            Circle()
                .trim(from: 0, to: info.quality)
                .stroke(signalColor(for: info), style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: info.quality)

            VStack(spacing: 3) {
                Text("\(info.percent)%")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(info.label)
                    .font(.caption.weight(.bold))
                    .foregroundColor(signalColor(for: info))
            }
        }
        .frame(width: 190, height: 190)
        .padding(.top, 4)
    }

    private func valueBox(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline.bold())
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundColor(.white.opacity(0.48))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }

    private var permissionCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "location.fill")
                .font(.headline.weight(.bold))
                .foregroundColor(.black)
                .frame(width: 36, height: 36)
                .background(Color(red: 0.35, green: 0.75, blue: 0.9))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 5) {
                Text("Wichtig für iOS")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)

                Text(viewModel.permissionText.isEmpty ? "Für echte WLAN-Daten braucht die App Standortfreigabe und die Xcode-Capability Access WiFi Information." : viewModel.permissionText)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.68))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    private var explanationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Was diese Seite wirklich kann", systemImage: "checkmark.seal")
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)

            bullet("Zeigt das aktuell verbundene WLAN live an.")
            bullet("Aktualisiert die Signalqualität automatisch beim Herumgehen im Haus.")
            bullet("Listet nicht alle fremden WLANs auf, weil iOS das nicht normal erlaubt.")
            bullet("dBm ist hier ein grober Schätzwert, weil iOS nur eine normalisierte Signalqualität liefert.")
        }
        .padding(16)
        .background(cardBackground)
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color(red: 0.45, green: 0.83, blue: 0.62))
                .font(.caption)
                .padding(.top, 2)

            Text(text)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.70))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func signalColor(for info: ConnectedWifiInfo) -> Color {
        switch info.estimatedDBM {
        case -55...0: return Color(red: 0.45, green: 0.83, blue: 0.62)
        case -67...(-56): return Color(red: 0.35, green: 0.75, blue: 0.9)
        case -75...(-68): return Color(red: 0.95, green: 0.71, blue: 0.3)
        default: return Color(red: 0.92, green: 0.45, blue: 0.52)
        }
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.16, blue: 0.21),
                    Color(red: 0.02, green: 0.03, blue: 0.08),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color(red: 0.35, green: 0.75, blue: 0.9).opacity(0.11))
                .frame(width: 230, height: 230)
                .blur(radius: 70)
                .offset(x: 150, y: -240)
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(Color(red: 0.1, green: 0.15, blue: 0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    ConnectedWifiSignalView()
}
