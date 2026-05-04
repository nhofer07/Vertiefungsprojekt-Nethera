import SwiftUI

struct HomeView: View {

    @State private var animateContent = false

    private let gridColumns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                background

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {

                        VStack(alignment: .leading, spacing: 18) {
                            heroCard
                                .opacity(animateContent ? 1 : 0)
                                .offset(y: animateContent ? 0 : 12)

                            sectionHeader(
                                title: "Schnellzugriff",
                                subtitle: "Die wichtigsten Bereiche von Nethera"
                            )
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 12)

                            LazyVGrid(columns: gridColumns, spacing: 14) {
                                NavigationLink(destination: SpeedView()) {
                                    shortcutCard(
                                        title: "Geschwindigkeit",
                                        subtitle: "Verbindung prüfen",
                                        symbol: "speedometer",
                                        tint: Color(red: 0.35, green: 0.75, blue: 0.9)
                                    )
                                }
                                .buttonStyle(.plain)

                                NavigationLink(destination: ParentalControlView()) {
                                    shortcutCard(
                                        title: "Kindersicherung",
                                        subtitle: "Geräte verwalten",
                                        symbol: "lock.shield",
                                        tint: Color(red: 0.45, green: 0.83, blue: 0.62)
                                    )
                                }
                                .buttonStyle(.plain)

                                NavigationLink(destination: AdBlockDashboardView()) {
                                    shortcutCard(
                                        title: "AdBlock",
                                        subtitle: "Werbung filtern",
                                        symbol: "shield.lefthalf.filled",
                                        tint: Color(red: 0.95, green: 0.71, blue: 0.3)
                                    )
                                }
                                .buttonStyle(.plain)

                                NavigationLink(destination: BlacklistDashboardView()) {
                                    shortcutCard(
                                        title: "Blacklist",
                                        subtitle: "Domains sperren",
                                        symbol: "nosign",
                                        tint: Color(red: 0.92, green: 0.45, blue: 0.52)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 12)

                            infoCard
                                .opacity(animateContent ? 1 : 0)
                                .offset(y: animateContent ? 0 : 12)
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 28)
                }
            }
            .onAppear {
                animateContent = true
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var background: some View {
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
                .fill(Color(red: 0.18, green: 0.72, blue: 0.82).opacity(0.12))
                .frame(width: 220, height: 220)
                .blur(radius: 64)
                .offset(x: 160, y: -240)

            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 180, height: 180)
                .blur(radius: 70)
                .offset(x: -140, y: 260)
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nethera")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Dein Netzwerk auf einen Blick.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.72))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "network")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                    .background(Color(red: 0.35, green: 0.75, blue: 0.9))
                    .clipShape(Circle())
            }

            VStack(spacing: 10) {
                compactMetric(value: "5", label: "Geräte mit dem Netz verbunden", isPrimary: true)

                HStack(spacing: 10) {
                    compactMetric(value: "19h", label: "Internetnutzung \n diese Woche")
                    compactMetric(value: "57 GB", label: "Datenverbrauch \n diese Woche")
                }
            }
        }
        .padding(18)
        .background(heroBackground)
    }


    private var netheraStatusCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Nethera-Übersicht", systemImage: "network.badge.shield.half.filled")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)

                Spacer()

                Text("Live")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.35, green: 0.75, blue: 0.9))
                    .clipShape(Capsule())
            }

            VStack(spacing: 10) {
                statusRow(title: "Neu / nicht zugeordnet", value: "1 Gerät", icon: "sparkles")
                statusRow(title: "Aktive Presets", value: "Ein/Aus direkt am Preset", icon: "slider.horizontal.3")
                statusRow(title: "Gruppenaktionen", value: "Swipe: Umbenennen, Blocklist, Löschen", icon: "hand.draw")
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    private func statusRow(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.cyan)
                .frame(width: 22)

            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundColor(.white.opacity(0.86))

            Spacer()

            Text(value)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.66))
                .multilineTextAlignment(.trailing)
        }
        .padding(10)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var infoCard: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: "checkmark.seal.fill")
                .font(.headline)
                .foregroundColor(Color(red: 0.45, green: 0.83, blue: 0.62))

            VStack(alignment: .leading, spacing: 4) {
                Text("Alles synchronisiert")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)

                Text("Schutz, Blocklisten und Priorisierung sind zentral erreichbar.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.68))
            }

            Spacer()
        }
        .padding(16)
        .background(cardBackground)
    }

    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)

            Text(subtitle)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.68))
        }
    }

    private func compactMetric(value: String, label: String, isPrimary: Bool = false) -> some View {
        VStack(alignment: isPrimary ? .leading : .center, spacing: isPrimary ? 4 : 6) {
            Text(value)
                .font(.system(size: isPrimary ? 30 : 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(label)
                .font(isPrimary ? .subheadline.weight(.semibold) : .caption.weight(.semibold))
                .foregroundColor(.white.opacity(0.72))
                .multilineTextAlignment(isPrimary ? .leading : .center)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: isPrimary ? 58 : 74, alignment: isPrimary ? .leading : .center)
        .padding(.vertical, isPrimary ? 14 : 10)
        .padding(.horizontal, isPrimary ? 16 : 10)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(isPrimary ? 0.10 : 0.07), Color.white.opacity(0.045)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.07), lineWidth: 1)
        )
    }
    
    private func shortcutCard(title: String, subtitle: String, symbol: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: symbol)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 38, height: 38)
                    .background(tint.opacity(0.24))
                    .clipShape(Circle())

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white.opacity(0.55))
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.68))
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 128, alignment: .leading)
        .padding(16)
        .background(
            LinearGradient(
                colors: [tint.opacity(0.22), Color.white.opacity(0.06)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 6)
    }

    // card style für jede gruppe:
    private var heroBackground: some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.10),
                        Color.white.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.18), radius: 16, x: 0, y: 8)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(Color.white.opacity(0.07))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.07), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.16), radius: 12, x: 0, y: 6)
    }
}

#Preview {
    HomeView()
}
