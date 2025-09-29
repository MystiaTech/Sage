// src/barcode.ts  (REPLACE) — validation + smart normalization
export type NormalizedBarcode = {
  raw: string;
  digits: string;
  canonical: string;   // GTIN-13 canonical form when possible
  upc12?: string;      // if canonical is UPC-A form (leading 0 EAN-13)
  tryList: string[];
};

export function validateEAN13(d: string): boolean {
  if (d.length !== 13 || !/^\d+$/.test(d)) return false;
  const odd = [...d.slice(0, 12)].filter((_, i) => i % 2 === 0).reduce((s, c) => s + +c, 0);
  const even = [...d.slice(0, 12)].filter((_, i) => i % 2 === 1).reduce((s, c) => s + +c, 0);
  const chk = (10 - ((odd + 3 * even) % 10)) % 10;
  return chk === +d[12];
}

export function validateUPCA(d: string): boolean {
  if (d.length !== 12 || !/^\d+$/.test(d)) return false;
  const odd = [...d.slice(0, 11)].filter((_, i) => i % 2 === 0).reduce((s, c) => s + +c, 0);
  const even = [...d.slice(0, 11)].filter((_, i) => i % 2 === 1).reduce((s, c) => s + +c, 0);
  const chk = (10 - ((3 * odd + even) % 10)) % 10;
  return chk === +d[11];
}

/** Generic normalization (kept backward-compatible) */
export function normalizeBarcode(rawInput: string): NormalizedBarcode {
  const digits = (rawInput || "").replace(/\D+/g, "");
  let canonical = digits;
  const trySet = new Set<string>();

  if (digits.length === 12 && validateUPCA(digits)) {
    canonical = "0" + digits;   // UPC-A → GTIN-13
    trySet.add(canonical);
    trySet.add(digits);
  } else if (digits.length === 13 && validateEAN13(digits)) {
    canonical = digits;
    trySet.add(canonical);
    if (digits.startsWith("0")) trySet.add(digits.slice(1)); // UPC-12 form for lookups that accept it
  } else {
    if (digits) trySet.add(digits);
  }

  const upc12 = canonical.length === 13 && canonical.startsWith("0") ? canonical.slice(1) : undefined;
  return { raw: rawInput, digits, canonical, upc12, tryList: [...trySet] };
}

/** Strict “US retail” chooser: accept UPC-A or EAN-13 that starts with 0 */
export function chooseUSRetail(rawInput: string): NormalizedBarcode | null {
  const n = normalizeBarcode(rawInput);
  if (n.digits.length === 12 && validateUPCA(n.digits)) return n;
  if (n.digits.length === 13 && validateEAN13(n.digits) && n.digits.startsWith("0")) return n;
  return null;
}
