import SwiftUI

struct AuthView: View {
    enum Mode: String, CaseIterable {
        case login = "Login"
        case register = "Registrieren"
    }

    @State private var mode: Mode = .login
    @State private var loginEmail = ""
    @State private var loginPassword = ""

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

    @State private var message = ""
    @State private var messageIsError = false
    @State private var isSubmitting = false

    private let accentColor = Color(red: 0.35, green: 0.75, blue: 0.9)

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.2, blue: 0.25),
                    Color(red: 0.02, green: 0.03, blue: 0.08),
                    .black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    authHero

                    AuthModeSelector(mode: $mode, accentColor: accentColor)
                        .padding(.top, 10)

                    VStack(alignment: .leading, spacing: 14) {
                        if mode == .login {
                            loginForm
                        } else {
                            registerForm
                        }
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.white.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                    )

                    if !message.isEmpty {
                        Text(message)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(messageIsError ? Color(red: 1.0, green: 0.45, blue: 0.45) : accentColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 48)
                .padding(.bottom, 28)
            }
        }
        .onAppear {
            NetheraBackend.refreshFromMongoDB()
        }
    }

    private var authHero: some View {
        VStack(spacing: 11) {
            Image("Nethera_Logo")
                .resizable()
                .scaledToFit()
                .padding(14)
                .frame(width: 96, height: 96)
                .background(Color(red: 0.07, green: 0.16, blue: 0.19))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(accentColor.opacity(0.55), lineWidth: 1)
                )
                .shadow(color: accentColor.opacity(0.28), radius: 22, x: 0, y: 10)

            Text("Nethera")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Dein Netzwerk. Sicher verbunden.")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white.opacity(0.68))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 28)
        .padding(.bottom, 6)
    }

    private var loginForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Anmelden")
                .font(.title2.weight(.bold))
                .foregroundColor(.white)

            AuthTextField(icon: "envelope", placeholder: "E-Mail", text: $loginEmail)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)

            AuthSecureField(icon: "lock", placeholder: "Passwort", text: $loginPassword)

            AuthPrimaryButton(title: "Einloggen", icon: "rectangle.portrait.and.arrow.right", isLoading: isSubmitting) {
                login()
            }
        }
    }

    private var registerForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account erstellen")
                .font(.title2.weight(.bold))
                .foregroundColor(.white)

            AuthTextField(icon: "person.crop.circle", placeholder: "Name", text: $name)
            AuthTextField(icon: "envelope", placeholder: "E-Mail", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
            AuthSecureField(icon: "lock", placeholder: "Passwort", text: $password)
            Text("Telefon und Geburtsdatum kannst du danach in den Kontoeinstellungen ergänzen.")
                .font(.caption)
                .foregroundColor(.white.opacity(0.60))
                .fixedSize(horizontal: false, vertical: true)

            AuthPrimaryButton(title: "Registrieren", icon: "person.badge.plus", isLoading: isSubmitting) {
                register()
            }
        }
    }

    private func login() {
        let trimmedEmail = loginEmail.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty, !loginPassword.isEmpty else {
            showMessage("Bitte E-Mail und Passwort eingeben.", isError: true)
            return
        }

        isSubmitting = true
        NetheraBackend.login(email: trimmedEmail, password: loginPassword) { result in
            isSubmitting = false
            switch result {
            case .success:
                loginPassword = ""
                showMessage("Angemeldet.", isError: false)
            case .failure(let error):
                showMessage(error.localizedDescription, isError: true)
            }
        }
    }

    private func register() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty,
              !trimmedEmail.isEmpty,
              !password.isEmpty else {
            showMessage("Bitte alle Registrierungsfelder ausfüllen.", isError: true)
            return
        }

        isSubmitting = true
        NetheraBackend.register(name: trimmedName, email: trimmedEmail, password: password) { result in
            isSubmitting = false
            switch result {
            case .success:
                clearRegistrationForm()
                showMessage("Account erstellt und sicher gespeichert.", isError: false)
            case .failure(let error):
                showMessage(error.localizedDescription, isError: true)
            }
        }
    }

    private func clearRegistrationForm() {
        name = ""
        email = ""
        password = ""
    }

    private func showMessage(_ text: String, isError: Bool) {
        message = text
        messageIsError = isError
    }
}

private struct AuthTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Color(red: 0.35, green: 0.75, blue: 0.9))
                .frame(width: 24)

            TextField(placeholder, text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.45)))
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))
        }
        .padding(13)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct AuthModeSelector: View {
    @Binding var mode: AuthView.Mode
    let accentColor: Color

    var body: some View {
        HStack(spacing: 8) {
            modeButton(.login)
            modeButton(.register)
        }
        .padding(5)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    private func modeButton(_ targetMode: AuthView.Mode) -> some View {
        let isSelected = mode == targetMode

        return Button {
            withAnimation(.spring(response: 0.26, dampingFraction: 0.86)) {
                mode = targetMode
            }
        } label: {
            Text(targetMode.rawValue)
                .font(.subheadline.weight(.bold))
                .foregroundColor(isSelected ? .black : .white.opacity(0.7))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(isSelected ? accentColor : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct AuthSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Color(red: 0.35, green: 0.75, blue: 0.9))
                .frame(width: 24)

            SecureField(placeholder, text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.45)))
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))
        }
        .padding(13)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct AuthPrimaryButton: View {
    let title: String
    let icon: String
    var isLoading = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(.black)
                } else {
                    Label(title, systemImage: icon)
                }
            }
            .font(.headline.weight(.bold))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color(red: 0.35, green: 0.75, blue: 0.9))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .padding(.top, 4)
    }
}
