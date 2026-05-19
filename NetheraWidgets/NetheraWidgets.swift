import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI
import UIKit
import WidgetKit

enum NetheraColors {
    static let accent = Color(red: 0.35, green: 0.75, blue: 0.9)
    static let success = Color(red: 0.45, green: 0.83, blue: 0.62)
    static let warning = Color(red: 0.95, green: 0.71, blue: 0.3)
    static let danger = Color(red: 0.92, green: 0.45, blue: 0.52)
}

struct NetheraWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: NetheraWidgetSnapshot
}

struct NetheraWidgetSnapshot {
    let protectedDevices: Int
    let blockedThreats: Int
    let networkLoad: Int
    let unknownDevices: Int
    let lastScan: String
    let securityRecommendation: String
    let guestSSID: String
    let guestPassword: String
    let dailyLimit: String
    let childDevicesOnline: Int
    let nextFocusWindow: String
    let childName: String
    let activePreset: String
    let familyRecommendation: String

    static let demo = NetheraWidgetSnapshot(
        protectedDevices: 5,
        blockedThreats: 128,
        networkLoad: 73,
        unknownDevices: 1,
        lastScan: "vor 8 min",
        securityRecommendation: "1 neues Gerät prüfen",
        guestSSID: "Nethera Guest",
        guestPassword: "Guest_2026!",
        dailyLimit: "1h 45m",
        childDevicesOnline: 2,
        nextFocusWindow: "20:30",
        childName: "Lena",
        activePreset: "Schultag",
        familyRecommendation: "YouTube bleibt bis 18:00 blockiert"
    )
}

struct NetheraWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> NetheraWidgetEntry {
        NetheraWidgetEntry(date: Date(), snapshot: .demo)
    }

    func getSnapshot(in context: Context, completion: @escaping (NetheraWidgetEntry) -> Void) {
        completion(NetheraWidgetEntry(date: Date(), snapshot: .demo))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NetheraWidgetEntry>) -> Void) {
        let now = Date()
        let entries = (0..<6).compactMap { hourOffset in
            Calendar.current.date(byAdding: .hour, value: hourOffset, to: now).map {
                NetheraWidgetEntry(date: $0, snapshot: .demo)
            }
        }
        completion(Timeline(entries: entries, policy: .after(Calendar.current.date(byAdding: .hour, value: 1, to: now) ?? now)))
    }
}

@main
struct NetheraWidgetsBundle: WidgetBundle {
    var body: some Widget {
        NetheraShieldWidget()
        NetheraGuestWidget()
        NetheraFamilyWidget()
    }
}

struct NetheraShieldWidget: Widget {
    let kind = "NetheraShieldWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NetheraWidgetProvider()) { entry in
            NetheraShieldWidgetView(entry: entry)
        }
        .configurationDisplayName("Nethera Netzwerk-Check")
        .description("Zeigt, ob du heute im Netzwerk etwas prüfen musst.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct NetheraGuestWidget: Widget {
    let kind = "NetheraGuestWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NetheraWidgetProvider()) { entry in
            NetheraGuestWidgetView(entry: entry)
        }
        .configurationDisplayName("Nethera Gast-WLAN")
        .description("Gastnetz schnell teilen, ohne in der App etwas vorzubereiten.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct NetheraFamilyWidget: Widget {
    let kind = "NetheraFamilyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NetheraWidgetProvider()) { entry in
            NetheraFamilyWidgetView(entry: entry)
        }
        .configurationDisplayName("Nethera Familienplan")
        .description("Restzeit, aktives Preset und nächste Fokuszeit ohne App öffnen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct NetheraShieldWidgetView: View {
    let entry: NetheraWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        NetheraWidgetBackground {
            if family == .systemSmall {
                VStack(alignment: .leading, spacing: 9) {
                    WidgetHeader(title: "Netz-Check", icon: "checkmark.shield.fill")
                    Spacer()

                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text("\(entry.snapshot.unknownDevices)")
                            .font(.system(size: 44, weight: .black, design: .rounded))
                            .foregroundStyle(entry.snapshot.unknownDevices == 0 ? NetheraColors.success : NetheraColors.warning)
                        Text("neu")
                            .font(.caption.weight(.black))
                            .foregroundStyle(.white.opacity(0.72))
                    }

                    Text(entry.snapshot.securityRecommendation)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    Text("Scan \(entry.snapshot.lastScan)")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.55))
                }
                .widgetURL(URL(string: "nethera://devices"))
            } else {
                VStack(alignment: .leading, spacing: 13) {
                    HStack {
                        WidgetHeader(title: "Nethera Netzwerk-Check", icon: "checkmark.shield.fill")
                        Spacer()
                        StatusChip(text: entry.snapshot.unknownDevices == 0 ? "Alles ruhig" : "Prüfen", tint: entry.snapshot.unknownDevices == 0 ? NetheraColors.success : NetheraColors.warning)
                    }

                    HStack(spacing: 12) {
                        PriorityPanel(
                            title: "Nächste Aktion",
                            value: entry.snapshot.securityRecommendation,
                            icon: entry.snapshot.unknownDevices == 0 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill",
                            tint: entry.snapshot.unknownDevices == 0 ? NetheraColors.success : NetheraColors.warning
                        )

                        VStack(spacing: 8) {
                            CompactMetric(value: "\(entry.snapshot.protectedDevices)", label: "geschützt", icon: "desktopcomputer")
                            CompactMetric(value: "\(entry.snapshot.blockedThreats)", label: "geblockt", icon: "nosign")
                        }
                        .frame(width: 92)
                    }

                    HStack {
                        Label("Letzter Scan \(entry.snapshot.lastScan)", systemImage: "clock")
                        Spacer()
                        Label("\(entry.snapshot.networkLoad)% Last", systemImage: "waveform.path.ecg")
                    }
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white.opacity(0.58))
                }
                .widgetURL(URL(string: "nethera://devices"))
            }
        }
    }
}

struct NetheraGuestWidgetView: View {
    let entry: NetheraWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        NetheraWidgetBackground {
            if family == .systemSmall {
                VStack(alignment: .leading, spacing: 9) {
                    WidgetHeader(title: "Gast-WLAN", icon: "qrcode")
                    Spacer()
                    WidgetQRCodeMark(ssid: entry.snapshot.guestSSID, password: entry.snapshot.guestPassword)
                        .frame(width: 68, height: 68)
                    Text(entry.snapshot.guestSSID)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text("Kamera öffnen und scannen")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.55))
                }
            } else {
                HStack(spacing: 16) {
                    WidgetQRCodeMark(ssid: entry.snapshot.guestSSID, password: entry.snapshot.guestPassword)
                        .frame(width: 96, height: 96)

                    VStack(alignment: .leading, spacing: 9) {
                        WidgetHeader(title: "Gast-WLAN", icon: "qrcode.viewfinder")
                        Text("Sofort verbinden")
                            .font(.title3.weight(.black))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Text(entry.snapshot.guestSSID)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white.opacity(0.70))
                        Text(entry.snapshot.guestPassword)
                            .font(.system(.caption, design: .monospaced).weight(.bold))
                            .foregroundStyle(.white.opacity(0.76))
                            .padding(.horizontal, 9)
                            .padding(.vertical, 6)
                            .background(.white.opacity(0.10))
                            .clipShape(Capsule())
                        Text("Kein Menü, kein Suchen, einfach QR scannen.")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.55))
                            .lineLimit(2)
                    }
                    Spacer()
                }
            }
        }
    }
}

struct NetheraFamilyWidgetView: View {
    let entry: NetheraWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        NetheraWidgetBackground {
            if family == .systemSmall {
                VStack(alignment: .leading, spacing: 9) {
                    WidgetHeader(title: entry.snapshot.childName, icon: "figure.2.and.child.holdinghands")
                    Spacer()
                    Text(entry.snapshot.dailyLimit)
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Restzeit heute")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.72))
                    StatusChip(text: entry.snapshot.activePreset, tint: NetheraColors.accent)
                }
                .widgetURL(URL(string: "nethera://presets"))
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        WidgetHeader(title: "Familienplan", icon: "lock.shield.fill")
                        Spacer()
                        StatusChip(text: entry.snapshot.activePreset, tint: NetheraColors.accent)
                    }

                    HStack(spacing: 12) {
                        PriorityPanel(
                            title: "\(entry.snapshot.childName) heute",
                            value: entry.snapshot.familyRecommendation,
                            icon: "hand.raised.fill",
                            tint: NetheraColors.warning
                        )

                        VStack(spacing: 8) {
                            CompactMetric(value: entry.snapshot.dailyLimit, label: "Restzeit", icon: "clock.fill")
                            CompactMetric(value: entry.snapshot.nextFocusWindow, label: "Fokus", icon: "moon.fill")
                        }
                        .frame(width: 96)
                    }

                    Label("\(entry.snapshot.childDevicesOnline) Kindergeräte gerade online", systemImage: "iphone.gen3.radiowaves.left.and.right")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white.opacity(0.58))
                }
                .widgetURL(URL(string: "nethera://presets"))
            }
        }
    }
}

struct NetheraWidgetBackground<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.11, blue: 0.14),
                    Color(red: 0.02, green: 0.03, blue: 0.07),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(NetheraColors.accent.opacity(0.22))
                .frame(width: 120, height: 120)
                .blur(radius: 35)
                .offset(x: 72, y: -64)

            content
                .padding(16)
        }
        .containerBackground(for: .widget) {
            Color.black
        }
    }
}

struct WidgetHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.caption.weight(.black))
                .foregroundStyle(.black)
                .frame(width: 24, height: 24)
                .background(NetheraColors.accent)
                .clipShape(Circle())

            Text(title)
                .font(.caption.weight(.black))
                .foregroundStyle(.white)
                .lineLimit(1)
        }
    }
}

struct ThreatBadge: View {
    let count: Int

    var body: some View {
        Label("\(count) geblockt", systemImage: "nosign")
            .font(.caption2.weight(.black))
            .foregroundStyle(.white)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(NetheraColors.danger.opacity(0.24))
            .clipShape(Capsule())
    }
}

struct RingProgress: View {
    let value: Int
    let label: String

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.12), lineWidth: 10)
            Circle()
                .trim(from: 0, to: CGFloat(value) / 100)
                .stroke(NetheraColors.accent, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))

            VStack(spacing: 1) {
                Text("\(value)%")
                    .font(.system(size: 19, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text(label)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white.opacity(0.62))
            }
        }
        .frame(width: 82, height: 82)
    }
}

struct QRLikeMark: View {
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
            let size = (geometry.size.width - gap * 6) / 7

            VStack(spacing: gap) {
                ForEach(cells.indices, id: \.self) { row in
                    HStack(spacing: gap) {
                        ForEach(cells[row].indices, id: \.self) { column in
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .fill(cells[row][column] ? Color.black : Color.clear)
                                .frame(width: size, height: size)
                        }
                    }
                }
            }
            .padding(8)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}

struct WidgetQRCodeMark: View {
    let ssid: String
    let password: String

    var body: some View {
        Group {
            if let image = makeQRCode() {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .padding(8)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                QRLikeMark()
            }
        }
    }

    private func makeQRCode() -> UIImage? {
        let escapedSSID = escape(ssid)
        let escapedPassword = escape(password)
        let wifiPayload = "WIFI:T:WPA;S:\(escapedSSID);P:\(escapedPassword);;"

        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(wifiPayload.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else { return nil }
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

struct MetricPill: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(NetheraColors.accent)
            Text(value)
                .font(.headline.weight(.black))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white.opacity(0.62))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct StatusChip: View {
    let text: String
    let tint: Color

    var body: some View {
        Text(text)
            .font(.caption2.weight(.black))
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(tint.opacity(0.24))
            .clipShape(Capsule())
    }
}

struct PriorityPanel: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.caption.weight(.black))
                .foregroundStyle(.black)
                .frame(width: 28, height: 28)
                .background(tint)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.caption.weight(.black))
                    .foregroundStyle(.white.opacity(0.72))
                    .lineLimit(1)

                Text(value)
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 76, alignment: .topLeading)
        .padding(12)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct CompactMetric: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.caption2.weight(.black))
                .foregroundStyle(NetheraColors.accent)
                .frame(width: 16)

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.caption.weight(.black))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
                Text(label)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white.opacity(0.55))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(9)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
