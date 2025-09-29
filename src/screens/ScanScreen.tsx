// src/screens/ScanScreen.tsx  (REPLACE) — stricter types, stability, torch/zoom/mode
import React, { useEffect, useRef, useState } from "react";
import { View, Text, Button, Pressable } from "react-native";
import { CameraView, useCameraPermissions } from "expo-camera";
import { chooseUSRetail, normalizeBarcode } from "../barcode";
import { useSageColors } from "../theme";

type Mode = "us" | "all";

export default function ScanScreen({ navigation }: any) {
  const c = useSageColors();
  const [permission, requestPermission] = useCameraPermissions();
  const [scanning, setScanning] = useState(true);
  const [torch, setTorch] = useState(false);
  const [zoom, setZoom] = useState(0.05);
  const [mode, setMode] = useState<Mode>("us");
  const [hintText, setHintText] = useState<string>("");

  // stability: require same canonical code twice
  const hits = useRef<Map<string, number>>(new Map());

  useEffect(() => { if (permission && !permission.granted) requestPermission(); }, [permission]);

  function reset() {
    hits.current.clear();
    setHintText("");
  }

  function accept(code: string) {
    setScanning(false);
    navigation.replace("AddItem", { barcode: code });
    reset();
  }

  function handleScan(raw: string) {
    // Prefer US retail strictness unless in "all"
    let n = mode === "us" ? chooseUSRetail(raw) : null;
    if (!n && mode === "all") {
      const alt = normalizeBarcode(raw);
      // Only accept if it’s a valid UPC-A or any valid EAN-13
      if ((alt.digits.length === 12 && /^\d+$/.test(alt.digits)) || (alt.digits.length === 13 && /^\d+$/.test(alt.digits))) {
        n = alt;
      }
    }
    if (!n) {
      setHintText("Scanning… (preferring UPC-A / EAN-13 starting with 0)");
      return;
    }
    const key = n.canonical;
    const prev = hits.current.get(key) || 0;
    const next = prev + 1;
    hits.current.set(key, next);

    const shown = n.upc12 ? `UPC-12 ${n.upc12}` : n.canonical;
    setHintText(`Detected: ${shown}${next < 2 ? " (hold steady…)" : ""}`);
    if (next >= 2) accept(n.canonical); // stable
  }

  if (!permission) return <Center><Text style={{ color: c.text }}>Checking camera…</Text></Center>;
  if (!permission.granted) {
    return (
      <Center>
        <Text style={{ color: c.text }}>Camera permission needed.</Text>
        <Button title="Grant" onPress={requestPermission} />
      </Center>
    );
  }

  const typesUS = ["ean13","upc_a"];                 // strict; avoids most false positives
  const typesAll = ["ean13","ean8","upc_a","upc_e"]; // wider acceptance
  const types = mode === "us" ? typesUS : typesAll;

  return (
    <View style={{ flex: 1, backgroundColor: c.bg }}>
      {scanning ? (
        <>
          <CameraView
            style={{ flex: 1 }}
            facing="back"
            enableZoomGesture
            zoom={zoom}
            enableTorch={torch}
            barcodeScannerSettings={{ barcodeTypes: types }}
            onBarcodeScanned={(e) => {
              const code = String(e.data || "").trim();
              if (!code) return;
              handleScan(code);
            }}
          />

          {/* Reticle */}
          <View pointerEvents="none" style={{ position:"absolute", left:0, right:0, top:0, bottom:0, alignItems:"center", justifyContent:"center" }}>
            <View style={{ width: 260, height: 120, borderColor: "#00FFA0", borderWidth: 3, borderRadius: 12 }} />
          </View>

          {/* Controls overlay */}
          <View style={{ position:"absolute", left:0, right:0, bottom:0, padding:12, gap:8, backgroundColor:"#0008" }}>
            <Text style={{ color:"#fff", textAlign:"center" }}>{hintText || "Align barcode in the box"}</Text>
            <View style={{ flexDirection:"row", justifyContent:"space-between", alignItems:"center" }}>
              <Pressable onPress={()=>setTorch(t=>!t)} style={{ padding:10, backgroundColor:"#fff2", borderRadius:8 }}>
                <Text style={{ color:"#fff" }}>{torch ? "Torch: On" : "Torch: Off"}</Text>
              </Pressable>
              <View style={{ flexDirection:"row", gap:8 }}>
                <Pressable onPress={()=>setZoom(z=>Math.max(0, +(z-0.05).toFixed(2)))} style={{ padding:10, backgroundColor:"#fff2", borderRadius:8 }}><Text style={{ color:"#fff" }}>Zoom −</Text></Pressable>
                <Pressable onPress={()=>setZoom(z=>Math.min(1, +(z+0.05).toFixed(2)))} style={{ padding:10, backgroundColor:"#fff2", borderRadius:8 }}><Text style={{ color:"#fff" }}>Zoom +</Text></Pressable>
              </View>
              <Pressable onPress={()=>{ setMode(m=>m==="us"?"all":"us"); reset(); }} style={{ padding:10, backgroundColor:"#fff2", borderRadius:8 }}>
                <Text style={{ color:"#fff" }}>{mode==="us" ? "Mode: US retail" : "Mode: All"}</Text>
              </Pressable>
            </View>
          </View>
        </>
      ) : (
        <Center>
          <Text style={{ color: c.text, fontSize: 18 }}>Processing…</Text>
          <Button title="Scan again" onPress={() => { setScanning(true); reset(); }} />
        </Center>
      )}
    </View>
  );
}

function Center({ children }: { children: React.ReactNode }) {
  return <View style={{ flex:1, alignItems:"center", justifyContent:"center", gap:12 }}>{children}</View>;
}
