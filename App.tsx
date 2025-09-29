// App.tsx
import React, { useEffect } from "react";
import { View, Button } from "react-native";
import { NavigationContainer } from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";

import Dashboard from "./src/screens/Dashboard";
import Inventory from "./src/screens/Inventory";
import ScanScreen from "./src/screens/ScanScreen";
import AddItem from "./src/screens/AddItem";
import Settings from "./src/screens/Settings";
import { runMigrations } from "./src/db";

const Stack = createNativeStackNavigator();

export default function App() {
  useEffect(() => {
    (async () => { await runMigrations(); })();
  }, []);

  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen
          name="Dashboard"
          component={Dashboard}
          options={({ navigation }) => ({
            title: "Sage",
            headerRight: () => (
              <View style={{ flexDirection: "row" }}>
                <View style={{ marginLeft: 8 }}>
                  <Button title="Scan" onPress={() => navigation.navigate("Scan" as never)} />
                </View>
                <View style={{ marginLeft: 8 }}>
                  <Button title="Inventory" onPress={() => navigation.navigate("Inventory" as never)} />
                </View>
                <View style={{ marginLeft: 8 }}>
                  <Button title="Settings" onPress={() => navigation.navigate("Settings" as never)} />
                </View>
              </View>
            )
          })}
        />
        <Stack.Screen name="Inventory" component={Inventory} />
        <Stack.Screen name="Scan" component={ScanScreen} />
        <Stack.Screen name="AddItem" component={AddItem} />
        <Stack.Screen name="Settings" component={Settings} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
