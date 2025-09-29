// src/screens/Settings.tsx
import React, { useEffect, useState } from "react";
import { View, Text, TextInput, Button, Alert } from "react-native";
import { getDiscordWebhook, setDiscordWebhook, sendExpiringToDiscord } from "../discord";

export default function Settings() {
  const [url, setUrl] = useState("");
  const [days, setDays] = useState("3");

  useEffect(() => {
    (async () => {
      const saved = await getDiscordWebhook();
      if (saved) setUrl(saved);
    })();
  }, []);

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

  return (
    <View style={{ flex:1, padding:16 }}>
      <Text style={{ fontSize:20, fontWeight:"600", marginBottom:8 }}>Settings</Text>
      <Text style={{ fontWeight:"600" }}>Discord Webhook URL</Text>
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
      <Button title="Send expiring to Discord" onPress={testSend} />
      <View style={{ height:24 }} />
      <Text style={{ opacity:0.7 }}>
        Create a Discord webhook in Server Settings → Integrations → Webhooks, then paste it here.
      </Text>
    </View>
  );
}
