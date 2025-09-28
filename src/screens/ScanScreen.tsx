// src/screens/ScanScreen.tsx
import React, { useEffect, useState } from "react";
import { View, Text, Button } from "react-native";
import { CameraView, useCameraPermissions } from "expo-camera";
import type { NativeStackScreenProps } from "@react-navigation/native-stack";

type RootStackParamList = {
  Scan: undefined;
  AddItem: { barcode?: string };
};

export default function ScanScreen({ navigation }: NativeStackScreenProps<RootStackParamList, "Scan">) {
  const [permission, requestPermission] = useCameraPermissions();
  const [scanning, setScanning] = useState(true);

  useEffect(() => { if (permission && !permission.granted) requestPermission(); }, [permission]);

  if (!permission) return <Center> <Text>Checking camera…</Text> </Center>;
  if (!permission.granted) {
    return (
      <Center>
        <Text>Camera permission needed.</Text>
        <Button title="Grant" onPress={requestPermission} />
      </Center>
    );
  }

  return (
    <View style={{ flex: 1 }}>
      {scanning ? (
        <CameraView
          style={{ flex: 1 }}
          barcodeScannerSettings={{ barcodeTypes: ["ean13","ean8","upc_a","upc_e","qr","code128"] }}
          onBarcodeScanned={(e) => { setScanning(false); navigation.replace("AddItem", { barcode: e.data }); }}
        />
      ) : (
        <Center>
          <Text style={{ fontSize: 18 }}>Processing…</Text>
          <Button title="Scan again" onPress={() => setScanning(true)} />
        </Center>
      )}
    </View>
  );
}

function Center({ children }: { children: React.ReactNode }) {
  return <View style={{ flex:1, alignItems:"center", justifyContent:"center", gap:12 }}>{children}</View>;
}
