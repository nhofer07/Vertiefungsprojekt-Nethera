import dotenv from "dotenv";
import { MongoClient } from "mongodb";

dotenv.config();

const uri = process.env.MONGODB_URI ?? "mongodb://127.0.0.1:27017";
const dbName = process.env.MONGODB_DB ?? "nethera";

const client = new MongoClient(uri);
let db;

// baut die mongodb-verbindung einmal auf und nutzt sie danach wieder:
export async function getDb() {
  if (!db) {
    await client.connect();
    db = client.db(dbName);
    await ensureIndexes(db);
  }
  return db;
}

// verhindert doppelte ids und macht die collections stabiler:
async function ensureIndexes(database) {
  await database.collection("devices").createIndex({ id: 1 }, { unique: true });
  await database.collection("deviceSettings").createIndex({ deviceID: 1 }, { unique: true });
  await database.collection("presets").createIndex({ id: 1 }, { unique: true });
  await database.collection("groupBlocklists").createIndex({ group: 1 }, { unique: true });
  await database.collection("groups").createIndex({ name: 1 }, { unique: true });
  await database.collection("routerSettings").createIndex({ key: 1 }, { unique: true });
  await database.collection("accountSettings").createIndex({ key: 1 }, { unique: true });
}
