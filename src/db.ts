// src/db.ts
import { openDatabaseSync, type SQLiteDatabase } from "expo-sqlite";

export const appDb: SQLiteDatabase = openDatabaseSync("sage.sqlite");

export async function runMigrations() {
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

  await appDb.runAsync(
    `INSERT OR IGNORE INTO locations (id,name,kind,created_at) VALUES ('loc_pantry','Pantry','pantry',datetime('now'))`
  );
  await appDb.runAsync(
    `INSERT OR IGNORE INTO locations (id,name,kind,created_at) VALUES ('loc_fridge','Fridge','fridge',datetime('now'))`
  );
  await appDb.runAsync(
    `INSERT OR IGNORE INTO locations (id,name,kind,created_at) VALUES ('loc_freezer','Freezer','freezer',datetime('now'))`
  );
}

export async function execAsync(db: SQLiteDatabase, sql: string, params: any[] = []) {
  if (params.length) return db.runAsync(sql, params);
  return db.execAsync(sql);
}

export async function queryAsync<T = any>(db: SQLiteDatabase, sql: string, params: any[] = []) {
  const rows = await db.getAllAsync<T>(sql, params);
  return rows as T[];
}
