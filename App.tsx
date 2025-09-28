// App.tsx
import React, { useEffect } from "react";
import { NavigationContainer } from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";
import Dashboard from "./src/screens/Dashboard";
import Inventory from "./src/screens/Inventory";
import AddItem from "./src/screens/AddItem";
import ScanScreen from "./src/screens/ScanScreen";
import { runMigrations } from "./src/db";
import { Button } from "react-native";

type RootStackParamList = {
  Dashboard: undefined;
  Inventory: undefined;
  Scan: undefined;
  AddItem: { barcode?: string };
};

const Stack = createNativeStackNavigator<RootStackParamList>();

export default function App() {
  useEffect(() => { (async () => { await runMigrations(); })(); }, []);

  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen
          name="Dashboard"
          component={Dashboard}
          options={({ navigation }) => ({
            title: "Sage",
            headerRight: () => (
              <>
                <Button title="Scan" onPress={() => navigation.navigate("Scan")} />
                <Button title="Inventory" onPress={() => navigation.navigate("Inventory")} />
              </>
            ),
          })}
        />
        <Stack.Screen name="Inventory" component={Inventory} />
        <Stack.Screen name="Scan" component={ScanScreen} options={{ title: "Scan" }} />
        <Stack.Screen name="AddItem" component={AddItem} options={{ title: "Add Item" }} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
