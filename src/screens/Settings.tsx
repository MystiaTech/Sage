// src/screens/Settings.tsx  (UPDATE) — themed UI remains; no logic change except colors
import React from "react";
import { View, Text, TextInput, Button, Alert, Switch } from "react-native";
import { getDiscordWebhook, setDiscordWebhook, sendExpiringToDiscord } from "../discord";
import { useThemePrefs, useSageColors } from "../theme";
import { insertTestItem } from "../db";

export default function Settings() {
  const { themePref, setThemePref, autofill, setAutofill } = useThemePrefs();
  const c = useSageColors();
  const [url, setUrl] = React.useState("");
  const [days, setDays] = React.useState("3");

  React.useEffect(() => { (async () => { const saved = await getDiscordWebhook(); if (saved) setUrl(saved); })(); }, []);

  async function save() { await setDiscordWebhook(url || null); Alert.alert("Saved", url ? "Webhook saved" : "Webhook cleared"); }
  async function testSend() {
    try { const n = parseInt(days || "3", 10) || 3; const res = await sendExpiringToDiscord(n); Alert.alert("Discord", `Sent ${res.sent} item(s).`); }
    catch (e: any) { Alert.alert("Discord", e?.message ?? "Failed to send"); }
  }
  async function addTestItemAndSend() { try { await insertTestItem(1); const res = await sendExpiringToDiscord(3); Alert.alert("OK", `Inserted test item and sent ${res.sent} item(s).`); } catch (e:any){ Alert.alert("Error", e?.message ?? "Failed"); } }
  async function addTestItemOnly() { try { const r = await insertTestItem(1); Alert.alert("OK", `Inserted test item expiring ${r.use_by}.`); } catch (e:any){ Alert.alert("Error", e?.message ?? "Failed"); } }

  return (
    <View style={{ flex:1, padding:16, backgroundColor: c.bg }}>
      <Text style={{ fontSize:20, fontWeight:"600", marginBottom:8, color: c.text }}>Settings</Text>

      <Text style={{ fontWeight:"600", marginTop:8, color: c.text }}>Theme</Text>
      <View style={{ flexDirection:"row", gap:8, marginVertical:8 }}>
        {(["system","light","dark"] as const).map(p => (
          <Button key={p} title={p} onPress={()=>setThemePref(p)} color={themePref===p ? c.primary : undefined} />
        ))}
      </View>

      <View style={{ flexDirection:"row", alignItems:"center", justifyContent:"space-between", marginVertical:8 }}>
        <Text style={{ fontWeight:"600", color: c.text }}>Auto-fill from barcode (Open Food Facts)</Text>
        <Switch value={autofill} onValueChange={setAutofill} />
      </View>

      <Text style={{ fontSize:18, fontWeight:"600", marginTop:16, color: c.text }}>Discord</Text>
      <Text style={{ fontWeight:"600", marginTop:8, color: c.text }}>Webhook URL</Text>
      <TextInput
        value={url}
        onChangeText={setUrl}
        placeholder="https://discord.com/api/webhooks/…"
        placeholderTextColor={c.subtext}
        autoCapitalize="none"
        autoCorrect={false}
        style={{ borderWidth:1, borderColor:c.border, backgroundColor:c.inputBg, color:c.text, borderRadius:8, padding:10, marginVertical:8 }}
      />
      <Button title="Save Webhook" onPress={save} />
      <View style={{ height:12 }} />
      <Text style={{ fontWeight:"600", color: c.text }}>Test send (days ahead)</Text>
      <TextInput
        value={days} onChangeText={setDays} keyboardType="numeric"
        placeholderTextColor={c.subtext}
        style={{ borderWidth:1, borderColor:c.border, backgroundColor:c.inputBg, color:c.text, borderRadius:8, padding:10, marginVertical:8 }}
      />
      <View style={{ flexDirection:"row", gap:8, marginBottom:8 }}>
        <Button title="Send expiring to Discord" onPress={testSend} />
      </View>

      <Text style={{ fontSize:18, fontWeight:"600", marginTop:16, color: c.text }}>Debug / Test</Text>
      <View style={{ flexDirection:"row", gap:8, marginTop:8 }}>
        <Button title="Insert test item (expires tomorrow)" onPress={addTestItemOnly} />
      </View>
      <View style={{ flexDirection:"row", gap:8, marginTop:8 }}>
        <Button title="Insert test item & send to Discord" onPress={addTestItemAndSend} />
      </View>
    </View>
  );
}
