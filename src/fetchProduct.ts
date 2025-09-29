// src/fetchProduct.ts  (UPDATED) — use normalization + robust lookup attempts
import { normalizeBarcode } from "./barcode";

type ProductInfo = {
  name?: string;
  brand?: string;
  imageUrl?: string;
  shelfLifeDays?: number | null;
};

const HINTS: Array<{ match: RegExp; days: number }> = [
  { match: /\bmilk\b|yogurt|kefir|cream|half[-\s]?and[-\s]?half|fresh\s*juice/i, days: 7 },
  { match: /ground\s*(beef|turkey|pork)|mince|raw\s*meat/i, days: 2 },
  { match: /chicken|poultry|fish|seafood/i, days: 2 },
  { match: /\bbeef\b|\bpork\b|\blamb\b(?!.*ground)/i, days: 4 },
  { match: /deli\s*meat|cold\s*cuts|ham|turkey\s*breast/i, days: 5 },
  { match: /soft\s*cheese|ricotta|cottage\s*cheese|cream\s*cheese/i, days: 7 },
  { match: /hard\s*cheese|cheddar|parmesan|gouda/i, days: 28 },
  { match: /eggs?/i, days: 21 },
  { match: /bagged\s*salad|spring\s*mix|greens|lettuce|spinach|herbs/i, days: 4 },
  { match: /bread|bakery|bagel|rolls/i, days: 5 },
  { match: /berries|strawberries|raspberries|blueberries/i, days: 4 },
  { match: /ready[-\s]?to[-\s]?eat|prepared\s*meals|leftovers/i, days: 3 },
];

async function tryOFF(code: string) {
  const url = `https://world.openfoodfacts.org/api/v2/product/${encodeURIComponent(code)}.json`;
  const res = await fetch(url);
  if (!res.ok) return null;
  const data = await res.json();
  if (!data?.product) return null;
  return data.product;
}

export async function fetchProductByBarcode(raw: string): Promise<ProductInfo | null> {
  const norm = normalizeBarcode(raw);

  // Try all variants until one returns
  let p: any = null;
  for (const variant of norm.tryList) {
    try {
      // OFF has country mirrors; base domain usually fine
      p = await tryOFF(variant);
      if (p) break;
    } catch {}
  }
  if (!p) return null;

  const name: string | undefined =
    p.product_name || p.generic_name || p.product_name_en || undefined;
  const brand: string | undefined = (p.brands || "").split(",")[0]?.trim() || undefined;
  const imageUrl: string | undefined =
    p.image_front_url || p.image_url || p.image_small_url || undefined;

  const cat = [p.categories, ...(p.categories_tags || []), p.labels, p.ingredients_text, name]
    .filter(Boolean)
    .join(", ");
  const hint = HINTS.find((h) => h.match.test(cat));
  const shelfLifeDays = hint?.days ?? null;

  return { name, brand, imageUrl, shelfLifeDays };
}
