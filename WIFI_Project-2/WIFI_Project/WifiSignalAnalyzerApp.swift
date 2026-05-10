import SwiftUI

@main
struct WifiSignalAnalyzerApp: App {
    var body: some Scene {
        WindowGroup {
            ConnectedWifiSignalView()
        }
    }
}
