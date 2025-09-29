// src/screens/AddItem.tsx
import React, { useMemo, useState } from "react";
import { View, Text, TextInput, Button, Alert } from "react-native";
import { appDb, execAsync } from "../db";
import { computeEstExpiry, bestExpiry } from "../expiry";
import { ensureNotificationPermissions, scheduleExpiryReminder } from "../notify";

export default function AddItem({ route, navigation }: any) {
  const initialBarcode = route?.params?.barcode ?? "";
  const [barcode, setBarcode] = useState(initialBarcode);
  const [name, setName] = useState("");
  const [brand, setBrand] = useState("");
  const [qty, setQty] = useState("1");
  const [unit, setUnit] = useState("count");
  const [locationId, setLocationId] = useState<"loc_pantry"|"loc_fridge"|"loc_freezer">("loc_pantry");
  const [acquiredAt, setAcquiredAt] = useState(new Date().toISOString().slice(0,10));
  const [bestBefore, setBestBefore] = useState("");
  const [useBy, setUseBy] = useState("");

  const est = useMemo(() => computeEstExpiry({ acquiredAt, shelfLifeDays: undefined }), [acquiredAt]);
  const previewExpiry = bestExpiry(useBy || null, bestBefore || null, est);

  async function save() {
    const productId = "prd_" + Math.random().toString(36).slice(2,10);
    const stockId = "stk_" + Math.random().toString(36).slice(2,10);

    await execAsync(appDb, `
      INSERT OR IGNORE INTO products (id, barcode, name, brand, default_unit, created_at)
      VALUES (?, ?, ?, ?, ?, datetime('now'))
    `, [productId, barcode || null, name || "Unnamed", brand || null, unit]);

    await execAsync(appDb, `
      INSERT INTO stock (id, product_id, location_id, quantity, unit, acquired_at, best_before, use_by, est_expires_at, status, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'in_stock', datetime('now'), datetime('now'))
    `, [
      stockId, productId, locationId,
      parseFloat(qty || "1"), unit, acquiredAt || null,
      bestBefore || null, useBy || null, est || null
    ]);

    await ensureNotificationPermissions();
    if (previewExpiry) await scheduleExpiryReminder(name || "Unnamed item", previewExpiry, 24);

    Alert.alert("Saved", previewExpiry ? `Expiry: ${previewExpiry}` : "No expiry set");
    navigation.popToTop();
  }

  return (
    <View style={{ flex:1, padding:16, gap:8 }}>
      <Text style={{ fontSize:18, fontWeight:"600" }}>Add Item</Text>
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
        {["loc_pantry","loc_fridge","loc_freezer"].map((id) => (
          <Button key={id} title={id.replace("loc_","")} onPress={() => setLocationId(id as any)} color={locationId===id?"#2F7D5B":undefined} />
        ))}
      </Row>
      <Label>Acquired (YYYY-MM-DD)</Label>
      <TextInput value={acquiredAt} onChangeText={setAcquiredAt} style={input} />
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
