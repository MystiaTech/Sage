// src/screens/ScanScreen.tsx  (REPLACE)
import React, { useEffect, useRef, useState } from "react";
import { View, Text, Button, Pressable, Image } from "react-native";
import { CameraView, useCameraPermissions } from "expo-camera";
import { findBestCandidate, type NormalizedBarcode } from "../barcode";
import { useSageColors } from "../theme";
import { fetchProductByBarcode } from "../fetchProduct";

type Mode = "us" | "all";
type PreviewState = { n: NormalizedBarcode; name?: string; brand?: string; imageUrl?: string|null };

export default function ScanScreen({ navigation }: any) {
  const c = useSageColors();
  const [permission, requestPermission] = useCameraPermissions();
  const [scanning, setScanning] = useState(true);
  const [torch, setTorch] = useState(false);
  const [zoom, setZoom] = useState(0.05);
  const [mode, setMode] = useState<Mode>("us");
  const [hintText, setHintText] = useState<string>("");
  const [preview, setPreview] = useState<PreviewState | null>(null);

  const REQUIRED_HITS = 3;
  const hits = useRef<Map<string, number>>(new Map());

  useEffect(() => { if (permission && !permission.granted) requestPermission(); }, [permission]);

  function reset() { hits.current.clear(); setHintText(""); setPreview(null); }
  function startScan() { setScanning(true); reset(); }

  async function showPreview(n: NormalizedBarcode) {
    setScanning(false);
    setHintText("Looking up…");
    try {
      const info = await fetchProductByBarcode(n.canonical);
      setPreview({
        n,
        name: info?.name,
        brand: info?.brand,
        imageUrl: info?.imageUrl ?? null
      });
      setHintText("");
    } catch {
      setPreview({ n });
      setHintText("");
    }
  }

  function handleScanPayload(raw: string) {
    const candidate = findBestCandidate(raw, mode === "us");
    if (!candidate) { setHintText("Scanning… (valid UPC-A/EAN-13 only)"); return; }
    const key = candidate.canonical;
    const prev = hits.current.get(key) || 0;
    const next = prev + 1;
    hits.current.set(key, next);

    const label = candidate.upc12 ? `UPC-12 ${candidate.upc12} • GTIN-13 ${candidate.canonical}` : `GTIN-13 ${candidate.canonical}`;
    setHintText(`${label}  (${next}/${REQUIRED_HITS})`);

    if (next >= REQUIRED_HITS) { showPreview(candidate); }
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

  const typesUS = ["ean13","upc_a"];
  const typesAll = ["ean13","ean8","upc_a","upc_e"];
  const types = mode === "us" ? typesUS : typesAll;

  return (
    <View style={{ flex: 1, backgroundColor: c.bg }}>
      {scanning ? (
        <>
          <CameraView
            style={{ flex: 1 }}
            facing="back"
            enableZoomGesture
            enableTorch={torch}
            zoom={zoom}
            barcodeScannerSettings={{ barcodeTypes: types }}
            onBarcodeScanned={(e) => {
              const payload = String(e.data ?? "").trim();
              if (!payload) return;
              handleScanPayload(payload);
            }}
          />
          {/* Reticle */}
          <View pointerEvents="none" style={{ position:"absolute", left:0, right:0, top:0, bottom:0, alignItems:"center", justifyContent:"center" }}>
            <View style={{ width: 260, height: 120, borderColor: "#00FFA0", borderWidth: 3, borderRadius: 12 }} />
          </View>
          {/* Controls */}
          <Controls
            torch={torch} setTorch={setTorch}
            zoom={zoom} setZoom={setZoom}
            mode={mode} setMode={setMode}
            hintText={hintText}
          />
        </>
      ) : preview ? (
        <VerifyCard preview={preview} onUse={() => {
          navigation.replace("AddItem", {
            barcode: preview.n.canonical,
            prefill: { name: preview.name, brand: preview.brand, imageUrl: preview.imageUrl }
          });
          reset();
        }} onRescan={startScan} />
      ) : (
        <Center>
          <Text style={{ color: c.text, fontSize: 18 }}>Processing…</Text>
          <Button title="Scan again" onPress={startScan} />
        </Center>
      )}
    </View>
  );
}

function Controls({ torch, setTorch, zoom, setZoom, mode, setMode, hintText }:{
  torch:boolean; setTorch:(v:boolean|((t:boolean)=>boolean))=>void;
  zoom:number; setZoom:(fn:(z:number)=>number)=>void;
  mode:"us"|"all"; setMode:(fn:(m:"us"|"all")=>"us"|"all")=>void;
  hintText:string;
}) {
  return (
    <View style={{ position:"absolute", left:0, right:0, bottom:0, padding:12, gap:8, backgroundColor:"#0008" }}>
      <Text style={{ color:"#fff", textAlign:"center" }}>{hintText || "Align barcode in the box"}</Text>
      <View style={{ flexDirection:"row", justifyContent:"space-between", alignItems:"center" }}>
        <Pressable onPress={()=>setTorch(t=>!t)} style={{ padding:10, backgroundColor:"#fff2", borderRadius:8 }}>
          <Text style={{ color:"#fff" }}>{torch ? "Torch: On" : "Torch: Off"}</Text>
        </Pressable>
        <View style={{ flexDirection:"row", gap:8 }}>
          <Pressable onPress={()=>setZoom(z=>Math.max(0, +(z-0.05).toFixed(2)))} style={{ padding:10, backgroundColor:"#fff2", borderRadius:8 }}>
            <Text style={{ color:"#fff" }}>Zoom −</Text>
          </Pressable>
          <Pressable onPress={()=>setZoom(z=>Math.min(1, +(z+0.05).toFixed(2)))} style={{ padding:10, backgroundColor:"#fff2", borderRadius:8 }}>
            <Text style={{ color:"#fff" }}>Zoom +</Text>
          </Pressable>
        </View>
        <Pressable onPress={()=>setMode(m=>m==="us"?"all":"us")} style={{ padding:10, backgroundColor:"#fff2", borderRadius:8 }}>
          <Text style={{ color:"#fff" }}>{mode==="us" ? "Mode: US retail" : "Mode: All"}</Text>
        </Pressable>
      </View>
    </View>
  );
}

function VerifyCard({ preview, onUse, onRescan }:{ preview: PreviewState; onUse:()=>void; onRescan:()=>void }) {
  const c = useSageColors();
  return (
    <View style={{ flex:1, padding:16, backgroundColor:c.bg }}>
      <Text style={{ color:c.text, fontSize:18, fontWeight:"700", marginBottom:10 }}>Verify product</Text>
      <View style={{ borderWidth:1, borderColor:c.border, borderRadius:12, backgroundColor:c.card, padding:12 }}>
        {!!preview.imageUrl && <Image source={{ uri: preview.imageUrl }} style={{ width:"100%", height: 200, borderRadius: 10, marginBottom:10 }} resizeMode="cover" />}
        <Text style={{ color:c.text, fontWeight:"600" }}>{preview.name || "(no name from database)"}</Text>
        <Text style={{ color:c.subtext }}>{preview.brand || ""}</Text>
        <Text style={{ color:c.text, marginTop:6 }}>
          {preview.n.upc12 ? `UPC-12: ${preview.n.upc12}  •  GTIN-13: ${preview.n.canonical}` : `GTIN-13: ${preview.n.canonical}`}
        </Text>
        <View style={{ height:10 }} />
        <Button title="Looks correct" onPress={onUse} />
        <View style={{ height:6 }} />
        <Button title="Scan again" onPress={onRescan} />
      </View>
    </View>
  );
}

function Center({ children }: { children: React.ReactNode }) {
  return <View style={{ flex:1, alignItems:"center", justifyContent:"center", gap:12 }}>{children}</View>;
}
