import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI
import UIKit
import WidgetKit

enum NetheraWidgetColor {
    static let backgroundTop = Color(red: 0.03, green: 0.09, blue: 0.10)
    static let backgroundBottom = Color(red: 0.01, green: 0.02, blue: 0.03)
    static let card = Color.white.opacity(0.09)
    static let line = Color.white.opacity(0.13)
    static let text = Color.white
    static let muted = Color.white.opacity(0.66)
    static let cyan = Color(red: 0.33, green: 0.83, blue: 0.92)
    static let green = Color(red: 0.47, green: 0.86, blue: 0.62)
    static let yellow = Color(red: 0.96, green: 0.73, blue: 0.33)
    static let red = Color(red: 0.93, green: 0.42, blue: 0.49)
}

struct NetheraWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: NetheraWidgetSnapshot
}

struct NetheraWidgetSnapshot: Codable {
    let unknownDevices: Int
    let protectedDevices: Int
    let blockedThreats: Int
    let networkLoad: Int
    let lastScan: String
    let nextNetworkAction: String
    let guestNetworkName: String
    let guestPassword: String
    let guestTimeLeft: String
    let childName: String
    let screenTimeLeft: String
    let focusStartsAt: String
    let activePreset: String
    let familyAction: String

    static let fallback = NetheraWidgetSnapshot(
        unknownDevices: 1,
        protectedDevices: 5,
        blockedThreats: 0,
        networkLoad: 70,
        lastScan: "vor acht Minuten",
        nextNetworkAction: "Unbekanntes Gerät prüfen",
        guestNetworkName: "Nethera Guest",
        guestPassword: "In der App speichern",
        guestTimeLeft: "Gastzugang aus den Einstellungen",
        childName: "Kind",
        screenTimeLeft: "Kein Zeitlimit aktiv",
        focusStartsAt: "Keine Fokuszeit geplant",
        activePreset: "Kein Preset aktiv",
        familyAction: "In der App ein Preset aktivieren"
    )
}

enum NetheraWidgetDataStore {
    private static let appGroupID = "group.NicoHofer.Nethera"
    private static let snapshotKey = "widgets.snapshot"

    static func loadSnapshot() -> NetheraWidgetSnapshot {
        guard let data = UserDefaults(suiteName: appGroupID)?.data(forKey: snapshotKey),
              let snapshot = try? JSONDecoder().decode(NetheraWidgetSnapshot.self, from: data) else {
            return .fallback
        }
        return snapshot
    }
}

struct NetheraWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> NetheraWidgetEntry {
        NetheraWidgetEntry(date: Date(), snapshot: .fallback)
    }

    func getSnapshot(in context: Context, completion: @escaping (NetheraWidgetEntry) -> Void) {
        completion(NetheraWidgetEntry(date: Date(), snapshot: NetheraWidgetDataStore.loadSnapshot()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NetheraWidgetEntry>) -> Void) {
        let now = Date()
        let entries = (0..<6).compactMap { hourOffset in
            Calendar.current.date(byAdding: .hour, value: hourOffset, to: now).map {
                NetheraWidgetEntry(date: $0, snapshot: NetheraWidgetDataStore.loadSnapshot())
            }
        }
        let refreshDate = Calendar.current.date(byAdding: .hour, value: 1, to: now) ?? now
        completion(Timeline(entries: entries, policy: .after(refreshDate)))
    }
}

@main
struct NetheraWidgetsBundle: WidgetBundle {
    var body: some Widget {
        NetheraDailyCheckWidget()
        NetheraGuestAccessWidget()
        NetheraFamilyFocusWidget()
    }
}

struct NetheraDailyCheckWidget: Widget {
    let kind = "NetheraDailyCheckWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NetheraWidgetProvider()) { entry in
            NetheraDailyCheckWidgetView(entry: entry)
        }
        .configurationDisplayName("Nethera Tagescheck")
        .description("Zeigt die wichtigste Netzwerk-Aufgabe und den aktuellen Schutz.")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}

struct NetheraGuestAccessWidget: Widget {
    let kind = "NetheraGuestAccessWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NetheraWidgetProvider()) { entry in
            NetheraGuestAccessWidgetView(entry: entry)
        }
        .configurationDisplayName("Nethera Gastzugang")
        .description("Zeigt den Gast-WLAN-QR-Code mit Name und Passwort.")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}

struct NetheraFamilyFocusWidget: Widget {
    let kind = "NetheraFamilyFocusWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NetheraWidgetProvider()) { entry in
            NetheraFamilyFocusWidgetView(entry: entry)
        }
        .configurationDisplayName("Nethera Familienruhe")
        .description("Zeigt Restzeit, aktives Profil und die nächste Fokuszeit.")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}

struct NetheraDailyCheckWidgetView: View {
    let entry: NetheraWidgetEntry

    var body: some View {
        NetheraWidgetBackground {
            VStack(alignment: .leading, spacing: 9) {
                HStack(alignment: .top, spacing: 10) {
                    NetheraWidgetTitle(icon: "shield.checkered", title: "Nethera Tagescheck")
                    Spacer(minLength: 0)
                    NetheraStatusLabel(
                        text: entry.snapshot.unknownDevices == 0 ? "Keine Aktion offen" : "Aktion offen",
                        tint: entry.snapshot.unknownDevices == 0 ? NetheraWidgetColor.green : NetheraWidgetColor.yellow
                    )
                }

                HStack(spacing: 10) {
                    NetheraActionCard(
                        icon: entry.snapshot.unknownDevices == 0 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill",
                        title: "Wichtigste Aufgabe",
                        text: entry.snapshot.nextNetworkAction,
                        tint: entry.snapshot.unknownDevices == 0 ? NetheraWidgetColor.green : NetheraWidgetColor.yellow
                    )

                    VStack(spacing: 8) {
                        NetheraStackMetric(
                            value: "\(entry.snapshot.protectedDevices)",
                            label: "Geräte geschützt",
                            icon: "desktopcomputer"
                        )
                        NetheraStackMetric(
                            value: "\(entry.snapshot.blockedThreats)",
                            label: "Bedrohungen geblockt",
                            icon: "nosign"
                        )
                    }
                    .frame(width: 116)
                }
            }
        }
        .widgetURL(URL(string: "nethera://devices"))
    }
}

struct NetheraGuestAccessWidgetView: View {
    let entry: NetheraWidgetEntry

    var body: some View {
        NetheraWidgetBackground {
            HStack(spacing: 13) {
                NetheraQRCodeView(
                    networkName: entry.snapshot.guestNetworkName,
                    password: entry.snapshot.guestPassword
                )
                .frame(width: 100, height: 100)

                VStack(alignment: .leading, spacing: 7) {
                    NetheraWidgetTitle(icon: "qrcode.viewfinder", title: "Nethera Gastzugang")

                    Text("Direkt verbinden")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(NetheraWidgetColor.text)
                        .lineLimit(1)
                        .minimumScaleFactor(0.74)

                    NetheraPlainRow(title: "Netzwerkname", value: entry.snapshot.guestNetworkName)
                    NetheraPlainRow(title: "Passwort", value: entry.snapshot.guestPassword, monospaced: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .widgetURL(URL(string: "nethera://guest"))
    }
}

struct NetheraFamilyFocusWidgetView: View {
    let entry: NetheraWidgetEntry

    var body: some View {
        NetheraWidgetBackground {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 12) {
                    NetheraWidgetTitle(icon: "moon.zzz.fill", title: "Nethera Familienruhe")
                    Spacer(minLength: 0)
                    NetheraStatusLabel(text: entry.snapshot.activePreset, tint: NetheraWidgetColor.cyan)
                }

                HStack(spacing: 10) {
                    NetheraActionCard(
                        icon: "hand.raised.fill",
                        title: "\(entry.snapshot.childName) heute",
                        text: entry.snapshot.familyAction,
                        tint: NetheraWidgetColor.yellow
                    )

                    VStack(spacing: 8) {
                        NetheraStackMetric(
                            value: entry.snapshot.screenTimeLeft,
                            label: "Bildschirmzeit übrig",
                            icon: "clock.fill"
                        )
                        NetheraStackMetric(
                            value: entry.snapshot.focusStartsAt,
                            label: "Nächste Fokuszeit",
                            icon: "moon.fill"
                        )
                    }
                    .frame(width: 132)
                }
            }
        }
        .widgetURL(URL(string: "nethera://presets"))
    }
}

struct NetheraWidgetBackground<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [NetheraWidgetColor.backgroundTop, NetheraWidgetColor.backgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 0) {
                Rectangle()
                    .fill(NetheraWidgetColor.cyan.opacity(0.22))
                    .frame(height: 3)
                Spacer(minLength: 0)
            }

            content
                .padding(.horizontal, 13)
                .padding(.top, 12)
                .padding(.bottom, 11)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .containerBackground(for: .widget) {
            NetheraWidgetColor.backgroundBottom
        }
    }
}

struct NetheraWidgetTitle: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(.black)
                .frame(width: 24, height: 24)
                .background(NetheraWidgetColor.cyan)
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

            Text(title)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(NetheraWidgetColor.text)
                .lineLimit(1)
                .minimumScaleFactor(0.74)
        }
    }
}

struct NetheraStatusLabel: View {
    let text: String
    let tint: Color

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .black, design: .rounded))
            .foregroundStyle(NetheraWidgetColor.text)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(tint.opacity(0.23))
            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
    }
}

struct NetheraActionCard: View {
    let icon: String
    let title: String
    let text: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(.black)
                    .frame(width: 25, height: 25)
                    .background(tint)
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

                Text(title)
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(NetheraWidgetColor.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }

            Text(text)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(NetheraWidgetColor.text)
                .lineLimit(2)
                .minimumScaleFactor(0.68)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 88, alignment: .topLeading)
        .padding(11)
        .background(NetheraWidgetColor.card)
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(NetheraWidgetColor.line, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct NetheraStackMetric: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(NetheraWidgetColor.cyan)
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(NetheraWidgetColor.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }

            Text(value)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(NetheraWidgetColor.text)
                .lineLimit(2)
                .minimumScaleFactor(0.58)
        }
        .frame(maxWidth: .infinity, minHeight: 42, alignment: .leading)
        .padding(.horizontal, 9)
        .padding(.vertical, 7)
        .background(NetheraWidgetColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct NetheraPlainRow: View {
    let title: String
    let value: String
    var monospaced = false

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(NetheraWidgetColor.muted)
                .lineLimit(1)

            Text(value)
                .font(monospaced ? .system(size: 14, weight: .black, design: .monospaced) : .system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(NetheraWidgetColor.text)
                .lineLimit(1)
                .minimumScaleFactor(0.58)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(NetheraWidgetColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct NetheraQRCodeView: View {
    let networkName: String
    let password: String

    var body: some View {
        Group {
            if let image = makeQRCode() {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
            } else {
                NetheraFallbackQRCode()
            }
        }
        .padding(7)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func makeQRCode() -> UIImage? {
        let payload = "WIFI:T:WPA;S:\(escape(networkName));P:\(escape(password));;"
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(payload.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else {
            return nil
        }

        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 8, y: 8))
        let context = CIContext()

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }

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

struct NetheraFallbackQRCode: View {
    private let cells: [[Bool]] = [
        [true, true, true, false, true, false, true],
        [true, false, true, false, false, true, false],
        [true, true, true, false, true, true, true],
        [false, false, false, true, false, true, false],
        [true, false, true, true, true, false, true],
        [false, true, false, false, true, false, false],
        [true, false, true, true, false, true, true]
    ]

    var body: some View {
        GeometryReader { geometry in
            let gap: CGFloat = 3
            let size = max(2, (geometry.size.width - gap * 6) / 7)

            VStack(spacing: gap) {
                ForEach(cells.indices, id: \.self) { row in
                    HStack(spacing: gap) {
                        ForEach(cells[row].indices, id: \.self) { column in
                            RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                                .fill(cells[row][column] ? Color.black : Color.clear)
                                .frame(width: size, height: size)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
