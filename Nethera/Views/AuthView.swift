import SwiftUI

struct AuthView: View {
    enum Mode: String, CaseIterable {
        case login = "Login"
        case register = "Registrieren"
    }

    @State private var mode: Mode = .login
    @State private var storedSettings = NetheraBackend.loadAccountSettings()

    @State private var loginEmail = ""
    @State private var loginPassword = ""

    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var birthDate = ""

    @State private var message = ""
    @State private var messageIsError = false

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
                    VStack(alignment: .leading, spacing: 12) {
                        Image("Nethera_Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 78, height: 78)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: accentColor.opacity(0.22), radius: 18, x: 0, y: 8)

                        Text("Nethera")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Melde dich an, damit Netzwerk-, Router- und Gerätedaten geladen werden können.")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.white.opacity(0.68))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 22)

                    AuthModeSelector(mode: $mode, accentColor: accentColor)

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
                .padding(.bottom, 28)
            }
        }
        .onAppear {
            loadStoredSettings()
            NetheraBackend.refreshFromMongoDB()
        }
        .onReceive(NotificationCenter.default.publisher(for: .netheraBackendDidRefresh)) { _ in
            loadStoredSettings()
        }
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

            AuthPrimaryButton(title: "Einloggen", icon: "rectangle.portrait.and.arrow.right") {
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
            AuthTextField(icon: "phone", placeholder: "Telefon", text: $phone)
                .keyboardType(.phonePad)
            AuthSecureField(icon: "lock", placeholder: "Passwort", text: $password)
            AuthTextField(icon: "calendar", placeholder: "Geburtsdatum", text: $birthDate)
            AuthPrimaryButton(title: "Registrieren", icon: "person.badge.plus") {
                register()
            }
        }
    }

    private func loadStoredSettings() {
        storedSettings = NetheraBackend.loadAccountSettings()
    }

    private func login() {
        let trimmedEmail = loginEmail.trimmingCharacters(in: .whitespacesAndNewlines)

        guard NetheraBackend.isDatabaseAvailable() else {
            showMessage("Datenbank nicht erreichbar. Login erst nach Backend-Verbindung möglich.", isError: true)
            NetheraBackend.refreshFromMongoDB()
            return
        }

        guard !trimmedEmail.isEmpty, !loginPassword.isEmpty else {
            showMessage("Bitte E-Mail und Passwort eingeben.", isError: true)
            return
        }

        guard !storedSettings.email.isEmpty, !storedSettings.password.isEmpty else {
            showMessage("Noch kein Account vorhanden. Bitte zuerst registrieren.", isError: true)
            mode = .register
            return
        }

        guard trimmedEmail.caseInsensitiveCompare(storedSettings.email) == .orderedSame,
              loginPassword == storedSettings.password else {
            showMessage("E-Mail oder Passwort stimmt nicht.", isError: true)
            return
        }

        var settings = storedSettings
        settings.isLoggedIn = true
        settings.authMode = "Angemeldet"
        NetheraBackend.saveAccountSettings(settings)
        showMessage("Angemeldet.", isError: false)
    }

    private func register() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBirthDate = birthDate.trimmingCharacters(in: .whitespacesAndNewlines)

        guard NetheraBackend.isDatabaseAvailable() else {
            showMessage("Datenbank nicht erreichbar. Registrierung erst nach Backend-Verbindung möglich.", isError: true)
            NetheraBackend.refreshFromMongoDB()
            return
        }

        guard !trimmedName.isEmpty,
              !trimmedEmail.isEmpty,
              !trimmedPhone.isEmpty,
              !password.isEmpty,
              !trimmedBirthDate.isEmpty else {
            showMessage("Bitte alle Registrierungsfelder ausfüllen.", isError: true)
            return
        }

        let settings = NetheraBackend.AccountSettings(
            name: trimmedName,
            email: trimmedEmail,
            phone: trimmedPhone,
            password: password,
            birthDate: trimmedBirthDate,
            twoFactorStatus: "",
            apiAccessStatus: "",
            isLoggedIn: true,
            authMode: "Account erstellt"
        )

        NetheraBackend.saveAccountSettings(settings)
        storedSettings = settings
        clearRegistrationForm()
        showMessage("Account erstellt und gespeichert.", isError: false)
    }

    private func clearRegistrationForm() {
        name = ""
        email = ""
        phone = ""
        password = ""
        birthDate = ""
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
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.headline.weight(.bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(red: 0.35, green: 0.75, blue: 0.9))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
    }
}
