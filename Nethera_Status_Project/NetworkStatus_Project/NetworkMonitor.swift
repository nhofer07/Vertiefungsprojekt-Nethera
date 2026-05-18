import Foundation
import Combine
import Network

@MainActor
final class NetworkMonitor: ObservableObject {
    @Published var isConnected = false
    @Published var connectionType = "Unbekannt"
    @Published var isExpensive = false
    @Published var isConstrained = false
    @Published var statusText = "Wird geprüft ..."
    @Published var routerHint = "Der aktuelle Netzwerkstatus wird geladen."

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkStatusProject.Monitor")

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.update(with: path)
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }

    private func update(with path: NWPath) {
        isConnected = path.status == .satisfied
        isExpensive = path.isExpensive
        isConstrained = path.isConstrained

        if path.usesInterfaceType(.wifi) {
            connectionType = "WLAN"
        } else if path.usesInterfaceType(.cellular) {
            connectionType = "Mobile Daten"
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = "Ethernet"
        } else if path.usesInterfaceType(.loopback) {
            connectionType = "Simulator / Lokal"
        } else {
            connectionType = "Unbekannt"
        }

        statusText = isConnected ? "Online" : "Offline"
        routerHint = makeRouterHint()
    }

    private func makeRouterHint() -> String {
        guard isConnected else {
            return "Keine Internetverbindung erkannt. Prüfe Router, WLAN oder mobile Verbindung."
        }

        if connectionType == "WLAN" {
            if isConstrained {
                return "Du bist im WLAN, aber iOS meldet eine eingeschränkte Verbindung. Routerfunktionen könnten langsamer reagieren."
            }
            return "Du bist mit einem WLAN verbunden. Routerfunktionen und lokale Netzwerkchecks sind sinnvoll verfügbar."
        }

        if connectionType == "Mobile Daten" {
            return "Du bist über mobile Daten online. Für Routerfunktionen solltest du dich mit deinem Heim-WLAN verbinden."
        }

        if connectionType == "Ethernet" {
            return "Du bist per Ethernet verbunden. Das ist für Router- und Netzwerkdiagnosen sehr stabil."
        }

        return "Die Verbindung ist online, der genaue Netzwerktyp wurde aber nicht eindeutig erkannt."
    }
}
