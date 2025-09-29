// src/db.ts  (UPDATED) — helpers: smart upsert, decrement/use, discard, test item
import { openDatabaseSync, type SQLiteDatabase } from "expo-sqlite";
import * as SecureStore from "expo-secure-store";

export const appDb: SQLiteDatabase = openDatabaseSync("sage.sqlite");

export async function runMigrations() {
  await maybeEnableEncryption(appDb);
  await appDb.execAsync(`
    PRAGMA foreign_keys = ON;

    CREATE TABLE IF NOT EXISTS locations (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      kind TEXT CHECK(kind IN ('pantry','fridge','freezer','other')) NOT NULL,
      created_at TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS products (
      id TEXT PRIMARY KEY,
      barcode TEXT UNIQUE,
      name TEXT NOT NULL,
      brand TEXT,
      default_unit TEXT,
      shelf_life_days INTEGER,
      opened_life_days INTEGER,
      image_url TEXT,
      created_at TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS stock (
      id TEXT PRIMARY KEY,
      product_id TEXT,
      location_id TEXT NOT NULL,
      quantity REAL NOT NULL DEFAULT 1,
      unit TEXT,
      acquired_at TEXT,
      opened_at TEXT,
      best_before TEXT,
      use_by TEXT,
      est_expires_at TEXT,
      status TEXT CHECK(status IN ('in_stock','consumed','discarded')) NOT NULL DEFAULT 'in_stock',
      notes TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );

    CREATE INDEX IF NOT EXISTS idx_stock_expiry ON stock(use_by, best_before, est_expires_at);
    CREATE INDEX IF NOT EXISTS idx_stock_status ON stock(status);
  `);

  await appDb.runAsync(`INSERT OR IGNORE INTO locations (id,name,kind,created_at) VALUES ('loc_pantry','Pantry','pantry',datetime('now'))`);
  await appDb.runAsync(`INSERT OR IGNORE INTO locations (id,name,kind,created_at) VALUES ('loc_fridge','Fridge','fridge',datetime('now'))`);
  await appDb.runAsync(`INSERT OR IGNORE INTO locations (id,name,kind,created_at) VALUES ('loc_freezer','Freezer','freezer',datetime('now'))`);
}

export async function execAsync(db: SQLiteDatabase, sql: string, params: any[] = []) {
  if (params.length) return db.runAsync(sql, params);
  return db.execAsync(sql);
}

export async function queryAsync<T = any>(db: SQLiteDatabase, sql: string, params: any[] = []) {
  const rows = await db.getAllAsync<T>(sql, params);
  return rows as T[];
}

// --- Optional SQLCipher encryption for fresh installs ---
const DB_KEY_K = "db_key_hex";

function ssOpts(): SecureStore.SecureStoreOptions | undefined {
  try {
    const supported = (SecureStore as any).canUseBiometricAuthentication?.() ?? false;
    return supported ? { keychainAccessible: SecureStore.WHEN_UNLOCKED_THIS_DEVICE_ONLY } : undefined;
  } catch {
    return undefined;
  }
}

async function getOrCreateDbKeyHex(): Promise<string> {
  const existing = await SecureStore.getItemAsync(DB_KEY_K, ssOpts());
  if (existing) return existing;
  const hex = randomHex(32);
  await SecureStore.setItemAsync(DB_KEY_K, hex, ssOpts());
  return hex;
}

async function maybeEnableEncryption(db: SQLiteDatabase) {
  try {
    const rows = await queryAsync<{ name: string }>(
      db,
      "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('locations','products','stock')"
    );
    if (rows.length > 0) return; // existing DB: skip to avoid breaking upgrades

    const keyHex = await getOrCreateDbKeyHex();
    await execAsync(db, `PRAGMA cipher_compatibility = 4; PRAGMA key = '${keyHex}';`);
    // Best-effort check; unknown pragma when SQLCipher not present returns empty set
    await queryAsync<any>(db, "PRAGMA cipher_version;").catch(() => []);
  } catch {
    // Ignore and continue without encryption
  }
}

function randomHex(bytes: number): string {
  const arr = new Uint8Array(bytes);
  if (globalThis.crypto?.getRandomValues) {
    globalThis.crypto.getRandomValues(arr);
  } else {
    for (let i = 0; i < bytes; i++) arr[i] = Math.floor(Math.random() * 256);
  }
  let out = "";
  for (let i = 0; i < arr.length; i++) out += arr[i].toString(16).padStart(2, "0");
  return out;
}

/** Find product by barcode (if exists) */
export async function findProductByBarcode(barcode: string) {
  const rows = await queryAsync<{ id: string; name: string; brand?: string; default_unit?: string; shelf_life_days?: number|null; image_url?: string|null }>(
    appDb,
    `SELECT id,name,brand,default_unit,shelf_life_days,image_url FROM products WHERE barcode=? LIMIT 1`,
    [barcode]
  );
  return rows[0] ?? null;
}

/** Create product record */
export async function createProduct(p: {
  id?: string; barcode?: string|null; name: string; brand?: string|null; default_unit?: string|null; shelf_life_days?: number|null; image_url?: string|null;
}) {
  const id = p.id ?? ("prd_" + Math.random().toString(36).slice(2,10));
  await execAsync(appDb,
    `INSERT INTO products (id, barcode, name, brand, default_unit, shelf_life_days, image_url, created_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, datetime('now'))`,
    [id, p.barcode ?? null, p.name, p.brand ?? null, p.default_unit ?? null, p.shelf_life_days ?? null, p.image_url ?? null]
  );
  return id;
}

/** Smart upsert: if same product + location + unit + same expiry date → increment quantity; else insert a new row */
export async function upsertStockSmart(params: {
  product_id: string;
  location_id: "loc_pantry"|"loc_fridge"|"loc_freezer";
  unit: string|null;
  quantity: number;
  acquired_at?: string|null;
  best_before?: string|null;
  use_by?: string|null;
  est_expires_at?: string|null;
}) {
  const expiryKey = params.use_by ?? params.best_before ?? params.est_expires_at ?? null;

  const match = await queryAsync<{ id: string; quantity: number }>(
    appDb,
    `SELECT id, quantity
     FROM stock
     WHERE product_id=? AND location_id=? AND status='in_stock'
       AND IFNULL(unit,'') = IFNULL(?, '')
       AND date(COALESCE(use_by, best_before, est_expires_at)) = date(?)`,
    [params.product_id, params.location_id, params.unit ?? null, expiryKey]
  );

  if (match[0]) {
    await execAsync(appDb,
      `UPDATE stock SET quantity = ?, updated_at=datetime('now') WHERE id=?`,
      [match[0].quantity + params.quantity, match[0].id]
    );
    return match[0].id;
  }

  const id = "stk_" + Math.random().toString(36).slice(2,10);
  await execAsync(appDb,
    `INSERT INTO stock (id, product_id, location_id, quantity, unit, acquired_at, best_before, use_by, est_expires_at, status, created_at, updated_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'in_stock', datetime('now'), datetime('now'))`,
    [id, params.product_id, params.location_id, params.quantity, params.unit ?? null, params.acquired_at ?? null,
      params.best_before ?? null, params.use_by ?? null, params.est_expires_at ?? null]
  );
  return id;
}

/** Decrement quantity by 1; if hits 0 → mark consumed */
export async function useOne(stockId: string) {
  const row = (await queryAsync<{ quantity: number }>(appDb, `SELECT quantity FROM stock WHERE id=?`, [stockId]))[0];
  if (!row) return;
  if (row.quantity > 1) {
    await execAsync(appDb, `UPDATE stock SET quantity=quantity-1, updated_at=datetime('now') WHERE id=?`, [stockId]);
  } else {
    await execAsync(appDb, `UPDATE stock SET status='consumed', updated_at=datetime('now') WHERE id=?`, [stockId]);
  }
}

/** Mark whole row discarded */
export async function discardStock(stockId: string) {
  await execAsync(appDb, `UPDATE stock SET status='discarded', updated_at=datetime('now') WHERE id=?`, [stockId]);
}

/** Insert a test product that expires in N days (for Discord tests) */
export async function insertTestItem(daysAhead = 1) {
  const productName = `Sage Test Item`;
  const testBarcode = "0000000000000"; // EAN-13 placeholder
  // ensure product exists (idempotent-ish)
  let prod = await findProductByBarcode(testBarcode);
  const pid = prod?.id ?? await createProduct({
    barcode: testBarcode, name: productName, brand: "Sage", default_unit: "count", shelf_life_days: daysAhead, image_url: null
  });

  const d = new Date();
  d.setDate(d.getDate() + daysAhead);
  const iso = d.toISOString().slice(0,10);

  const id = await upsertStockSmart({
    product_id: pid,
    location_id: "loc_pantry",
    unit: "count",
    quantity: 1,
    acquired_at: new Date().toISOString().slice(0,10),
    best_before: null,
    use_by: iso,
    est_expires_at: null
  });

  return { stock_id: id, product_id: pid, use_by: iso };
}
