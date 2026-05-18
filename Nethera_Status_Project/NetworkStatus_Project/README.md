# NetworkStatus_Project

Eigenständiges SwiftUI-Demo-Projekt für die Nethera-App.

## Apple Features

Dieses Projekt ersetzt das alte WLAN-Signal-Projekt, weil SSID/BSSID/Signalstärke unter iOS spezielle Berechtigungen bzw. Entitlements benötigen können.

Umgesetzt wurden deshalb Apple-Features, die ohne speziellen Apple Developer Account als lokales SwiftUI-Projekt funktionieren:

1. **Apple Network Framework**
   - Live-Erkennung von Online/Offline
   - Verbindungstyp: WLAN, mobile Daten, Ethernet, Simulator/Lokal
   - Erkennung von begrenzter oder kostenpflichtiger Verbindung

2. **Face ID / Touch ID / Gerätecode**
   - Schutz sensibler Routerdaten
   - WLAN-Passwort, Account-Passwort und Gast-WLAN-Zugang bleiben gesperrt, bis der Nutzer sich authentifiziert

3. **Core Image QR-Code**
   - Generiert lokal einen WLAN-QR-Code für das Gast-WLAN
   - Der QR-Code kann mit der iPhone-Kamera gescannt werden
   - Das iPhone zeigt danach eine Verbindungsmöglichkeit zum WLAN an

4. **UserNotifications**
   - Lokale iOS-Mitteilungen für Router-Warnungen
   - Testmeldungen für Offline, mobile Daten, Router-Sicherheitscheck und neues Gerät als Demo
   - Automatische Warnungen bei Netzwerkänderungen, solange die App aktiv ist oder iOS sie kurzzeitig im Hintergrund weiterlaufen lässt

## Projekt öffnen

`NetworkStatus_Project/NetworkStatus_Project.xcodeproj` in Xcode öffnen.

## Tabs

- **Status**: Netzwerkstatus + Face-ID-geschützte Routerdaten
- **Gast-WLAN**: QR-Code für das Gastnetz
- **Mitteilungen**: lokale iOS-Benachrichtigungen mit Testmeldungen und automatischen Warnungen

## Wichtiger Hinweis zu Mitteilungen

Lokale Mitteilungen können auch erscheinen, wenn die App im Hintergrund ist. Eine sofortige Warnung exakt beim Ausschalten von WLAN ist aber nur realistisch, solange iOS die App noch weiterlaufen lässt. Wenn iOS die App nach längerer Zeit einfriert oder die App komplett beendet wurde, kann sie Netzwerkänderungen nicht dauerhaft überwachen.

Es werden bewusst keine WLAN-SSID, BSSID oder Signalstärke ausgelesen, damit das Projekt ohne spezielle Netzwerk-Entitlements funktioniert.
