import SwiftUI

enum NetheraStyle {
    static let accent = Color(red: 0.35, green: 0.75, blue: 0.9)
    static let success = Color(red: 0.45, green: 0.83, blue: 0.62)

    static var background: some View {
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
                .fill(accent.opacity(0.13))
                .frame(width: 230, height: 230)
                .blur(radius: 70)
                .offset(x: 150, y: -260)

            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 190, height: 190)
                .blur(radius: 70)
                .offset(x: -140, y: 280)
        }
    }

    static var heroBackground: some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.13),
                        Color.white.opacity(0.06)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.35), radius: 18, x: 0, y: 12)
    }

    static var cardBackground: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Color.white.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.28), radius: 14, x: 0, y: 9)
    }
}
