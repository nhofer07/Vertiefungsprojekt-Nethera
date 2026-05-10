import SwiftUI

struct WifiNetwork: Identifiable, Equatable {
    enum NetworkType: String {
        case router = "Router"
        case accessPoint = "Access Point"
    }

    let id = UUID()
    var ssid: String
    var bssid: String
    var type: NetworkType
    var signalStrength: Int
    var channel: Int
    var frequency: String
    var encryption: String
    var isKnownNetwork: Bool
    var lastSeen: String

    var signalLabel: String {
        switch signalStrength {
        case -55...0: return "Sehr stark"
        case -67...(-56): return "Stark"
        case -75...(-68): return "Okay"
        default: return "Schwach"
        }
    }

    var signalQuality: Double {
        let clamped = min(max(signalStrength, -90), -35)
        return Double(clamped + 90) / 55.0
    }
}

struct WifiNetworksView: View {
    @State private var networks: [WifiNetwork] = WifiNetworksView.demoNetworks
    @State private var searchText = ""
    @State private var selectedFilter: NetworkFilter = .all
    @State private var isScanning = false

    private enum NetworkFilter: String, CaseIterable {
        case all = "Alle"
        case router = "Router"
        case accessPoint = "Access Points"
        case strong = "Bestes Signal"
    }

    private var filteredNetworks: [WifiNetwork] {
        networks
            .filter { network in
                switch selectedFilter {
                case .all: return true
                case .router: return network.type == .router
                case .accessPoint: return network.type == .accessPoint
                case .strong: return network.signalStrength >= -67
                }
            }
            .filter { network in
                searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                network.ssid.localizedCaseInsensitiveContains(searchText) ||
                network.bssid.localizedCaseInsensitiveContains(searchText)
            }
            .sorted { $0.signalStrength > $1.signalStrength }
    }

    private var bestNetwork: WifiNetwork? {
        networks.sorted { $0.signalStrength > $1.signalStrength }.first
    }

    var body: some View {
        NavigationStack {
            ZStack {
                background

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        header
                            .padding(.horizontal, 20)
                            .padding(.top, 12)

                        introCard
                            .padding(.horizontal, 20)

                        bestSignalCard
                            .padding(.horizontal, 20)

                        searchAndFilterArea
                            .padding(.horizontal, 20)

                        VStack(spacing: 12) {
                            ForEach(filteredNetworks) { network in
                                networkCard(network)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 30)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("WiFi Signal Analyzer")
                .font(.largeTitle.bold())
                .foregroundColor(.white)

            Text("Router & Access Points in der Umgebung")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.65))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var introCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
                    .background(Color(red: 0.35, green: 0.75, blue: 0.9))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 5) {
                    Text("WLAN-Scanner")
                        .font(.title3.bold())
                        .foregroundColor(.white)

                    Text("Listet WLAN-Router und Access Points in der Umgebung auf. So kann später sichtbar werden, wo das Router-Signal am besten ist.")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.70))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Button {
                simulateScan()
            } label: {
                HStack {
                    Image(systemName: isScanning ? "arrow.triangle.2.circlepath" : "magnifyingglass")
                        .rotationEffect(.degrees(isScanning ? 360 : 0))
                        .animation(isScanning ? .linear(duration: 0.9).repeatForever(autoreverses: false) : .default, value: isScanning)

                    Text(isScanning ? "Scanne Umgebung ..." : "Umgebung scannen")
                        .font(.headline.weight(.semibold))

                    Spacer()

                    Text("Demo")
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.18))
                        .clipShape(Capsule())
                }
                .foregroundColor(.black)
                .padding(14)
                .background(Color(red: 0.35, green: 0.75, blue: 0.9))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(isScanning)
        }
        .padding(16)
        .background(cardBackground)
    }

    private var bestSignalCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Bestes Signal", systemImage: "target")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)

                Spacer()

                Text("Empfehlung")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(Color(red: 0.45, green: 0.83, blue: 0.62))
                    .clipShape(Capsule())
            }

            if let bestNetwork {
                HStack(spacing: 12) {
                    signalCircle(for: bestNetwork)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(bestNetwork.ssid)
                            .font(.headline)
                            .foregroundColor(.white)

                        Text("\(bestNetwork.type.rawValue) • \(bestNetwork.signalStrength) dBm • Kanal \(bestNetwork.channel)")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.66))
                    }

                    Spacer()
                }
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    private var searchAndFilterArea: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.55))

                TextField("Router oder Access Point suchen", text: $searchText, prompt: Text("Router oder Access Point suchen").foregroundColor(.white.opacity(0.45)))
                    .foregroundColor(.white)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
            .padding(13)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(NetworkFilter.allCases, id: \.self) { filter in
                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                                selectedFilter = filter
                            }
                        } label: {
                            Text(filter.rawValue)
                                .font(.caption.weight(.semibold))
                                .foregroundColor(selectedFilter == filter ? .black : .white.opacity(0.72))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedFilter == filter ? Color(red: 0.35, green: 0.75, blue: 0.9) : Color.white.opacity(0.08))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func networkCard(_ network: WifiNetwork) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: network.type == .router ? "wifi.router" : "antenna.radiowaves.left.and.right")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.cyan)
                    .frame(width: 38, height: 38)
                    .background(Color.white.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(network.ssid)
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(1)

                        if network.isKnownNetwork {
                            Text("bekannt")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Color(red: 0.45, green: 0.83, blue: 0.62))
                                .clipShape(Capsule())
                        }
                    }

                    Text("\(network.type.rawValue) • \(network.encryption)")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.66))

                    Text(network.bssid)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.42))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 5) {
                    Text("\(network.signalStrength) dBm")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)

                    Text(network.signalLabel)
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(signalColor(for: network))
                }
            }

            signalBar(for: network)

            HStack(spacing: 8) {
                infoPill(icon: "number", text: "Kanal \(network.channel)")
                infoPill(icon: "wave.3.right", text: network.frequency)
                infoPill(icon: "clock", text: network.lastSeen)
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    private func signalBar(for network: WifiNetwork) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.08))

                Capsule()
                    .fill(signalColor(for: network))
                    .frame(width: geometry.size.width * network.signalQuality)
            }
        }
        .frame(height: 8)
    }

    private func signalCircle(for network: WifiNetwork) -> some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.10), lineWidth: 6)

            Circle()
                .trim(from: 0, to: network.signalQuality)
                .stroke(signalColor(for: network), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Image(systemName: "wifi")
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)
        }
        .frame(width: 52, height: 52)
    }

    private func infoPill(icon: String, text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption2.weight(.semibold))
        .foregroundColor(.white.opacity(0.72))
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.07))
        .clipShape(Capsule())
    }

    private func signalColor(for network: WifiNetwork) -> Color {
        switch network.signalStrength {
        case -55...0: return Color(red: 0.45, green: 0.83, blue: 0.62)
        case -67...(-56): return Color(red: 0.35, green: 0.75, blue: 0.9)
        case -75...(-68): return Color(red: 0.95, green: 0.71, blue: 0.3)
        default: return Color(red: 0.92, green: 0.45, blue: 0.52)
        }
    }

    private func simulateScan() {
        isScanning = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.15) {
            networks = WifiNetworksView.demoNetworks.shuffled().map { network in
                var copy = network
                copy.signalStrength = max(-88, min(-38, network.signalStrength + Int.random(in: -4...4)))
                return copy
            }
            isScanning = false
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

    static let demoNetworks: [WifiNetwork] = [
        WifiNetwork(ssid: "Nethera WiFi", bssid: "A4:2B:8C:19:20:01", type: .router, signalStrength: -43, channel: 36, frequency: "5 GHz", encryption: "WPA3", isKnownNetwork: true, lastSeen: "gerade"),
        WifiNetwork(ssid: "Nethera WiFi OG", bssid: "A4:2B:8C:19:20:02", type: .accessPoint, signalStrength: -51, channel: 40, frequency: "5 GHz", encryption: "WPA3", isKnownNetwork: true, lastSeen: "gerade"),
        WifiNetwork(ssid: "FRITZ!Box 7590", bssid: "E8:DF:70:44:91:AF", type: .router, signalStrength: -62, channel: 11, frequency: "2.4 GHz", encryption: "WPA2", isKnownNetwork: false, lastSeen: "vor 1 min"),
        WifiNetwork(ssid: "Nachbar_WLAN", bssid: "C0:25:06:7B:11:9C", type: .router, signalStrength: -71, channel: 6, frequency: "2.4 GHz", encryption: "WPA2", isKnownNetwork: false, lastSeen: "vor 2 min"),
        WifiNetwork(ssid: "Office_AP_Keller", bssid: "18:FD:74:01:8A:20", type: .accessPoint, signalStrength: -78, channel: 149, frequency: "5 GHz", encryption: "WPA2", isKnownNetwork: false, lastSeen: "vor 3 min"),
        WifiNetwork(ssid: "IoT_Guest", bssid: "B0:95:75:C4:2D:81", type: .accessPoint, signalStrength: -66, channel: 1, frequency: "2.4 GHz", encryption: "WPA2", isKnownNetwork: true, lastSeen: "gerade")
    ]
}

#Preview {
    WifiNetworksView()
}
