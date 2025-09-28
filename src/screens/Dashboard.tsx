// src/screens/Dashboard.tsx
import React, { useEffect, useState } from "react";
import { View, Text, FlatList } from "react-native";
import { appDb, queryAsync } from "../db";

type Row = {
  id: string; product_id: string; best_before?: string; use_by?: string; est_expires_at?: string;
  name?: string; brand?: string;
};

export default function Dashboard() {
  const [rows, setRows] = useState<Row[]>([]);

  useEffect(() => {
    (async () => {
      const data = await queryAsync<Row>(appDb, `
        SELECT s.*, p.name, p.brand
        FROM stock s
        LEFT JOIN products p ON p.id = s.product_id
        WHERE s.status='in_stock'
          AND date(COALESCE(s.use_by, s.best_before, s.est_expires_at)) <= date('now','+7 day')
        ORDER BY date(COALESCE(s.use_by, s.best_before, s.est_expires_at)) ASC
        LIMIT 50
      `);
      setRows(data);
    })();
  }, []);

  return (
    <View style={{ flex:1, padding:16 }}>
      <Text style={{ fontSize:22, fontWeight:"600", marginBottom:8 }}>Expiring Soon (7 days)</Text>
      <FlatList
        data={rows}
        keyExtractor={(r) => r.id}
        renderItem={({ item }) => {
          const expiry = item.use_by || item.best_before || item.est_expires_at || "n/a";
          return (
            <View style={{ padding:12, borderWidth:1, borderRadius:12, marginBottom:8 }}>
              <Text style={{ fontWeight:"600" }}>{item.name || "Unnamed item"}</Text>
              <Text style={{ opacity:0.7 }}>{item.brand || ""}</Text>
              <Text>Expiry: {expiry}</Text>
            </View>
          );
        }}
        ListEmptyComponent={<Text style={{ opacity:0.6 }}>Nothing expiring soon 🎉</Text>}
      />
    </View>
  );
}
