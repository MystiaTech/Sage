// src/discord.ts
import * as SecureStore from "expo-secure-store";
import { appDb, queryAsync } from "./db";

// SecureStore keys must be [A-Za-z0-9._-]+
const KEY = "discord_webhook";

function isValidDiscordWebhook(url: string) {
  const u = url.trim();
  return /^https:\/\/(discord\.com|discordapp\.com)\/api\/webhooks\/\d+\/[A-Za-z0-9_\-]+$/.test(u);
}

function secureStoreOptions(): SecureStore.SecureStoreOptions | undefined {
  const supportsAuth = (SecureStore as any).canUseBiometricAuthentication?.() ?? false;
  if (!supportsAuth) return undefined;
  return {
    requireAuthentication: true,
    authenticationPrompt: "Authenticate to access Discord webhook",
    keychainAccessible: SecureStore.WHEN_UNLOCKED_THIS_DEVICE_ONLY,
  };
}

export async function setDiscordWebhook(url: string | null) {
  if (!url) return SecureStore.deleteItemAsync(KEY, secureStoreOptions());
  const clean = url.trim();
  if (!isValidDiscordWebhook(clean)) {
    throw new Error("Invalid Discord webhook URL.");
  }
  await SecureStore.setItemAsync(KEY, clean, secureStoreOptions());
}

export async function getDiscordWebhook(): Promise<string | null> {
  try {
    return (await SecureStore.getItemAsync(KEY, secureStoreOptions())) ?? null;
  } catch {
    // Keys can be invalidated when biometrics/passcode change
    return null;
  }
}

type ExpiringRow = {
  id: string;
  name?: string;
  brand?: string;
  best_before?: string;
  use_by?: string;
  est_expires_at?: string;
};

export async function sendExpiringToDiscord(daysAhead = 3) {
  const url = await getDiscordWebhook();
  if (!url) throw new Error("No Discord webhook URL set.");

  const rows = await queryAsync<ExpiringRow>(
    appDb,
    `
    SELECT s.id, p.name, p.brand, s.use_by, s.best_before, s.est_expires_at
    FROM stock s
    LEFT JOIN products p ON p.id = s.product_id
    WHERE s.status='in_stock'
      AND date(COALESCE(s.use_by, s.best_before, s.est_expires_at)) <= date('now', ?)
    ORDER BY date(COALESCE(s.use_by, s.best_before, s.est_expires_at)) ASC
    LIMIT 25
  `,
    [`+${daysAhead} day`]
  );

  const header = `Sage: Items expiring within ${daysAhead} days:\n`;
  const body = rows
    .map((r) => {
      const expiry = r.use_by || r.best_before || r.est_expires_at || "n/a";
      const name = r.name ?? "Unnamed item";
      const brand = r.brand ? ` (${r.brand})` : "";
      return `• **${escapeMarkdown(name)}**${escapeMarkdown(brand)} — *${escapeMarkdown(expiry)}*`;
    })
    .join("\n");

  let content = rows.length === 0 ? "Nothing expiring soon." : header + body;
  content = trimToDiscordLimit(content);

  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    // Disable all mentions to prevent @everyone/@here/user/role pings.
    body: JSON.stringify({ content, allowed_mentions: { parse: [] } }),
  });
  if (!res.ok) {
    const txt = await res.text().catch(() => "");
    throw new Error(`Discord error: ${res.status} ${txt}`.trim());
  }
  return { sent: rows.length };
}

// --- helpers ---
function escapeMarkdown(s: string): string {
  return s.replace(/[\\_*`~|>]/g, (m) => `\\${m}`);
}

function trimToDiscordLimit(s: string, max = 2000): string {
  if (s.length <= max) return s;
  const slice = s.slice(0, max - 1);
  const idx = slice.lastIndexOf("\n");
  return (idx > 0 ? slice.slice(0, idx) : slice) + "\u2026";
}

