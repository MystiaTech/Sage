// src/screens/Settings.tsx  (UPDATED) — test item buttons
import React from "react";
import { View, Text, TextInput, Button, Alert, Switch } from "react-native";
import { getDiscordWebhook, setDiscordWebhook, sendExpiringToDiscord } from "../discord";
import { useThemePrefs } from "../theme";
import { insertTestItem } from "../db";

export default function Settings() {
  const { themePref, setThemePref, autofill, setAutofill } = useThemePrefs();
  const [url, setUrl] = React.useState("");
  const [days, setDays] = React.useState("3");

  React.useEffect(() => { (async () => { const saved = await getDiscordWebhook(); if (saved) setUrl(saved); })(); }, []);

  async function save() {
    await setDiscordWebhook(url || null);
    Alert.alert("Saved", url ? "Webhook saved" : "Webhook cleared");
  }

  async function testSend() {
    try {
      const n = parseInt(days || "3", 10) || 3;
      const res = await sendExpiringToDiscord(n);
      Alert.alert("Discord", `Sent ${res.sent} item(s).`);
    } catch (e: any) {
      Alert.alert("Discord", e?.message ?? "Failed to send");
    }
  }

  async function addTestItemAndSend() {
    try {
      await insertTestItem(1); // expires tomorrow
      const res = await sendExpiringToDiscord(3);
      Alert.alert("OK", `Inserted test item and sent ${res.sent} item(s) to Discord.`);
    } catch (e: any) {
      Alert.alert("Error", e?.message ?? "Failed to insert/send");
    }
  }

  async function addTestItemOnly() {
    try {
      const r = await insertTestItem(1);
      Alert.alert("OK", `Inserted test item expiring ${r.use_by}.`);
    } catch (e: any) {
      Alert.alert("Error", e?.message ?? "Failed to insert");
    }
  }

  return (
    <View style={{ flex:1, padding:16 }}>
      <Text style={{ fontSize:20, fontWeight:"600", marginBottom:8 }}>Settings</Text>

      <Text style={{ fontWeight:"600", marginTop:8 }}>Theme</Text>
      <View style={{ flexDirection:"row", gap:8, marginVertical:8 }}>
        {(["system","light","dark"] as const).map(p => (
          <Button key={p} title={p} onPress={()=>setThemePref(p)} color={themePref===p ? "#2F7D5B" : undefined} />
        ))}
      </View>

      <View style={{ flexDirection:"row", alignItems:"center", justifyContent:"space-between", marginVertical:8 }}>
        <Text style={{ fontWeight:"600" }}>Auto-fill from barcode (Open Food Facts)</Text>
        <Switch value={autofill} onValueChange={setAutofill} />
      </View>

      <Text style={{ fontSize:18, fontWeight:"600", marginTop:16 }}>Discord</Text>
      <Text style={{ fontWeight:"600", marginTop:8 }}>Webhook URL</Text>
      <TextInput
        value={url}
        onChangeText={setUrl}
        placeholder="https://discord.com/api/webhooks/…"
        autoCapitalize="none"
        autoCorrect={false}
        style={{ borderWidth:1, borderColor:"#ddd", borderRadius:8, padding:10, marginVertical:8 }}
      />
      <Button title="Save Webhook" onPress={save} />
      <View style={{ height:12 }} />
      <Text style={{ fontWeight:"600" }}>Test send (days ahead)</Text>
      <TextInput
        value={days}
        onChangeText={setDays}
        keyboardType="numeric"
        style={{ borderWidth:1, borderColor:"#ddd", borderRadius:8, padding:10, marginVertical:8 }}
      />
      <View style={{ flexDirection:"row", gap:8, marginBottom:8 }}>
        <Button title="Send expiring to Discord" onPress={testSend} />
      </View>

      <Text style={{ fontSize:18, fontWeight:"600", marginTop:16 }}>Debug / Test</Text>
      <View style={{ flexDirection:"row", gap:8, marginTop:8 }}>
        <Button title="Insert test item (expires tomorrow)" onPress={addTestItemOnly} />
      </View>
      <View style={{ flexDirection:"row", gap:8, marginTop:8 }}>
        <Button title="Insert test item & send to Discord" onPress={addTestItemAndSend} />
      </View>
    </View>
  );
}
