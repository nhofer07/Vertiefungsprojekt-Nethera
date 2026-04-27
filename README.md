# Nethera – Projektüberblick

Nethera ist ein iOS-Prototyp für eine Router-/Kindersicherungs-App. Die App zeigt Geräte in Gruppen an, erlaubt Blocklisten für Gruppen und einzelne Geräte und kann Geräteeinstellungen als Presets speichern.

Der Fokus liegt auf einer verständlichen Demo-App mit SwiftUI. Es gibt aktuell keinen echten Router, keine echte Netzwerkverbindung und kein Backend. Die Daten werden lokal am Gerät gespeichert.

---

## Verwendete Technologien

### Swift
Die App ist in Swift geschrieben. Swift ist die Programmiersprache für iOS-Apps. Damit werden Models, Funktionen, Speicherlogik und UI-Logik umgesetzt.

Wichtige Dateien:

- `NetheraApp.swift` – Startpunkt der App
- `ContentView.swift` – Hauptnavigation / Tabs
- `Devices.swift` – Datenmodell für ein Gerät
- `NetheraStorage.swift` – Speichern und Laden von Einstellungen

---

### SwiftUI
SwiftUI wird für die Oberfläche verwendet. Das bedeutet, die UI wird direkt im Code beschrieben.

Beispiele aus dem Projekt:

- `NavigationStack` für Seiten-Navigation
- `ScrollView` und `VStack` für Layouts
- `Button`, `Toggle`, `TextField`, `DatePicker` für Eingaben
- `.sheet(...)` für Popups / Bearbeitungsfenster
- `@State` und `@Binding` für Live-Änderungen in der UI

Wichtige Views:

- `DevicesView.swift` – Geräteübersicht mit Gruppen
- `DeviceDetailView.swift` – Detailseite eines Geräts
- `BlocklistEditorSheet.swift` – Sheet zum Bearbeiten von Blocklisten
- `HomeView.swift` – Startseite
- `SettingsView.swift` – Einstellungen

---

## Wichtige App-Funktionen

### 1. Geräte und Gruppen
In `DevicesView.swift` gibt es eine Liste von Geräten. Jedes Gerät hat eine Gruppe, zum Beispiel `Eltern`, `Kinder` oder `Wohnzimmer`.

Ein Gerät sieht ungefähr so aus:

```swift
struct Device: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var type: String
    var onlineTime: String
    var dataUsage: String
    var group: String
}
```

`Identifiable` ist wichtig, damit SwiftUI Geräte in einer Liste eindeutig erkennen kann.

---

### 2. Gruppen-Blocklisten
Eine Gruppe kann Blocklisten haben, zum Beispiel:

- Glücksspiel
- 18+ Inhalte
- Social Media
- manuelle Domains

Diese Gruppen-Blocklist gilt für alle Geräte in dieser Gruppe.

Wichtig: Die Gruppen-Blocklist wird nicht direkt vom individuellen Gerät verändert. Wenn man bei einem Gerät abweicht, ist das nur eine eigene Einstellung für dieses Gerät.

Die Logik ist:

```text
Wenn Gerät eigene Blocklist hat:
    Gerät verwendet eigene Blocklist
Sonst:
    Gerät verwendet Gruppen-Blocklist
```

Das ist wichtig für eure Erklärung, weil dadurch klar ist:

```text
Individuell > Gruppe
```

---

### 3. Presets
Presets speichern Geräteeinstellungen, damit man sie später wieder anwenden kann.

Ein Preset enthält zum Beispiel:

- Kindersicherung an/aus
- Priorisierung an/aus
- Zeitlimit
- Blocklist-Einstellungen

Im Code heißt das `DevicePreset`.

Wenn ein Preset aktiv ist und man nochmal darauf klickt, soll es wieder deaktiviert werden. Danach gilt wieder die Gruppen-Blocklist, falls es eine gibt.

---

### 4. Lokales Speichern mit UserDefaults
Die App verwendet `UserDefaults`, um Daten lokal zu speichern.

Gespeichert werden zum Beispiel:

- Geräte
- Gruppen
- Geräteeinstellungen
- Presets
- Gruppen-Blocklisten

Da `UserDefaults` eigentlich einfache Daten speichert, werden komplexe Swift-Structs mit `Codable`, `JSONEncoder` und `JSONDecoder` umgewandelt.

Vereinfacht:

```text
Swift-Objekt → JSON → UserDefaults
UserDefaults → JSON → Swift-Objekt
```

Das passiert hauptsächlich in `NetheraStorage.swift`.

---

### 5. Live-Updates
Ein schwieriger Teil war, dass Änderungen sofort sichtbar sein müssen, ohne die App neu zu starten.

SwiftUI aktualisiert sich nur automatisch, wenn sich ein beobachteter State ändert. Deshalb verwendet die App:

- `@State` für lokale Zustände in einer View
- `@Binding` wenn eine Child-View ein Gerät aus der Parent-View ändern soll
- `NotificationCenter`, damit andere Views mitbekommen, wenn sich Gruppen-Blocklisten ändern

Beispiel:

```swift
NotificationCenter.default.post(name: .groupBlocklistDidChange, object: nil)
```

Damit kann `DevicesView` oder `DeviceDetailView` neu laden, wenn eine Gruppen-Blocklist geändert wurde.

---

### 6. Drag & Drop für Geräte
In `DevicesView.swift` gibt es Drag & Drop, damit Geräte zwischen Gruppen verschoben werden können.

Dafür wird `Transferable` verwendet.

```swift
private struct DeviceDragItem: Codable, Transferable {
    let id: UUID
}
```

Die Idee ist simpel:

```text
Gerät ziehen → Geräte-ID übertragen → Zielgruppe bekommt das Gerät
```

---

## Warum manche Dinge schwieriger waren

### Gruppen-Blocklist vs. individuelle Blocklist
Das war wahrscheinlich der komplizierteste Teil.

Eine Gruppe gibt Standard-Regeln vor. Ein Gerät darf aber abweichen. Deshalb darf man Gruppenwerte nicht einfach in jedes Gerät kopieren, sonst wird alles schwer zu kontrollieren.

Besser ist:

```text
Beim Anzeigen prüfen:
Hat das Gerät eigene Regeln?
Ja → eigene Regeln anzeigen
Nein → Gruppenregeln anzeigen
```

Das macht die App logischer und verhindert, dass andere Geräte ungewollt verändert werden.

---

### SwiftUI Refresh
Ein weiteres schwieriges Thema war das Aktualisieren der UI.

Wenn man nur etwas in `UserDefaults` speichert, weiß SwiftUI nicht automatisch, dass sich die Oberfläche ändern soll.

Darum braucht man zusätzlich State-Änderungen, zum Beispiel:

```swift
refreshToken = UUID()
```

oder man ändert direkt eine `@State`-/`@Binding`-Variable.

---

### Preset aktiv erkennen
Ein Preset ist nicht nur ein Name. Damit die App erkennt, ob ein Preset aktiv ist, müssen die gespeicherten Einstellungen mit den aktuellen Geräteeinstellungen verglichen werden.

Das ist fehleranfällig, weil mehrere Werte zusammenpassen müssen:

- Blocklist
- Priorisierung
- Zeitlimit
- Start- und Endzeit
- Kindersicherung

---

## Projektstruktur

```text
Nethera/
├── Components/
│   ├── BlocklistEditorSheet.swift
│   ├── InfoCard.swift
│   ├── PageHeaderView.swift
│   ├── SpeedCard.swift
│   └── StatCard.swift
│
├── Views/
│   ├── DevicesView.swift
│   ├── DeviceDetailView.swift
│   ├── HomeView.swift
│   ├── SettingsView.swift
│   ├── AccountView.swift
│   ├── BlocklistView.swift
│   └── ...
│
├── Devices.swift
├── NetheraStorage.swift
├── ContentView.swift
└── NetheraApp.swift
```

---

## Was wir bei der Präsentation sagen können

Nethera ist ein SwiftUI-Prototyp einer Router-/Kindersicherungs-App. Wir haben Geräte, Gruppen, Gruppen-Blocklisten, individuelle Geräteeinstellungen und Presets umgesetzt. Die Daten werden lokal mit UserDefaults gespeichert. Schwieriger war vor allem die Logik, dass Gruppenregeln automatisch für Geräte gelten, aber individuelle Einstellungen Vorrang haben. Zusätzlich mussten wir Live-Updates lösen, damit Änderungen sofort sichtbar werden und nicht erst nach einem Neustart.

---

## Einschätzung

Für ein HTL-Projekt nach ungefähr einem halben Jahr Unterricht ist das Projekt stark. Ihr verwendet schon einige Konzepte, die nicht ganz trivial sind:

- SwiftUI Navigation
- eigene Components
- lokale Speicherung
- Codable / JSON
- State Management mit `@State` und `@Binding`
- einfache App-Architektur
- Drag & Drop
- Vererbungslogik zwischen Gruppe und Gerät

Was noch verbessert werden könnte:

- weniger Logik direkt in den Views
- langfristig ein eigenes ViewModel verwenden
- UserDefaults später durch eine richtige Datenbank ersetzen, zum Beispiel SwiftData
- Kommentare bei komplizierten Funktionen ergänzen
- Xcode-Userfiles aus Git entfernen bzw. ignorieren

Für euren aktuellen Stand ist die Lösung aber passend. Sie ist nicht übertrieben komplex und man kann sie gut erklären. Wichtig ist, dass ihr bei der Präsentation ehrlich sagt, dass es ein Prototyp ist und keine echte Router-App mit echter Netzwerksperre.

---

## Kurzfassung für Lehrer

Die App wurde mit Swift und SwiftUI entwickelt. Geräte und Gruppen werden lokal gespeichert. Gruppen können Blocklisten haben, die automatisch für alle Geräte der Gruppe gelten. Einzelne Geräte können diese Regeln überschreiben, weil individuelle Einstellungen Vorrang vor Gruppeneinstellungen haben. Presets speichern komplette Geräteeinstellungen und können später wieder angewendet oder deaktiviert werden. Für Live-Aktualisierungen verwenden wir SwiftUI-State und NotificationCenter.
