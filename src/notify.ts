// src/notify.ts
import * as Notifications from "expo-notifications";
import { Platform } from "react-native";

Notifications.setNotificationChannelAsync?.("default", {
  name: "default",
  importance: Notifications.AndroidImportance.DEFAULT,
});

export async function ensureNotificationPermissions() {
  if (Platform.OS === "ios") {
    const { status } = await Notifications.requestPermissionsAsync();
    if (status !== "granted") console.warn("Notifications permission not granted");
  }
}

export async function scheduleExpiryReminder(itemName: string, isoDate: string, hoursBefore = 24) {
  const at = new Date(isoDate + "T09:00:00");
  at.setHours(at.getHours() - hoursBefore);
  if (Number.isNaN(at.getTime())) return;
  await Notifications.scheduleNotificationAsync({
    content: { title: "Expiring soon", body: `${itemName} expires around ${isoDate}` },
    trigger: { date: at },
  });
}
