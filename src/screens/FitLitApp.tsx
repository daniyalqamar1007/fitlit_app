"use client"

import { useState, useCallback, useMemo } from "react"
import { View, StyleSheet, Dimensions, ScrollView, StatusBar } from "react-native"
import { SafeAreaView } from "react-native-safe-area-context"
import { LinearGradient } from "expo-linear-gradient"
import * as Haptics from "expo-haptics"

import Header from "../components/Header"
import WeatherWidget from "../components/WeatherWidget"
import AvatarDisplay from "../components/AvatarDisplay"
import ClothingSelector from "../components/ClothingSelector"
import SocialPanel from "../components/SocialPanel"
import MetaPersonModal from "../components/MetaPersonModal"
import CacheSettingsModal from "../components/CacheSettingsModal"
import { useAvatar } from "../context/AvatarContext"
import { colors, spacing } from "../theme"

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get("window")
const IS_SMALL_DEVICE = SCREEN_WIDTH < 375

export default function FitLitApp() {
  const [selectedCategory, setSelectedCategory] = useState<"shirts" | "pants">("shirts")
  const [showAvatarCreator, setShowAvatarCreator] = useState(false)
  const [showCacheSettings, setShowCacheSettings] = useState(false)
  const [currentOutfit, setCurrentOutfit] = useState({
    shirt: null,
    pants: null,
  })

  const { avatarUrl, setAvatarUrl } = useAvatar()

  const handleAvatarCreated = useCallback(
    (url: string) => {
      setAvatarUrl(url)
      setShowAvatarCreator(false)
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success)
    },
    [setAvatarUrl],
  )

  const handleClothingSelect = useCallback((item: any, category: "shirts" | "pants") => {
    setCurrentOutfit((prev) => ({
      ...prev,
      [category]: item,
    }))
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light)
  }, [])

  const handleSaveOutfit = useCallback(() => {
    // Save outfit logic
    console.log("Saving outfit:", currentOutfit)
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success)
  }, [currentOutfit])

  const handleCategoryChange = useCallback((category: "shirts" | "pants") => {
    setSelectedCategory(category)
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light)
  }, [])

  const memoizedClothingSelector = useMemo(
    () => (
      <ClothingSelector
        selectedCategory={selectedCategory}
        onCategoryChange={handleCategoryChange}
        onItemSelect={handleClothingSelect}
        currentOutfit={currentOutfit}
      />
    ),
    [selectedCategory, handleCategoryChange, handleClothingSelect, currentOutfit],
  )

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" backgroundColor={colors.background} />

      <LinearGradient colors={[colors.gradientStart, colors.gradientEnd]} style={styles.gradient}>
        <ScrollView
          style={styles.scrollView}
          contentContainerStyle={styles.scrollContent}
          showsVerticalScrollIndicator={false}
          bounces={true}
        >
          {/* Header with Cache Settings */}
          <Header onSaveOutfit={handleSaveOutfit} onOpenSettings={() => setShowCacheSettings(true)} />

          {/* Weather Section */}
          <WeatherWidget />

          {/* Main Content */}
          <View style={styles.mainContent}>
            {/* Avatar Section */}
            <View style={styles.avatarSection}>
              <AvatarDisplay
                avatarUrl={avatarUrl}
                onCreateAvatar={() => setShowAvatarCreator(true)}
                onEditAvatar={() => setShowAvatarCreator(true)}
              />

              {!showAvatarCreator && memoizedClothingSelector}
            </View>

            {/* Social Panel */}
            <SocialPanel />
          </View>
        </ScrollView>

        {/* MetaPerson Modal */}
        <MetaPersonModal
          visible={showAvatarCreator}
          onAvatarCreated={handleAvatarCreated}
          onClose={() => setShowAvatarCreator(false)}
        />

        {/* Cache Settings Modal */}
        <CacheSettingsModal visible={showCacheSettings} onClose={() => setShowCacheSettings(false)} />
      </LinearGradient>
    </SafeAreaView>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  gradient: {
    flex: 1,
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingBottom: spacing.xl,
  },
  mainContent: {
    paddingHorizontal: spacing.md,
  },
  avatarSection: {
    marginBottom: spacing.lg,
  },
})
