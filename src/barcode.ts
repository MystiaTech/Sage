// src/barcode.ts  (REPLACE) — strict validation + extraction from noisy strings
export type NormalizedBarcode = {
  raw: string;
  digits: string;
  canonical: string;   // GTIN-13 (UPC-A -> prefixed with 0)
  upc12?: string;      // if canonical maps to UPC-A
  tryList: string[];
};

export function validateEAN13(d: string): boolean {
  if (d.length !== 13 || !/^\d+$/.test(d)) return false;
  const s = d.slice(0, 12).split("").map(Number);
  const odd = s.filter((_, i) => i % 2 === 0).reduce((a, b) => a + b, 0);
  const even = s.filter((_, i) => i % 2 === 1).reduce((a, b) => a + b, 0);
  const chk = (10 - ((odd + 3 * even) % 10)) % 10;
  return chk === +d[12];
}

export function validateUPCA(d: string): boolean {
  if (d.length !== 12 || !/^\d+$/.test(d)) return false;
  const s = d.slice(0, 11).split("").map(Number);
  const odd = s.filter((_, i) => i % 2 === 0).reduce((a, b) => a + b, 0);
  const even = s.filter((_, i) => i % 2 === 1).reduce((a, b) => a + b, 0);
  const chk = (10 - ((3 * odd + even) % 10)) % 10;
  return chk === +d[11];
}

export function normalizeBarcode(rawInput: string): NormalizedBarcode {
  const digits = (rawInput || "").replace(/\D+/g, "");
  let canonical = digits;
  const trySet = new Set<string>();

  if (digits.length === 12 && validateUPCA(digits)) {
    canonical = "0" + digits;
    trySet.add(canonical);
    trySet.add(digits);
  } else if (digits.length === 13 && validateEAN13(digits)) {
    canonical = digits;
    trySet.add(canonical);
    if (digits.startsWith("0")) trySet.add(digits.slice(1)); // UPC-12 variant
  } else if (digits) {
    trySet.add(digits);
  }

  const upc12 = canonical.length === 13 && canonical.startsWith("0") ? canonical.slice(1) : undefined;
  return { raw: rawInput, digits, canonical, upc12, tryList: [...trySet] };
}

/**
 * Finds the best valid UPC-A (12) or EAN-13 within a noisy payload.
 * Scans all 12/13-digit windows and returns a normalized candidate.
 */
export function findBestCandidate(rawInput: string, preferUS = true): NormalizedBarcode | null {
  const s = (rawInput || "").replace(/\D+/g, "");
  if (!s) return null;

  const cand = new Set<string>();

  // exact
  if (s.length === 12 && validateUPCA(s)) cand.add(s);
  if (s.length === 13 && validateEAN13(s)) cand.add(s);

  // sliding windows
  for (let i = 0; i + 12 <= s.length; i++) {
    const sub12 = s.slice(i, i + 12);
    if (validateUPCA(sub12)) cand.add(sub12);
    if (i + 13 <= s.length) {
      const sub13 = s.slice(i, i + 13);
      if (validateEAN13(sub13)) cand.add(sub13);
    }
  }

  const arr = [...cand];
  if (!arr.length) return null;

  const score = (d: string) => {
    if (d.length === 12) return preferUS ? 100 : 90;               // UPC-A
    if (d.length === 13 && d.startsWith("0")) return preferUS ? 95 : 100; // EAN-13 (0 + UPC)
    if (d.length === 13) return 80;                                 // other EAN-13
    return 0;
  };
  arr.sort((a, b) => score(b) - score(a));

  return normalizeBarcode(arr[0]);
}
