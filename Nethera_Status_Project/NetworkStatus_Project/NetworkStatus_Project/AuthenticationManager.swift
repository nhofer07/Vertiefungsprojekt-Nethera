import Foundation
import Combine
import LocalAuthentication

@MainActor
final class AuthenticationManager: ObservableObject {
    @Published var isUnlocked = false
    @Published var message = "Gesperrt"

    func unlock() {
        let context = LAContext()
        context.localizedCancelTitle = "Abbrechen"

        var error: NSError?
        let reason = "Entsperre sensible Routerdaten wie WLAN-Passwort und Account-Passwort."

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            message = "Auf diesem Gerät ist keine Authentifizierung eingerichtet."
            return
        }

        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] success, authenticationError in
            Task { @MainActor in
                if success {
                    self?.isUnlocked = true
                    self?.message = "Entsperrt"
                } else {
                    self?.isUnlocked = false
                    self?.message = authenticationError?.localizedDescription ?? "Entsperren abgebrochen."
                }
            }
        }
    }

    func lock() {
        isUnlocked = false
        message = "Gesperrt"
    }
}
