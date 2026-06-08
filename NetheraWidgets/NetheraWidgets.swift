import CoreImage
import CoreImage.CIFilterBuiltins
import AppIntents
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
    let childIndex: Int
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
    let childCards: [NetheraChildWidgetSnapshot]

    static let empty = NetheraWidgetSnapshot(
        unknownDevices: 0,
        protectedDevices: 0,
        blockedThreats: 0,
        networkLoad: 0,
        lastScan: "Noch nicht synchronisiert",
        nextNetworkAction: "App öffnen und Backend synchronisieren",
        guestNetworkName: "Nicht gespeichert",
        guestPassword: "Nicht gespeichert",
        guestTimeLeft: "Kein Gastzugang gespeichert",
        childName: "Kein Kind",
        screenTimeLeft: "Kein Preset aktiv",
        focusStartsAt: "Keine Fokuszeit geplant",
        activePreset: "Kein Preset aktiv",
        familyAction: "Kein Geräte-Preset aktiv",
        childCards: []
    )
}

struct NetheraChildWidgetSnapshot: Codable {
    let childName: String
    let screenTimeLeft: String
    let focusStartsAt: String
    let activePreset: String
    let familyAction: String
}

enum NetheraWidgetDataStore {
    private static let appGroupID = "group.NicoHofer.Nethera"
    private static let snapshotKey = "widgets.snapshot"
    private static let childIndexKey = "widgets.currentChildIndex"

    // liest die daten, die die app für die widgets gespeichert hat:
    static func loadSnapshot() -> NetheraWidgetSnapshot {
        guard let data = UserDefaults(suiteName: appGroupID)?.data(forKey: snapshotKey),
              let snapshot = try? JSONDecoder().decode(NetheraWidgetSnapshot.self, from: data) else {
            return .empty
        }
        return snapshot
    }

    // aktuelles kind fuer die kinderuebersicht:
    static func currentChildIndex(for snapshot: NetheraWidgetSnapshot) -> Int {
        let count = max(1, snapshot.childCards.count)
        let value = UserDefaults(suiteName: appGroupID)?.integer(forKey: childIndexKey) ?? 0
        return ((value % count) + count) % count
    }

    // wechselt das kind direkt ueber widget-buttons:
    static func switchChild(by offset: Int) {
        let snapshot = loadSnapshot()
        let count = max(1, snapshot.childCards.count)
        let current = currentChildIndex(for: snapshot)
        let next = ((current + offset) % count + count) % count
        UserDefaults(suiteName: appGroupID)?.set(next, forKey: childIndexKey)
        WidgetCenter.shared.reloadTimelines(ofKind: "NetheraFamilyFocusWidget")
    }
}

struct NetheraPreviousChildIntent: AppIntent {
    static var title: LocalizedStringResource = "Vorheriges Kind"

    func perform() async throws -> some IntentResult {
        NetheraWidgetDataStore.switchChild(by: -1)
        return .result()
    }
}

struct NetheraNextChildIntent: AppIntent {
    static var title: LocalizedStringResource = "Nächstes Kind"

    func perform() async throws -> some IntentResult {
        NetheraWidgetDataStore.switchChild(by: 1)
        return .result()
    }
}

struct NetheraWidgetProvider: TimelineProvider {
    // platzhalter wenn iOS das widget in der galerie zeigt:
    func placeholder(in context: Context) -> NetheraWidgetEntry {
        NetheraWidgetEntry(date: Date(), snapshot: .empty, childIndex: 0)
    }

    // schneller einzelstand fuer previews und kurze aktualisierungen:
    func getSnapshot(in context: Context, completion: @escaping (NetheraWidgetEntry) -> Void) {
        let snapshot = NetheraWidgetDataStore.loadSnapshot()
        completion(NetheraWidgetEntry(date: Date(), snapshot: snapshot, childIndex: NetheraWidgetDataStore.currentChildIndex(for: snapshot)))
    }

    // timeline bleibt stabil, gewechselt wird direkt ueber widget-buttons:
    func getTimeline(in context: Context, completion: @escaping (Timeline<NetheraWidgetEntry>) -> Void) {
        let now = Date()
        let snapshot = NetheraWidgetDataStore.loadSnapshot()
        let entry = NetheraWidgetEntry(date: now, snapshot: snapshot, childIndex: NetheraWidgetDataStore.currentChildIndex(for: snapshot))
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: now) ?? now
        completion(Timeline(entries: [entry], policy: .after(refreshDate)))
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
        .configurationDisplayName("Nethera Geräteübersicht")
        .description("Zeigt aktives Profil und Fokuszeit pro ausgewähltem Gerät.")
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
                        .font(.system(size: 22, weight: .bold, design: .rounded))
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

    private var currentIndex: Int {
        guard !entry.snapshot.childCards.isEmpty else { return 0 }
        return entry.childIndex % entry.snapshot.childCards.count
    }

    private var child: NetheraChildWidgetSnapshot {
        guard !entry.snapshot.childCards.isEmpty else {
            return NetheraChildWidgetSnapshot(
                childName: entry.snapshot.childName,
                screenTimeLeft: entry.snapshot.screenTimeLeft,
                focusStartsAt: entry.snapshot.focusStartsAt,
                activePreset: entry.snapshot.activePreset,
                familyAction: entry.snapshot.familyAction
            )
        }

        return entry.snapshot.childCards[currentIndex]
    }

    var body: some View {
        NetheraWidgetBackground {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(width: 28, height: 28)
                            .background(NetheraWidgetColor.cyan)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                        VStack(alignment: .leading, spacing: 1) {
                            Text(child.childName)
                                .font(.system(size: 19, weight: .bold, design: .rounded))
                                .foregroundStyle(NetheraWidgetColor.text)
                                .lineLimit(1)
                                .minimumScaleFactor(0.70)

                            Text("Nethera Geräteübersicht")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(NetheraWidgetColor.muted)
                                .lineLimit(1)
                        }

                        Spacer(minLength: 0)
                    }

                    HStack(spacing: 8) {
                        NetheraChildMainCard(child: child)

                        NetheraPresetFocusBox(child: child)
                            .frame(width: 126)
                    }
                }

                if entry.snapshot.childCards.count > 1 {
                    NetheraChildPagerRail(
                        currentIndex: currentIndex,
                        count: entry.snapshot.childCards.count
                    )
                    .frame(width: 22)
                }
            }
        }
        .widgetURL(URL(string: "nethera://presets"))
    }
}

struct NetheraPresetFocusBox: View {
    let child: NetheraChildWidgetSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            NetheraPresetFocusRow(
                icon: "shield.lefthalf.filled",
                label: "Aktives Preset",
                value: child.presetStatusText
            )

            Divider()
                .overlay(NetheraWidgetColor.line.opacity(0.65))

            NetheraPresetFocusRow(
                icon: "moon.fill",
                label: "Fokuszeit",
                value: child.focusStartsAt
            )

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 74, alignment: .topLeading)
        .padding(.horizontal, 9)
        .padding(.vertical, 8)
        .background(NetheraWidgetColor.card)
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(NetheraWidgetColor.line.opacity(0.75), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct NetheraPresetFocusRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(NetheraWidgetColor.cyan)

                Text(label)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(NetheraWidgetColor.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.60)
            }

            Text(value)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(NetheraWidgetColor.text)
                .lineLimit(2)
                .minimumScaleFactor(0.46)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct NetheraChildMainCard: View {
    let child: NetheraChildWidgetSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 20, height: 20)
                    .background(NetheraWidgetColor.cyan)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

                Text("Infos")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(NetheraWidgetColor.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }

            Text(child.infoText)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(NetheraWidgetColor.text)
                .lineLimit(3)
                .minimumScaleFactor(0.60)
                .lineSpacing(1)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 74, alignment: .topLeading)
        .padding(.horizontal, 9)
        .padding(.vertical, 8)
        .background(
            LinearGradient(
                colors: [NetheraWidgetColor.card, Color.white.opacity(0.055)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(NetheraWidgetColor.line, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

extension NetheraChildWidgetSnapshot {
    var presetStatusText: String {
        if activePreset.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Kein Preset aktiv"
        }
        if activePreset.contains("Kein Preset") || activePreset.contains(": aktiv") {
            return activePreset
        }
        return "\(activePreset): aktiv"
    }

    var infoText: String {
        if familyAction.contains("bleibt blockiert") || familyAction.contains("Domains") {
            return "Anfrage auf verbotene Seite blockiert"
        }
        return familyAction
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
                .padding(.horizontal, 20)
                .padding(.top, 17)
                .padding(.bottom, 16)
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
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.black)
                .frame(width: 24, height: 24)
                .background(NetheraWidgetColor.cyan)
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
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
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(NetheraWidgetColor.text)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(tint.opacity(0.23))
            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
    }
}

struct NetheraChildSwitchControls: View {
    var body: some View {
        HStack(spacing: 5) {
            Button(intent: NetheraPreviousChildIntent()) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(NetheraWidgetColor.text)
                    .frame(width: 24, height: 24)
                    .background(NetheraWidgetColor.card)
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            }
            .buttonStyle(.plain)

            Button(intent: NetheraNextChildIntent()) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(NetheraWidgetColor.text)
                    .frame(width: 24, height: 24)
                    .background(NetheraWidgetColor.card)
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
}

struct NetheraChildPagerRail: View {
    let currentIndex: Int
    let count: Int

    private var visibleDots: Int {
        min(count, 5)
    }

    var body: some View {
        VStack(spacing: 5) {
            Button(intent: NetheraPreviousChildIntent()) {
                Image(systemName: "chevron.up")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(NetheraWidgetColor.text)
                    .frame(width: 22, height: 18)
                    .background(NetheraWidgetColor.card)
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            VStack(spacing: 5) {
                ForEach(0..<visibleDots, id: \.self) { index in
                    Circle()
                        .fill(dotColor(for: index))
                        .frame(width: index == currentDot ? 7 : 6, height: index == currentDot ? 7 : 6)
                }
            }

            Spacer(minLength: 0)

            Button(intent: NetheraNextChildIntent()) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(NetheraWidgetColor.text)
                    .frame(width: 22, height: 18)
                    .background(NetheraWidgetColor.card)
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .frame(maxHeight: .infinity)
    }

    private var currentDot: Int {
        guard count > visibleDots else { return currentIndex }
        let position = (Double(currentIndex) / Double(max(1, count - 1))) * Double(visibleDots - 1)
        return min(visibleDots - 1, Int(position.rounded()))
    }

    private func dotColor(for index: Int) -> Color {
        index == currentDot ? NetheraWidgetColor.text : NetheraWidgetColor.text.opacity(0.34)
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
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 23, height: 23)
                    .background(tint)
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(NetheraWidgetColor.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }

            Text(text)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(NetheraWidgetColor.text)
                .lineLimit(3)
                .minimumScaleFactor(0.60)
                .lineSpacing(1)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 86, alignment: .topLeading)
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
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
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(NetheraWidgetColor.cyan)
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(NetheraWidgetColor.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }

            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(NetheraWidgetColor.text)
                .lineLimit(2)
                .minimumScaleFactor(0.50)
        }
        .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(NetheraWidgetColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct NetheraCompactMetric: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(NetheraWidgetColor.cyan)

                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(NetheraWidgetColor.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.60)
            }

            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(NetheraWidgetColor.text)
                .lineLimit(2)
                .minimumScaleFactor(0.48)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 36, alignment: .leading)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(NetheraWidgetColor.card)
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(NetheraWidgetColor.line.opacity(0.75), lineWidth: 1)
        }
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
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(NetheraWidgetColor.muted)
                .lineLimit(1)

            Text(value)
                .font(monospaced ? .system(size: 14, weight: .bold, design: .monospaced) : .system(size: 14, weight: .bold, design: .rounded))
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

    // erstellt den echten WLAN-QR-Code fuer das gastnetz:
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

    // escaped sonderzeichen im WLAN-QR-payload:
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
