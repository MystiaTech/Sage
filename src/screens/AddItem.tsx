// src/screens/AddItem.tsx  (UPDATED) — smart increments + autopopulate + images + fixed locations
import React, { useEffect, useMemo, useState } from "react";
import { View, Text, TextInput, Button, Alert, Image, Pressable } from "react-native";
import { appDb, execAsync, findProductByBarcode, createProduct, upsertStockSmart } from "../db";
import { computeEstExpiry, bestExpiry } from "../expiry";
import { ensureNotificationPermissions, scheduleExpiryReminder } from "../notify";
import { fetchProductByBarcode } from "../fetchProduct";
import { useThemePrefs } from "../theme";

type Loc = "loc_pantry" | "loc_fridge" | "loc_freezer";

export default function AddItem({ route, navigation }: any) {
  const { autofill } = useThemePrefs();
  const initialBarcode = route?.params?.barcode ?? "";
  const [barcode, setBarcode] = useState(initialBarcode);
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

  // Auto-fetch product info when barcode changes
  useEffect(() => {
    (async () => {
      if (!barcode || !autofill) return;
      const info = await fetchProductByBarcode(barcode);
      if (!info) return;
      if (info.name && !name) setName(info.name);
      if (info.brand && !brand) setBrand(info.brand);
      if (info.imageUrl) setImageUrl(info.imageUrl);
      if (info.shelfLifeDays && shelfLifeDays == null) setShelfLifeDays(info.shelfLifeDays);
    })();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [barcode, autofill]);

  const est = useMemo(() => computeEstExpiry({ acquiredAt, shelfLifeDays: shelfLifeDays ?? undefined }), [acquiredAt, shelfLifeDays]);
  const previewExpiry = bestExpiry(useBy || null, bestBefore || null, est);

  async function save() {
    const qtyNum = Math.max(1, parseFloat(qty || "1") || 1);

    // Reuse product by barcode if exists; else create
    let pid = null as string | null;
    if (barcode) {
      const existing = await findProductByBarcode(barcode);
      if (existing) {
        pid = existing.id;
        // Optionally backfill missing fields
        if ((existing.image_url == null && imageUrl) || (existing.shelf_life_days == null && shelfLifeDays != null)) {
          await execAsync(appDb, `UPDATE products SET image_url=IFNULL(image_url, ?), shelf_life_days=IFNULL(shelf_life_days, ?) WHERE id=?`,
            [imageUrl ?? null, shelfLifeDays ?? null, pid]);
        }
      }
    }
    if (!pid) {
      pid = await createProduct({
        barcode: barcode || null,
        name: name || "Unnamed",
        brand: brand || null,
        default_unit: unit,
        shelf_life_days: shelfLifeDays ?? null,
        image_url: imageUrl ?? null
      });
    }

    // SMART UPSERT: same product+location+unit+same expiry → increment; else insert new
    const stockId = await upsertStockSmart({
      product_id: pid!,
      location_id: locationId,
      unit: unit || null,
      quantity: qtyNum,
      acquired_at: acquiredAt || null,
      best_before: bestBefore || null,
      use_by: useBy || null,
      est_expires_at: est || null
    });

    await ensureNotificationPermissions();
    if (previewExpiry) await scheduleExpiryReminder(name || "Unnamed item", previewExpiry, 24);

    Alert.alert("Saved", previewExpiry ? `Expiry: ${previewExpiry}` : "No expiry set");
    navigation.popToTop();
  }

  return (
    <View style={{ flex:1, padding:16, gap:8 }}>
      <Text style={{ fontSize:18, fontWeight:"600" }}>Add Item</Text>

      {imageUrl ? (
        <Image source={{ uri: imageUrl }} style={{ width: "100%", height: 160, borderRadius: 12, marginBottom: 8 }} resizeMode="cover" />
      ) : null}

      <Label>Barcode</Label>
      <TextInput value={barcode} onChangeText={setBarcode} placeholder="Scan or type" style={input} />

      <Label>Name</Label>
      <TextInput value={name} onChangeText={setName} placeholder="e.g., Whole Milk" style={input} />

      <Label>Brand</Label>
      <TextInput value={brand} onChangeText={setBrand} placeholder="e.g., Horizon" style={input} />

      <Row>
        <View style={{ flex:1 }}>
          <Label>Qty</Label>
          <TextInput keyboardType="numeric" value={qty} onChangeText={setQty} style={input} />
        </View>
        <View style={{ flex:1 }}>
          <Label>Unit</Label>
          <TextInput value={unit} onChangeText={setUnit} placeholder="count/g/ml" style={input} />
        </View>
      </Row>

      <Label>Location</Label>
      <Row>
        {([
          { id: "loc_pantry", label: "Pantry" },
          { id: "loc_fridge", label: "Fridge" },
          { id: "loc_freezer", label: "Freezer" },
        ] as const).map(({ id, label }) => {
          const active = locationId === id;
          return (
            <Pressable
              key={id}
              onPress={() => setLocationId(id as Loc)}
              style={{
                flex: 1, padding: 10, borderRadius: 10,
                borderWidth: 1, borderColor: active ? "#2F7D5B" : "#ccc",
                backgroundColor: active ? "#2F7D5B" : "transparent",
                alignItems: "center", marginBottom: 6
              }}>
              <Text style={{ color: active ? "#fff" : "#000" }}>{label}</Text>
            </Pressable>
          );
        })}
      </Row>

      <Row>
        <View style={{ flex:1 }}>
          <Label>Acquired (YYYY-MM-DD)</Label>
          <TextInput value={acquiredAt} onChangeText={setAcquiredAt} style={input} />
        </View>
        <View style={{ flex:1 }}>
          <Label>Heuristic shelf life (days)</Label>
          <TextInput
            keyboardType="numeric"
            value={shelfLifeDays != null ? String(shelfLifeDays) : ""}
            onChangeText={(t)=>setShelfLifeDays(t ? parseInt(t,10) : null)}
            placeholder="(optional)"
            style={input}
          />
        </View>
      </Row>

      <Label>Best Before</Label>
      <TextInput value={bestBefore} onChangeText={setBestBefore} placeholder="YYYY-MM-DD" style={input} />
      <Label>Use By</Label>
      <TextInput value={useBy} onChangeText={setUseBy} placeholder="YYYY-MM-DD" style={input} />

      <Text style={{ opacity:0.7 }}>Estimated expiry: {previewExpiry ?? "n/a"}</Text>

      <Button title="Save" onPress={save} />
      <Button title="Scan another" onPress={() => navigation.replace("Scan")} />
    </View>
  );
}

const input = { borderWidth:1, borderColor:"#ddd", borderRadius:8, padding:10, marginBottom:6 };
function Label({ children }: { children: React.ReactNode }) { return <Text style={{ fontWeight:"600", marginTop:6 }}>{children}</Text>; }
function Row({ children }: { children: React.ReactNode }) { return <View style={{ flexDirection:"row", gap:8 }}>{children}</View>; }
