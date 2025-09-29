// src/screens/Inventory.tsx  (REPLACE) — themed UI + Use one / Discard remains
import React, { useEffect, useState } from "react";
import { View, Text, FlatList, Button, Image } from "react-native";
import { appDb, queryAsync, useOne, discardStock } from "../db";
import { useSageColors } from "../theme";
import { sendDiscardNotice } from "../discord";

type Row = {
  id: string; product_id: string; name?: string; brand?: string; image_url?: string|null;
  location_id: string; quantity: number; unit?: string|null;
  best_before?: string|null; use_by?: string|null; est_expires_at?: string|null; status: string;
};

export default function Inventory() {
  const c = useSageColors();
  const [loc, setLoc] = useState<"loc_pantry"|"loc_fridge"|"loc_freezer">("loc_pantry");
  const [rows, setRows] = useState<Row[]>([]);

  async function refresh() {
    const data = await queryAsync<Row>(appDb, `
      SELECT s.*, p.name, p.brand, p.image_url
      FROM stock s
      LEFT JOIN products p ON p.id = s.product_id
      WHERE s.status='in_stock' AND s.location_id=?
      ORDER BY p.name ASC
    `, [loc]);
    setRows(data);
  }
  useEffect(() => { refresh(); }, [loc]);

  return (
    <View style={{ flex:1, padding:16, backgroundColor: c.bg }}>
      <Text style={{ fontSize:22, fontWeight:"600", marginBottom:8, color: c.text }}>Inventory</Text>
      <View style={{ flexDirection:"row", gap:8, marginBottom:8 }}>
        <Button title="Pantry" onPress={()=>setLoc("loc_pantry")} color={loc==="loc_pantry" ? c.primary : undefined} />
        <Button title="Fridge" onPress={()=>setLoc("loc_fridge")} color={loc==="loc_fridge" ? c.primary : undefined} />
        <Button title="Freezer" onPress={()=>setLoc("loc_freezer")} color={loc==="loc_freezer" ? c.primary : undefined} />
      </View>
      <FlatList
        data={rows}
        keyExtractor={(r)=>r.id}
        renderItem={({ item }) => {
          const expiry = item.use_by || item.best_before || item.est_expires_at || "n/a";
          return (
            <View style={{ flexDirection:"row", gap:10, padding:12, borderWidth:1, borderRadius:12, marginBottom:8, alignItems:"center", borderColor:c.border, backgroundColor:c.card }}>
              {item.image_url ? <Image source={{ uri: item.image_url }} style={{ width:48, height:48, borderRadius:8 }} /> : null}
              <View style={{ flex:1 }}>
                <Text style={{ fontWeight:"600", color: c.text }}>{item.name || "(unnamed)"}</Text>
                <Text style={{ color: c.subtext }}>{item.brand || ""}</Text>
                <Text style={{ color: c.text }}>{item.quantity} {item.unit || ""} — {item.location_id.replace("loc_","")}</Text>
                <Text style={{ color: c.text }}>Expiry: {expiry}</Text>
                <View style={{ flexDirection:"row", gap:8, marginTop:6 }}>
                  <Button title="Use one" onPress={async()=>{ await useOne(item.id); refresh(); }} />
                  <Button title="Discard" onPress={async()=>{ await discardStock(item.id); await sendDiscardNotice(item.name || "Item", expiry); refresh(); }} />
                </View>
              </View>
            </View>
          );
        }}
        ListEmptyComponent={<Text style={{ color: c.subtext }}>No items here yet.</Text>}
      />
    </View>
  );
}
