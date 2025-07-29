import { StatusBar } from "expo-status-bar"
import { SafeAreaProvider } from "react-native-safe-area-context"
import { GestureHandlerRootView } from "react-native-gesture-handler"
import FitLitApp from "./src/screens/FitLitApp"
import { AvatarProvider } from "./src/context/AvatarContext"
import { ThemeProvider } from "./src/context/ThemeContext"

export default function App() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <SafeAreaProvider>
        <ThemeProvider>
          <AvatarProvider>
            <StatusBar style="dark" backgroundColor="#FEF3C7" />
            <FitLitApp />
          </AvatarProvider>
        </ThemeProvider>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  )
}
