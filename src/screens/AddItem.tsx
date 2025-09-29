// src/screens/AddItem.tsx  (REPLACE) — themed UI, readable in dark mode
import React, { useEffect, useMemo, useState } from "react";
import { View, Text, TextInput, Button, Alert, Image, Pressable } from "react-native";
import { appDb, execAsync, findProductByBarcode, createProduct, upsertStockSmart } from "../db";
import { computeEstExpiry, bestExpiry } from "../expiry";
import { ensureNotificationPermissions, scheduleExpiryReminder } from "../notify";
import { fetchProductByBarcode } from "../fetchProduct";
import { useThemePrefs, useSageColors } from "../theme";
import { normalizeBarcode } from "../barcode";

type Loc = "loc_pantry" | "loc_fridge" | "loc_freezer";

export default function AddItem({ route, navigation }: any) {
  const { autofill } = useThemePrefs();
  const c = useSageColors();

  const initialRaw = route?.params?.barcode ?? "";
  const [barcodeRaw, setBarcodeRaw] = useState(initialRaw);
  const norm = useMemo(() => normalizeBarcode(barcodeRaw), [barcodeRaw]);

  const [name, setName] = useState("");
  const [brand, setBrand] = useState("");
  const [imageUrl, setImageUrl] = useState<string | undefined>(undefined);
  const [qty, setQty] = useState("1");
  const [unit, setUnit] = useState("count");
  const [locationId, setLocationId] = useState<Loc>("loc_pantry");
  const [acquiredAt, setAcquiredAt] = useState(new Date().toISOString().slice(0,10));
  const [bestBefore, setBestBefore] = useState("");
  const [useBy, setUseBy] = useState("");
  const [shelfLifeDays, setShelfLifeDays] = useState<number | null>(null);

  useEffect(() => {
    (async () => {
      if (!norm.digits || !autofill) return;
      const info = await fetchProductByBarcode(norm.canonical);
      if (!info) return;
      if (info.name && !name) setName(info.name);
      if (info.brand && !brand) setBrand(info.brand);
      if (info.imageUrl) setImageUrl(info.imageUrl);
      if (info.shelfLifeDays && shelfLifeDays == null) setShelfLifeDays(info.shelfLifeDays);
    })();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [norm.canonical, autofill]);

  const est = useMemo(() => computeEstExpiry({ acquiredAt, shelfLifeDays: shelfLifeDays ?? undefined }), [acquiredAt, shelfLifeDays]);
  const previewExpiry = bestExpiry(useBy || null, bestBefore || null, est);

  async function save() {
    const qtyNum = Math.max(1, parseFloat(qty || "1") || 1);

    let pid = null as string | null;
    if (norm.digits) {
      const existing = await findProductByBarcode(norm.canonical);
      if (existing) {
        pid = existing.id;
        if ((existing.image_url == null && imageUrl) || (existing.shelf_life_days == null && shelfLifeDays != null)) {
          await execAsync(appDb, `UPDATE products SET image_url=IFNULL(image_url, ?), shelf_life_days=IFNULL(shelf_life_days, ?) WHERE id=?`,
            [imageUrl ?? null, shelfLifeDays ?? null, pid]);
        }
      }
    }
    if (!pid) {
      pid = await createProduct({
        barcode: norm.canonical || null, name: name || "Unnamed", brand: brand || null,
        default_unit: unit, shelf_life_days: shelfLifeDays ?? null, image_url: imageUrl ?? null
      });
    }

    await upsertStockSmart({
      product_id: pid!, location_id: locationId, unit: unit || null, quantity: qtyNum,
      acquired_at: acquiredAt || null, best_before: bestBefore || null, use_by: useBy || null, est_expires_at: est || null
    });

    await ensureNotificationPermissions();
    if (previewExpiry) await scheduleExpiryReminder(name || "Unnamed item", previewExpiry, 24);

    Alert.alert("Saved", previewExpiry ? `Expiry: ${previewExpiry}` : "No expiry set");
    navigation.popToTop();
  }

  return (
    <View style={{ flex:1, padding:16, gap:8, backgroundColor: c.bg }}>
      <Text style={{ fontSize:18, fontWeight:"600", color: c.text }}>Add Item</Text>

      {imageUrl ? (
        <Image source={{ uri: imageUrl }} style={{ width: "100%", height: 160, borderRadius: 12, marginBottom: 8 }} resizeMode="cover" />
      ) : null}

      <Label c={c}>Barcode</Label>
      <Input c={c} value={barcodeRaw} onChangeText={setBarcodeRaw} placeholder="Scan or type" />
      {norm.digits ? (
        <Text style={{ color: c.subtext }}>
          {norm.upc12 ? `UPC-12: ${norm.upc12}  •  GTIN-13: ${norm.canonical}` : `GTIN-13: ${norm.canonical}`}
        </Text>
      ) : null}

      <Label c={c}>Name</Label>
      <Input c={c} value={name} onChangeText={setName} placeholder="e.g., Gold Peak Tea & Lemonade" />

      <Label c={c}>Brand</Label>
      <Input c={c} value={brand} onChangeText={setBrand} placeholder="e.g., Gold Peak" />

      <Row>
        <View style={{ flex:1 }}>
          <Label c={c}>Qty</Label>
          <Input c={c} keyboardType="numeric" value={qty} onChangeText={setQty} />
        </View>
        <View style={{ flex:1 }}>
          <Label c={c}>Unit</Label>
          <Input c={c} value={unit} onChangeText={setUnit} placeholder="count/g/ml" />
        </View>
      </Row>

      <Label c={c}>Location</Label>
      <Row>
        {(["loc_pantry","loc_fridge","loc_freezer"] as const).map((id) => {
          const active = locationId === id;
          return (
            <Pressable
              key={id}
              onPress={() => setLocationId(id as Loc)}
              style={{
                flex:1, padding: 10, borderRadius: 10,
                borderWidth: 1, borderColor: active ? c.primary : c.border,
                backgroundColor: active ? c.primary : c.card,
                alignItems: "center", marginBottom: 6
              }}>
              <Text style={{ color: active ? "#fff" : c.text }}>
                {id.replace("loc_","").replace(/^./, s => s.toUpperCase())}
              </Text>
            </Pressable>
          );
        })}
      </Row>

      <Row>
        <View style={{ flex:1 }}>
          <Label c={c}>Acquired (YYYY-MM-DD)</Label>
          <Input c={c} value={acquiredAt} onChangeText={setAcquiredAt} />
        </View>
        <View style={{ flex:1 }}>
          <Label c={c}>Heuristic shelf life (days)</Label>
          <Input c={c} keyboardType="numeric"
            value={shelfLifeDays != null ? String(shelfLifeDays) : ""}
            onChangeText={(t)=>setShelfLifeDays(t ? parseInt(t,10) : null)}
            placeholder="(optional)" />
        </View>
      </Row>

      <Label c={c}>Best Before</Label>
      <Input c={c} value={bestBefore} onChangeText={setBestBefore} placeholder="YYYY-MM-DD" />
      <Label c={c}>Use By</Label>
      <Input c={c} value={useBy} onChangeText={setUseBy} placeholder="YYYY-MM-DD" />

      <Text style={{ color: c.subtext }}>Estimated expiry: {previewExpiry ?? "n/a"}</Text>

      <Button title="Save" onPress={save} />
      <View style={{ height: 6 }} />
      <Button title="Scan another" onPress={() => navigation.replace("Scan")} />
    </View>
  );
}

function Label({ children, c }: { children: React.ReactNode; c: ReturnType<typeof useSageColors> }) {
  return <Text style={{ color: c.text, fontWeight:"600", marginTop:6 }}>{children}</Text>;
}
function Input(props: any) {
  const c = useSageColors();
  return (
    <TextInput
      {...props}
      placeholderTextColor={c.subtext}
      style={{ borderWidth:1, borderColor:c.border, backgroundColor:c.inputBg, color:c.text, borderRadius:8, padding:10, marginBottom:6 }}
    />
  );
}
function Row({ children }: { children: React.ReactNode }) { return <View style={{ flexDirection:"row", gap:8 }}>{children}</View>; }
