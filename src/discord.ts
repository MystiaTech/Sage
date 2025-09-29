// src/discord.ts
import * as SecureStore from "expo-secure-store";
import { appDb, queryAsync } from "./db";

// SecureStore keys must be [A-Za-z0-9._-]+  → no colons.
const KEY = "discord_webhook";

function isValidDiscordWebhook(url: string) {
  const u = url.trim();
  return /^https:\/\/(discord\.com|discordapp\.com)\/api\/webhooks\/\d+\/[A-Za-z0-9_\-]+$/.test(u);
}

export async function setDiscordWebhook(url: string | null) {
  if (!url) return SecureStore.deleteItemAsync(KEY);
  const clean = url.trim();
  if (!isValidDiscordWebhook(clean)) {
    throw new Error("Invalid Discord webhook URL.");
  }
  await SecureStore.setItemAsync(KEY, clean);
}

export async function getDiscordWebhook(): Promise<string | null> {
  return (await SecureStore.getItemAsync(KEY)) ?? null;
}

type ExpiringRow = {
  id: string; name?: string; brand?: string;
  best_before?: string; use_by?: string; est_expires_at?: string;
};

export async function sendExpiringToDiscord(daysAhead = 3) {
  const url = await getDiscordWebhook();
  if (!url) throw new Error("No Discord webhook URL set.");

  const rows = await queryAsync<ExpiringRow>(appDb, `
    SELECT s.id, p.name, p.brand, s.use_by, s.best_before, s.est_expires_at
    FROM stock s
    LEFT JOIN products p ON p.id = s.product_id
    WHERE s.status='in_stock'
      AND date(COALESCE(s.use_by, s.best_before, s.est_expires_at)) <= date('now', ?)
    ORDER BY date(COALESCE(s.use_by, s.best_before, s.est_expires_at)) ASC
    LIMIT 25
  `, [`+${daysAhead} day`]);

  const content =
    rows.length === 0
      ? "✅ Nothing expiring soon."
      : `⚠️ **Sage**: Items expiring within ${daysAhead} days:\n` +
        rows.map(r => {
          const expiry = r.use_by || r.best_before || r.est_expires_at || "n/a";
          const name = r.name ?? "Unnamed item";
          const brand = r.brand ? ` (${r.brand})` : "";
          return `• **${name}**${brand} — *${expiry}*`;
        }).join("\n");

  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ content }),
  });
  if (!res.ok) {
    const txt = await res.text().catch(() => "");
    throw new Error(`Discord error: ${res.status} ${txt}`.trim());
  }
  return { sent: rows.length };
}
