// src/theme.tsx  (NEW) — system/light/dark switch + nav theme
import React, { createContext, useContext, useEffect, useMemo, useState } from "react";
import { useColorScheme } from "react-native";
import * as SecureStore from "expo-secure-store";
import { DarkTheme, DefaultTheme, Theme } from "@react-navigation/native";

type Pref = "system" | "light" | "dark";
type Ctx = {
  themePref: Pref;
  setThemePref: (p: Pref) => void;
  autofill: boolean;
  setAutofill: (v: boolean) => void;
};
const ThemeCtx = createContext<Ctx | null>(null);

const KEY_THEME = "prefs_theme";      // [A-Za-z0-9._-] only
const KEY_AUTOFILL = "prefs_autofill";

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [themePref, setThemePref] = useState<Pref>("system");
  const [autofill, setAutofill] = useState<boolean>(true);

  useEffect(() => {
    (async () => {
      const t = (await SecureStore.getItemAsync(KEY_THEME)) as Pref | null;
      const a = await SecureStore.getItemAsync(KEY_AUTOFILL);
      if (t) setThemePref(t);
      if (a != null) setAutofill(a === "1");
    })();
  }, []);

  useEffect(() => { SecureStore.setItemAsync(KEY_THEME, themePref); }, [themePref]);
  useEffect(() => { SecureStore.setItemAsync(KEY_AUTOFILL, autofill ? "1" : "0"); }, [autofill]);

  const value = useMemo(() => ({ themePref, setThemePref, autofill, setAutofill }), [themePref, autofill]);
  return <ThemeCtx.Provider value={value}>{children}</ThemeCtx.Provider>;
}

export function useThemePrefs() {
  const ctx = useContext(ThemeCtx);
  if (!ctx) throw new Error("useThemePrefs outside ThemeProvider");
  return ctx;
}

export function useNavTheme(): Theme {
  const { themePref } = useThemePrefs();
  const system = useColorScheme(); // "light" | "dark" | null
  const mode = themePref === "system" ? (system ?? "light") : themePref;
  return mode === "dark" ? DarkTheme : DefaultTheme;
}
