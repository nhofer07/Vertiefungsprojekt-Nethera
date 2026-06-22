import SwiftUI

struct SpeedView: View {
    @State private var buttonPressed = false
    @State private var metrics = NetheraBackend.loadSpeedMetrics()

    var body: some View {
        NavigationStack {
            ZStack {
                speedBackground

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        PageHeaderView(title: "Geschwindigkeit", showBackButton: true, outerHorizontalPadding: 0)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Netzwerkleistung")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            Text("Der Geschwindigkeitstest bezieht sich auf das gesamte Netzwerk.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.68))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                        .background(speedCardBackground)

                        VStack(spacing: 12) {
                            SpeedCard(value: display(metrics.download), label: "Download Geschwindigkeit")
                            SpeedCard(value: display(metrics.upload), label: "Upload Geschwindigkeit")
                            SpeedCard(value: display(metrics.averageDownload), label: "ø Download")
                        }

                        Button {
                            buttonPressed.toggle()
                        } label: {
                            Text("Geschwindigkeit testen")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color(red: 0.35, green: 0.75, blue: 0.9))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(
                                    color: Color.black.opacity(buttonPressed ? 0.26 : 0.16),
                                    radius: buttonPressed ? 12 : 8,
                                    x: 0,
                                    y: buttonPressed ? 7 : 5
                                )
                        }
                        .buttonStyle(.plain)

                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            NetheraBackend.refreshFromMongoDB()
            metrics = NetheraBackend.loadSpeedMetrics()
        }
        .onReceive(NotificationCenter.default.publisher(for: .netheraBackendDidRefresh)) { _ in
            metrics = NetheraBackend.loadSpeedMetrics()
        }
    }

    private func display(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Keine Daten" : value
    }

    private var speedBackground: some View {
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
    }

    private var speedCardBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(Color.white.opacity(0.07))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.16), radius: 12, x: 0, y: 6)
    }
}

#Preview {
    NavigationStack {
        SpeedView()
    }
}
