import Foundation
import Combine
// das ist der import für das
import LocalAuthentication

@MainActor
final class AuthenticationManager: ObservableObject {
    @Published var isUnlocked = false
    @Published var message = "Gesperrt"

    func unlock() {
        let context = LAContext()
        context.localizedCancelTitle = "Abbrechen"

        var error: NSError?
        let reason = "Entsperre sensible Daten wie Router-, Gast-WLAN- und Konto-Passwörter."

        // obs face oder touch gibt überhaupt
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            message = "Auf diesem Gerät ist keine Authentifizierung eingerichtet."
            return
        }
// hier kommt dann wirklich dieses face id feld
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
