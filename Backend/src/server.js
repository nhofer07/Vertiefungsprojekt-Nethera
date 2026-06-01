import cors from "cors";
import dotenv from "dotenv";
import express from "express";
import { getDb } from "./db.js";

dotenv.config();

const app = express();
const port = Number(process.env.PORT ?? 3001);

app.use(cors());
app.use(express.json({ limit: "1mb" }));

function withoutMongoID(item) {
  if (!item || typeof item !== "object") return item;
  const { _id, ...rest } = item;
  return rest;
}

function uniqueByID(items) {
  const byID = new Map();
  for (const rawItem of items) {
    const item = withoutMongoID(rawItem);
    if (item?.id) {
      byID.set(item.id, item);
    }
  }
  return Array.from(byID.values());
}

function uniqueGroups(groups) {
  return Array.from(new Set(groups.filter((name) => typeof name === "string" && name.trim() !== "").map((name) => name.trim())));
}

function asyncRoute(handler) {
  return (request, response, next) => {
    Promise.resolve(handler(request, response, next)).catch(next);
  };
}

async function loadGroups(db) {
  const groupDocs = await db.collection("groups").find({}, { projection: { _id: 0 } }).sort({ order: 1 }).toArray();
  if (groupDocs.length > 0) {
    return groupDocs.map((group) => group.name).filter(Boolean);
  }

  const meta = await db.collection("meta").findOne({ key: "groups" }, { projection: { _id: 0 } });
  return meta?.value ?? [];
}

async function saveGroups(db, groups) {
  const cleanedGroups = uniqueGroups(groups);
  await db.collection("groups").deleteMany({});
  if (cleanedGroups.length > 0) {
    await db.collection("groups").insertMany(cleanedGroups.map((name, order) => ({ name, order })));
  }
}

async function loadRouterSettings(db) {
  const settings = await db.collection("routerSettings").findOne({ key: "main" }, { projection: { _id: 0 } });
  if (settings) {
    const { key, ...value } = settings;
    return value;
  }

  const meta = await db.collection("meta").findOne({ key: "routerSettings" }, { projection: { _id: 0 } });
  return meta?.value ?? null;
}

async function loadGlobalBlocklist(db) {
  const blocklist = await db.collection("globalBlocklist").findOne({ key: "main" }, { projection: { _id: 0 } });
  return blocklist?.profile ?? {
    gamblingEnabled: false,
    adultEnabled: false,
    socialEnabled: false,
    manualDomains: []
  };
}

async function loadAdBlockDomains(db) {
  const adBlock = await db.collection("adBlockDomains").findOne({ key: "main" }, { projection: { _id: 0 } });
  return adBlock?.domains ?? [
    { id: crypto.randomUUID(), name: "googleads.g.doubleclick.net", time: "2m" },
    { id: crypto.randomUUID(), name: "connect.facebook.com", time: "4m" },
    { id: crypto.randomUUID(), name: "stats.g.doubleclick.net", time: "17m" },
    { id: crypto.randomUUID(), name: "adservice.google.com", time: "29m" }
  ];
}

async function saveRouterSettings(db, routerSettings) {
  await db.collection("routerSettings").updateOne(
    { key: "main" },
    { $set: { key: "main", ...routerSettings } },
    { upsert: true }
  );
}

async function saveGlobalBlocklist(db, profile) {
  await db.collection("globalBlocklist").updateOne(
    { key: "main" },
    { $set: { key: "main", profile } },
    { upsert: true }
  );
}

async function saveAdBlockDomains(db, domains) {
  await db.collection("adBlockDomains").updateOne(
    { key: "main" },
    { $set: { key: "main", domains } },
    { upsert: true }
  );
}

function presetInfoForSettings(settings, presetsByID) {
  const activePresetID = settings?.activePresetID ?? null;
  return {
    activePresetID,
    activePresetName: activePresetID ? presetsByID.get(activePresetID)?.name ?? null : null
  };
}

function enrichDevicesWithPresetInfo(devices, deviceSettings, presets) {
  const settingsByDeviceID = new Map(deviceSettings.map((item) => [item.deviceID, item.settings]));
  const presetsByID = new Map(presets.map((preset) => [preset.id, preset]));

  return devices.map((device) => ({
    ...device,
    ...presetInfoForSettings(settingsByDeviceID.get(device.id), presetsByID)
  }));
}

async function syncDevicePresetInfo(db, deviceID, settings) {
  const presets = await db.collection("presets").find({}, { projection: { _id: 0 } }).toArray();
  const presetsByID = new Map(presets.map((preset) => [preset.id, preset]));
  const presetInfo = presetInfoForSettings(settings, presetsByID);

  await db.collection("devices").updateOne(
    { id: deviceID },
    { $set: presetInfo }
  );
}

async function syncAllDevicePresetInfo(db) {
  const [devices, deviceSettings, presets] = await Promise.all([
    db.collection("devices").find({}, { projection: { _id: 0 } }).toArray(),
    db.collection("deviceSettings").find({}, { projection: { _id: 0 } }).toArray(),
    db.collection("presets").find({}, { projection: { _id: 0 } }).toArray()
  ]);
  const enrichedDevices = enrichDevicesWithPresetInfo(devices, deviceSettings, presets);

  await db.collection("devices").deleteMany({});
  if (enrichedDevices.length > 0) {
    await db.collection("devices").insertMany(enrichedDevices);
  }

  return enrichedDevices;
}

app.get("/health", asyncRoute(async (_request, response) => {
  await getDb();
  response.json({ ok: true, database: "mongodb" });
}));

app.get("/api/state", asyncRoute(async (_request, response) => {
  const db = await getDb();
  const [devices, groups, routerSettings, globalBlocklist, adBlockDomains, deviceSettings, presets, groupBlocklists] = await Promise.all([
    db.collection("devices").find({}, { projection: { _id: 0 } }).toArray(),
    loadGroups(db),
    loadRouterSettings(db),
    loadGlobalBlocklist(db),
    loadAdBlockDomains(db),
    db.collection("deviceSettings").find({}, { projection: { _id: 0 } }).toArray(),
    db.collection("presets").find({}, { projection: { _id: 0 } }).toArray(),
    db.collection("groupBlocklists").find({}, { projection: { _id: 0 } }).toArray()
  ]);

  response.json({
    devices: enrichDevicesWithPresetInfo(devices, deviceSettings, presets),
    groups,
    deviceSettings: Object.fromEntries(deviceSettings.map((item) => [item.deviceID, item.settings])),
    presets,
    groupBlocklists: Object.fromEntries(groupBlocklists.map((item) => [item.group, item.profile])),
    globalBlocklist,
    adBlockDomains,
    routerSettings
  });
}));

app.put("/api/devices", asyncRoute(async (request, response) => {
  const devices = uniqueByID(Array.isArray(request.body?.devices) ? request.body.devices : []);
  const db = await getDb();
  const [deviceSettings, presets] = await Promise.all([
    db.collection("deviceSettings").find({}, { projection: { _id: 0 } }).toArray(),
    db.collection("presets").find({}, { projection: { _id: 0 } }).toArray()
  ]);
  const enrichedDevices = enrichDevicesWithPresetInfo(devices, deviceSettings, presets);

  await db.collection("devices").deleteMany({});
  if (enrichedDevices.length > 0) {
    await db.collection("devices").insertMany(enrichedDevices);
  }
  response.json({ ok: true, count: enrichedDevices.length });
}));

app.put("/api/groups", asyncRoute(async (request, response) => {
  const groups = uniqueGroups(Array.isArray(request.body?.groups) ? request.body.groups : []);
  const db = await getDb();
  await saveGroups(db, groups);
  response.json({ ok: true, count: groups.length });
}));

app.put("/api/router-settings", asyncRoute(async (request, response) => {
  const routerSettings = request.body?.routerSettings ?? {};
  const db = await getDb();
  await saveRouterSettings(db, routerSettings);
  response.json({ ok: true });
}));

app.put("/api/global-blocklist", asyncRoute(async (request, response) => {
  const profile = request.body?.profile ?? {};
  const db = await getDb();
  await saveGlobalBlocklist(db, profile);
  response.json({ ok: true });
}));

app.put("/api/adblock-domains", asyncRoute(async (request, response) => {
  const domains = Array.isArray(request.body?.domains) ? request.body.domains : [];
  const db = await getDb();
  await saveAdBlockDomains(db, domains);
  response.json({ ok: true, count: domains.length });
}));

app.put("/api/device-settings/:deviceID", asyncRoute(async (request, response) => {
  const db = await getDb();
  const settings = request.body?.settings ?? {};
  await db.collection("deviceSettings").updateOne(
    { deviceID: request.params.deviceID },
    { $set: { deviceID: request.params.deviceID, settings } },
    { upsert: true }
  );
  await syncDevicePresetInfo(db, request.params.deviceID, settings);
  response.json({ ok: true });
}));

app.delete("/api/device-settings/:deviceID", asyncRoute(async (request, response) => {
  const db = await getDb();
  await db.collection("deviceSettings").deleteOne({ deviceID: request.params.deviceID });
  await syncDevicePresetInfo(db, request.params.deviceID, {});
  response.json({ ok: true });
}));

app.put("/api/presets", asyncRoute(async (request, response) => {
  const presets = uniqueByID(Array.isArray(request.body?.presets) ? request.body.presets : []);
  const db = await getDb();
  await db.collection("presets").deleteMany({});
  if (presets.length > 0) {
    await db.collection("presets").insertMany(presets);
  }
  await syncAllDevicePresetInfo(db);
  response.json({ ok: true, count: presets.length });
}));

app.put("/api/group-blocklists/:group", asyncRoute(async (request, response) => {
  const db = await getDb();
  await db.collection("groupBlocklists").updateOne(
    { group: request.params.group },
    { $set: { group: request.params.group, profile: request.body?.profile ?? {} } },
    { upsert: true }
  );
  response.json({ ok: true });
}));

app.delete("/api/group-blocklists/:group", asyncRoute(async (request, response) => {
  const db = await getDb();
  await db.collection("groupBlocklists").deleteOne({ group: request.params.group });
  response.json({ ok: true });
}));

app.use((error, _request, response, _next) => {
  console.error(error);
  response.status(500).json({ ok: false, error: error.message });
});

try {
  await getDb();
  app.listen(port, () => {
    console.log(`Nethera MongoDB backend listening on http://localhost:${port}`);
  });
} catch (error) {
  console.error("MongoDB ist nicht erreichbar.");
  console.error("Starte zuerst MongoDB oder passe MONGODB_URI in Backend/.env an.");
  console.error(`Aktueller Fehler: ${error.message}`);
  process.exit(1);
}
