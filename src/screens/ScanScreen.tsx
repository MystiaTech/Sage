// src/screens/ScanScreen.tsx  (UNCHANGED FROM LAST REPLY, shown for completeness)
import React, { useEffect, useState } from "react";
import { View, Text, Button } from "react-native";
import { CameraView, useCameraPermissions } from "expo-camera";

export default function ScanScreen({ navigation }: any) {
  const [permission, requestPermission] = useCameraPermissions();
  const [scanning, setScanning] = useState(true);

  useEffect(() => { if (permission && !permission.granted) requestPermission(); }, [permission]);

  if (!permission) return <Center><Text>Checking camera…</Text></Center>;
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
        <>
          <CameraView
            style={{ flex: 1 }}
            barcodeScannerSettings={{ barcodeTypes: ["ean13","ean8","upc_a","upc_e","qr","code128"] }}
            onBarcodeScanned={(e) => { setScanning(false); navigation.replace("AddItem", { barcode: e.data }); }}
          />
          <View pointerEvents="none" style={{ position:"absolute", left:0, right:0, top:0, bottom:0, alignItems:"center", justifyContent:"center" }}>
            <View style={{ width: 260, height: 120, borderColor: "#00FFA0", borderWidth: 3, borderRadius: 12 }} />
            <Text style={{ position:"absolute", bottom: 80, backgroundColor:"#0008", color:"#fff", paddingHorizontal:10, paddingVertical:6, borderRadius:8 }}>
              Align barcode inside the box
            </Text>
          </View>
        </>
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
