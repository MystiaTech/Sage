// src/screens/Dashboard.tsx  (REPLACE) — themed UI + Discord notice on discard
import React, { useEffect, useState } from "react";
import { View, Text, FlatList, Button, Image } from "react-native";
import { appDb, queryAsync, useOne, discardStock } from "../db";
import { sendExpiringToDiscord, sendDiscardNotice } from "../discord";
import { useSageColors } from "../theme";

type Row = {
  id: string; product_id: string; best_before?: string|null; use_by?: string|null; est_expires_at?: string|null;
  name?: string; brand?: string; image_url?: string|null;
};

export default function Dashboard() {
  const c = useSageColors();
  const [rows, setRows] = useState<Row[]>([]);

  async function load() {
    const data = await queryAsync<Row>(appDb, `
      SELECT s.id, s.best_before, s.use_by, s.est_expires_at, p.name, p.brand, p.image_url
      FROM stock s
      LEFT JOIN products p ON p.id = s.product_id
      WHERE s.status='in_stock'
        AND date(COALESCE(s.use_by, s.best_before, s.est_expires_at)) <= date('now','+7 day')
      ORDER BY date(COALESCE(s.use_by, s.best_before, s.est_expires_at)) ASC
      LIMIT 50
    `);
    setRows(data);
  }
  useEffect(() => { load(); }, []);

  return (
    <View style={{ flex:1, padding:16, backgroundColor: c.bg }}>
      <Text style={{ fontSize:22, fontWeight:"600", marginBottom:8, color: c.text }}>Expiring Soon (7 days)</Text>
      <View style={{ marginBottom: 8 }}>
        <Button title="Send to Discord (3 days)" onPress={() => sendExpiringToDiscord(3)} />
      </View>
      <FlatList
        data={rows}
        keyExtractor={(r) => r.id}
        renderItem={({ item }) => {
          const expiry = item.use_by || item.best_before || item.est_expires_at || "n/a";
          return (
            <View style={{ flexDirection:"row", gap:10, padding:12, borderWidth:1, borderRadius:12, marginBottom:8, alignItems:"center", borderColor:c.border, backgroundColor:c.card }}>
              {item.image_url ? <Image source={{ uri: item.image_url }} style={{ width:48, height:48, borderRadius:8 }} /> : null}
              <View style={{ flex:1 }}>
                <Text style={{ fontWeight:"600", color: c.text }}>{item.name || "Unnamed item"}</Text>
                <Text style={{ color: c.subtext }}>{item.brand || ""}</Text>
                <Text style={{ color: c.text }}>Expiry: {expiry}</Text>
                <View style={{ flexDirection:"row", gap:8, marginTop:6 }}>
                  <Button title="Use one" onPress={async()=>{ await useOne(item.id); load(); }} />
                  <Button title="Discard" onPress={async()=>{ await discardStock(item.id); await sendDiscardNotice(item.name || "Item", expiry); load(); }} />
                </View>
              </View>
            </View>
          );
        }}
        ListEmptyComponent={<Text style={{ color: c.subtext }}>Nothing expiring soon 🎉</Text>}
      />
    </View>
  );
}
