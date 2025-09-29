// src/theme.tsx  (REPLACE) — Sage palette + easy themed colors/hooks
import React, { createContext, useContext, useEffect, useMemo, useState } from "react";
import { useColorScheme } from "react-native";
import * as SecureStore from "expo-secure-store";
import { DarkTheme as NavDark, DefaultTheme as NavLight, Theme } from "@react-navigation/native";

type Pref = "system" | "light" | "dark";
type Ctx = {
  themePref: Pref;
  setThemePref: (p: Pref) => void;
  autofill: boolean;
  setAutofill: (v: boolean) => void;
};
const ThemeCtx = createContext<Ctx | null>(null);

const KEY_THEME = "prefs_theme";
const KEY_AUTOFILL = "prefs_autofill";

// Sage palette
const sage = {
  primary: "#2F7D5B",
  primaryAlt: "#256a4d",
  light: {
    bg: "#FAFBFA",
    card: "#FFFFFF",
    text: "#0E1A14",
    subtext: "#4B5E55",
    border: "#D7E2DB",
    inputBg: "#FFFFFF"
  },
  dark: {
    bg: "#0D1512",
    card: "#111A17",
    text: "#E7F1EC",
    subtext: "#9DB5A9",
    border: "#2A3A33",
    inputBg: "#111A17"
  }
};

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

  return (
    <ThemeCtx.Provider value={{ themePref, setThemePref, autofill, setAutofill }}>
      {children}
    </ThemeCtx.Provider>
  );
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
  const base = mode === "dark" ? NavDark : NavLight;
  return {
    ...base,
    colors: {
      ...base.colors,
      primary: sage.primary,
      background: mode === "dark" ? sage.dark.bg : sage.light.bg,
      card: mode === "dark" ? sage.dark.card : sage.light.card,
      text: mode === "dark" ? sage.dark.text : sage.light.text,
      border: mode === "dark" ? sage.dark.border : sage.light.border,
      notification: sage.primary,
    },
  };
}

export function useSageColors() {
  const { themePref } = useThemePrefs();
  const system = useColorScheme();
  const isDark = (themePref === "system" ? (system ?? "light") : themePref) === "dark";
  const c = isDark ? sage.dark : sage.light;
  return { ...c, isDark, primary: sage.primary, primaryAlt: sage.primaryAlt };
}
