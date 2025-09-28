// src/expiry.ts
export function computeEstExpiry(opts: {
  openedAt?: string; openedLifeDays?: number; acquiredAt?: string; shelfLifeDays?: number;
}): string | null {
  const base = opts.openedAt && opts.openedLifeDays != null
    ? new Date(opts.openedAt)
    : opts.acquiredAt && opts.shelfLifeDays != null
    ? new Date(opts.acquiredAt)
    : null;
  const days = opts.openedAt && opts.openedLifeDays != null ? opts.openedLifeDays
             : opts.acquiredAt && opts.shelfLifeDays != null ? opts.shelfLifeDays : null;
  if (!base || days == null) return null;
  const d = new Date(Date.UTC(base.getUTCFullYear(), base.getUTCMonth(), base.getUTCDate()));
  d.setUTCDate(d.getUTCDate() + days);
  return d.toISOString().slice(0,10);
}

export function bestExpiry(useBy?: string | null, bestBefore?: string | null, est?: string | null) {
  return useBy ?? bestBefore ?? est ?? null;
}
