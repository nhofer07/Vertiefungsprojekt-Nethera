import { getDb } from "./db.js";

const devices = [
  { id: crypto.randomUUID(), name: "iPhone von Nico", type: "iphone.homebutton", onlineTime: "12h", dataUsage: "57 GB", group: "Eltern" },
  { id: crypto.randomUUID(), name: "MacBook Nico", type: "laptopcomputer", onlineTime: "5h", dataUsage: "12 GB", group: "Eltern" },
  { id: crypto.randomUUID(), name: "Annas iPhone", type: "iphone", onlineTime: "6h", dataUsage: "4 GB", group: "Kinder" },
  { id: crypto.randomUUID(), name: "Lenas iPad", type: "ipad", onlineTime: "2h", dataUsage: "3 GB", group: "Kinder" },
  { id: crypto.randomUUID(), name: "PlayStation", type: "gamecontroller", onlineTime: "1h", dataUsage: "5 GB", group: "Wohnzimmer" },
  { id: crypto.randomUUID(), name: "Smart TV", type: "tv", onlineTime: "3h", dataUsage: "8 GB", group: "Wohnzimmer" },
  { id: crypto.randomUUID(), name: "Drucker Büro", type: "printer", onlineTime: "22m", dataUsage: "40 MB", group: "Eltern" },
  { id: crypto.randomUUID(), name: "Gast iPhone", type: "iphone", onlineTime: "8m", dataUsage: "120 MB", group: "Nicht zugeordnet" },
  { id: crypto.randomUUID(), name: "Tobis iPad", type: "ipad", onlineTime: "8m", dataUsage: "120 MB", group: "Nicht zugeordnet" }
];

const groups = ["Eltern", "Kinder", "Wohnzimmer", "Nicht zugeordnet", "Ignoriert"];

const routerSettings = {
  wifiName: "Nethera",
  password: "27N!G?4",
  guestPassword: "0N-Gast0",
  notifications: true,
  darkMode: true,
  frequency: "5 GHz",
  firewall: true
};

const presets = [
  {
    id: crypto.randomUUID(),
    name: "Schultag",
    isEnabled: false,
    parentalControl: true,
    prioritized: false,
    timeLimitEnabled: true,
    startTime: 802033200,
    endTime: 802076400,
    blocklist: {
      gamblingEnabled: true,
      adultEnabled: true,
      socialEnabled: true,
      manualDomains: ["youtube.com", "tiktok.com"]
    }
  },
  {
    id: crypto.randomUUID(),
    name: "Hausaufgaben",
    isEnabled: false,
    parentalControl: true,
    prioritized: true,
    timeLimitEnabled: true,
    startTime: 802044000,
    endTime: 802051200,
    blocklist: {
      gamblingEnabled: false,
      adultEnabled: true,
      socialEnabled: true,
      manualDomains: []
    }
  },
  {
    id: crypto.randomUUID(),
    name: "Abendruhe",
    isEnabled: false,
    parentalControl: true,
    prioritized: false,
    timeLimitEnabled: true,
    startTime: 802080000,
    endTime: 802116000,
    blocklist: {
      gamblingEnabled: true,
      adultEnabled: true,
      socialEnabled: true,
      manualDomains: ["netflix.com"]
    }
  }
];

let db;
try {
  db = await getDb();
} catch (error) {
  console.error("MongoDB ist nicht erreichbar.");
  console.error("Starte zuerst MongoDB oder passe MONGODB_URI in Backend/.env an.");
  console.error(`Aktueller Fehler: ${error.message}`);
  process.exit(1);
}
const devicesCount = await db.collection("devices").countDocuments();
const presetsCount = await db.collection("presets").countDocuments();
const groupsCount = await db.collection("groups").countDocuments();
const routerSettingsCount = await db.collection("routerSettings").countDocuments();
const groupsMeta = await db.collection("meta").findOne({ key: "groups" });
const routerSettingsMeta = await db.collection("meta").findOne({ key: "routerSettings" });

function uniqueGroups(input) {
  return Array.from(new Set(input.filter((name) => typeof name === "string" && name.trim() !== "").map((name) => name.trim())));
}

function enrichDevicesWithPresetInfo(devices, deviceSettings, presets) {
  const settingsByDeviceID = new Map(deviceSettings.map((item) => [item.deviceID, item.settings]));
  const presetsByID = new Map(presets.map((preset) => [preset.id, preset]));

  return devices.map((device) => {
    const settings = settingsByDeviceID.get(device.id);
    const activePresetID = settings?.activePresetID ?? null;
    return {
      ...device,
      activePresetID,
      activePresetName: activePresetID ? presetsByID.get(activePresetID)?.name ?? null : null
    };
  });
}

if (devicesCount === 0) {
  await db.collection("devices").insertMany(devices);
  console.log("Demo-Geräte eingefügt.");
} else {
  console.log("Geräte bleiben unverändert.");
}

if (presetsCount === 0) {
  await db.collection("presets").insertMany(presets);
  console.log("Demo-Presets eingefügt.");
} else {
  console.log("Presets bleiben unverändert.");
}

if (groupsCount === 0) {
  const sourceGroups = uniqueGroups(groupsMeta?.value ?? groups);
  if (sourceGroups.length > 0) {
    await db.collection("groups").insertMany(sourceGroups.map((name, order) => ({ name, order })));
    console.log("Gruppen eingefügt.");
  } else {
    console.log("Keine Gruppen zum Einfügen gefunden.");
  }
} else {
  console.log("Gruppen bleiben unverändert.");
}

if (routerSettingsCount === 0) {
  const sourceSettings = routerSettingsMeta?.value ?? routerSettings;
  await db.collection("routerSettings").updateOne(
    { key: "main" },
    { $set: { key: "main", ...sourceSettings } },
    { upsert: true }
  );
  console.log("Router-Einstellungen eingefügt.");
} else {
  console.log("Router-Einstellungen bleiben unverändert.");
}

const currentDevices = await db.collection("devices").find({}, { projection: { _id: 0 } }).toArray();
if (currentDevices.length > 0) {
  const currentDeviceSettings = await db.collection("deviceSettings").find({}, { projection: { _id: 0 } }).toArray();
  const currentPresets = await db.collection("presets").find({}, { projection: { _id: 0 } }).toArray();
  const enrichedDevices = enrichDevicesWithPresetInfo(currentDevices, currentDeviceSettings, currentPresets);

  await db.collection("devices").deleteMany({});
  await db.collection("devices").insertMany(enrichedDevices);
  console.log("Aktive Presets bei Geräten aktualisiert.");
}

console.log("MongoDB seed fertig, vorhandene Daten wurden nicht überschrieben.");
process.exit(0);
