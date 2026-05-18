# Änderungen: NetworkStatus_Project

Neu angelegt wurde ein eigenständiges SwiftUI-Projekt:

`NetworkStatus_Project/NetworkStatus_Project.xcodeproj`

## Enthaltene Apple-Features

- **Network Framework**: Live-Status für Online/Offline, WLAN, mobile Daten, Ethernet und begrenzte Verbindung.
- **LocalAuthentication**: Face ID / Touch ID / Gerätecode schützt WLAN-Passwort, Account-Passwort und Gast-WLAN-Zugang.
- **Core Image**: Erzeugt einen WLAN-QR-Code für das Gast-WLAN.
- **UserNotifications**: Lokale iOS-Mitteilungen für Router-Warnungen und Demo-Meldungen.

## Tabs

1. **Status**
   - Netzwerkstatus
   - Router-Hinweis
   - geschützte Routerdaten

2. **Gast-WLAN**
   - Gastnetz-Daten
   - Face-ID-geschützter QR-Code

3. **Mitteilungen**
   - Mitteilungsberechtigung anfragen
   - automatische Warnungen bei Netzwerkänderungen aktivieren/deaktivieren
   - Test-Mitteilungen für Offline, mobile Daten, Router-Check und neues Gerät als Demo

## Technischer Hinweis

Die automatischen Mitteilungen bei Netzwerkänderungen funktionieren, solange die App aktiv ist oder iOS sie im Hintergrund noch weiterlaufen lässt. Eine dauerhafte WLAN-Überwachung im Hintergrund wird ohne spezielle Rechte bewusst nicht versprochen.
