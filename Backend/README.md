# Nethera Backend

Kleines MongoDB-Backend für Geräte, Gruppen, Presets und Blocklists.

## Start

```bash
cd Backend
npm install
cp .env.example .env
brew tap mongodb/brew
brew install mongodb-community
brew services start mongodb-community
npm run seed
npm run dev
```

Falls MongoDB schon anders läuft, einfach `MONGODB_URI` in `.env` anpassen.

API läuft dann auf:

```text
http://localhost:3001
```

Für iPhone-Simulator geht `localhost`. Für ein echtes iPhone muss in der App später die Mac-IP eingetragen werden, z. B. `http://192.168.0.10:3001`.
