import SwiftUI

struct NotificationActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 24)
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
            }
            .font(.footnote.weight(.semibold))
            .foregroundColor(.white)
            .padding(12)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct ScreenContainer<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            NetheraStyle.background

            ScrollView(showsIndicators: false) {
                content
                    .padding(.horizontal, 20)
                    .padding(.top, 26)
                    .padding(.bottom, 88)
            }
        }
    }
}

struct HeaderCard: View {
    let title: String
    let subtitle: String
    let description: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(NetheraStyle.accent)
                }

                Spacer()

                Image(systemName: icon)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.black)
                    .frame(width: 46, height: 46)
                    .background(NetheraStyle.accent)
                    .clipShape(Circle())
            }

            Text(description)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.68))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(NetheraStyle.heroBackground)
    }
}

struct CardTitle: View {
    let title: String
    let icon: String

    init(_ title: String, icon: String) {
        self.title = title
        self.icon = icon
    }

    var body: some View {
        Label(title, systemImage: icon)
            .font(.headline.weight(.semibold))
            .foregroundColor(.white)
    }
}

struct StatusPill: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.headline.weight(.semibold))
                .foregroundColor(NetheraStyle.accent)

            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.58))

            Text(value)
                .font(.headline.weight(.bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(NetheraStyle.accent)
                .frame(width: 24)

            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundColor(.white.opacity(0.86))

            Spacer()

            Text(value)
                .font(.footnote.weight(.semibold))
                .foregroundColor(.white.opacity(0.66))
                .multilineTextAlignment(.trailing)
        }
        .padding(11)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct SecureRow: View {
    let title: String
    let value: String
    let icon: String
    let isUnlocked: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(NetheraStyle.accent)
                .frame(width: 24)

            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundColor(.white.opacity(0.86))

            Spacer()

            Text(isUnlocked ? value : "••••••••••")
                .font(.footnote.monospaced().weight(.semibold))
                .foregroundColor(isUnlocked ? .white : .white.opacity(0.44))
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
        .padding(11)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct UnlockButton: View {
    @ObservedObject var authentication: AuthenticationManager

    var body: some View {
        Button {
            authentication.isUnlocked ? authentication.lock() : authentication.unlock()
        } label: {
            HStack {
                Image(systemName: authentication.isUnlocked ? "lock.fill" : "faceid")
                Text(authentication.isUnlocked ? "Wieder sperren" : "Mit Face ID / Code entsperren")
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
            }
            .font(.headline.weight(.semibold))
            .foregroundColor(.black)
            .padding(14)
            .background(NetheraStyle.accent)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct AccessStatusBadge: View {
    let message: String
    let isUnlocked: Bool

    var body: some View {
        Text(message)
            .font(.caption2.weight(.bold))
            .foregroundColor(isUnlocked ? .black : .white.opacity(0.8))
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(isUnlocked ? NetheraStyle.success : Color.white.opacity(0.10))
            .clipShape(Capsule())
    }
}

struct IconInfoCard: View {
    let title: String
    let text: String
    let icon: String
    let iconColor: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(iconColor)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)

                Text(text)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.68))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(NetheraStyle.cardBackground)
    }
}
