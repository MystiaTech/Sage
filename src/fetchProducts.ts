// src/fetchProduct.ts  (NEW) — auto-fill from Open Food Facts + simple shelf-life heuristics
type ProductInfo = {
  name?: string;
  brand?: string;
  imageUrl?: string;
  shelfLifeDays?: number | null;   // heuristic
};

const CAT_HINTS: Array<{ match: RegExp; days: number }> = [
  { match: /milk|yogurt|fresh\s*juice|cream/i, days: 7 },
  { match: /meat|poultry|fish|seafood/i, days: 2 },
  { match: /bread|bakery/i, days: 5 },
  { match: /salad|greens|herbs/i, days: 4 },
  { match: /cheese/i, days: 14 },
  { match: /eggs?/i, days: 21 },
];

export async function fetchProductByBarcode(barcode: string): Promise<ProductInfo | null> {
  try {
    const res = await fetch(`https://world.openfoodfacts.org/api/v2/product/${encodeURIComponent(barcode)}.json`);
    if (!res.ok) return null;
    const data = await res.json();
    if (!data?.product) return null;

    const p = data.product;
    const name: string | undefined = p.product_name || p.generic_name || undefined;
    const brand: string | undefined = (p.brands || "").split(",")// src/fetchProduct.ts  (UPDATED) — stronger shelf-life hints
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

export async function fetchProductByBarcode(barcode: string): Promise<ProductInfo | null> {
  try {
    const res = await fetch(`https://world.openfoodfacts.org/api/v2/product/${encodeURIComponent(barcode)}.json`);
    if (!res.ok) return null;
    const data = await res.json();
    if (!data?.product) return null;

    const p = data.product;
    const name: string | undefined = p.product_name || p.generic_name || p.product_name_en || undefined;
    const brand: string | undefined = (p.brands || "").split(",")[0]?.trim() || undefined;
    const imageUrl: string | undefined = p.image_front_url || p.image_url || p.image_small_url || undefined;

    const cat = [p.categories, ...(p.categories_tags || []), p.labels, p.ingredients_text, name].filter(Boolean).join(", ");
    const hint = HINTS.find(h => h.match.test(cat));
    const shelfLifeDays = hint?.days ?? null;

    return { name, brand, imageUrl, shelfLifeDays };
  } catch {
    return null;
  }
}
[0]?.trim() || undefined;
    const imageUrl: string | undefined = p.image_front_url || p.image_url || undefined;

    const catStr: string = p.categories || p.categories_tags?.join(",") || "";
    const hint = CAT_HINTS.find(h => h.match.test(catStr));
    const shelfLifeDays = hint?.days ?? null;

    return { name, brand, imageUrl, shelfLifeDays };
  } catch {
    return null;
  }
}
