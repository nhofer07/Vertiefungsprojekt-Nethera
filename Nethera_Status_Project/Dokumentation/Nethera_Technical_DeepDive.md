# Nethera – Technical Deep Dive (Intern)

## 🧠 Architektur

Wir verwenden:
- SwiftUI (UI Framework)
- einfache MVVM Struktur

### Aufbau:
- Views: DeviceDetailView, DevicesView, HomeView
- Models: Device, Group
- Storage: NetheraStorage (UserDefaults)

---

## 🔁 State Management

### Verwendet:
- @State
- @Binding

### Beispiel:
```swift
@Binding var device: Device
```

👉 Änderungen an device aktualisieren sofort die UI.

### Wichtig:
UserDefaults alleine updated NICHT die UI.

```swift
// FALSCH
storage.save(...)

// RICHTIG
device.activePresetId = preset.id
```

---

## 💾 Daten speichern

### Methode:
UserDefaults

```swift
UserDefaults.standard.set(value, forKey: "key")
```

### Bewertung:
+ einfach
- nicht skalierbar
- kein echtes Backend

---

## ⚙️ Preset Logik

### Regel:
Individuell > Gruppe

### Umsetzung:
```swift
func isActive(type: String) -> Bool {
    if device.disabledFromGroup.contains(type) {
        return false
    }
    return device.blocklists.contains(type)
        || group.blocklists.contains(type)
}
```

---

## 🔄 UI Update Problem (wichtig)

Problem:
UI updated erst nach Restart

Grund:
State wurde nicht verändert

Fix:
```swift
device.activePresetId = preset.id
```

---

## 🔧 Navigation & Refresh

Problem:
Geräteübersicht updated nicht

Fix:
```swift
.onDisappear {
    refreshToken = UUID()
}
```

---

## 🎨 UI Entscheidungen

- Weniger Farben (ruhiger Look)
- Kein Sheet-in-Sheet
- Presets auf eigene Seite
- Toggle statt Checkmark

---

## 🧪 Reset Feature

Reset setzt alles zurück auf Gruppenblocklist:

```swift
device.blocklists = []
device.disabledFromGroup = []
device.activePresetId = nil
```

---

## ⚠️ Typische Fehler

- UI reagiert nicht → State Problem
- Daten stimmen, UI falsch → Binding fehlt
- Git Konflikte → Rebase nicht fertig

---

## 🧠 Einschätzung

Für 17 Jahre + 0.5 Jahr Unterricht:

🔥 Sehr stark:
- komplexe Logik verstanden
- State Management halb korrekt
- echte UX Entscheidungen

🛠 Verbesserung:
- weniger Logik in Views
- mehr Struktur (ViewModel optional)

---

## 🚀 Fazit

Ihr habt:
- funktionierende Logik
- saubere UX Ideen
- gutes Verständnis von State

👉 Das ist über Schulniveau.
