import { memo } from "react"
import { View, Text, TextInput, TouchableOpacity, StyleSheet } from "react-native"
import Icon from "react-native-vector-icons/Feather"
import { BlurView } from "expo-blur"
import { colors, spacing, typography } from "../theme"

interface HeaderProps {
  onSaveOutfit: () => void
  onOpenSettings?: () => void
}

const Header = memo(({ onSaveOutfit, onOpenSettings }: HeaderProps) => {
  return (
    <View style={styles.container}>
      <BlurView intensity={20} style={styles.blurContainer}>
        <View style={styles.content}>
          {/* Search */}
          <View style={styles.searchContainer}>
            <Icon name="search" size={20} color={colors.textSecondary} />
            <TextInput placeholder="Search" placeholderTextColor={colors.textSecondary} style={styles.searchInput} />
          </View>

          {/* Logo */}
          <Text style={styles.logo}>FITLIT</Text>

          {/* Actions */}
          <View style={styles.actions}>
            {onOpenSettings && (
              <TouchableOpacity style={styles.settingsButton} onPress={onOpenSettings} activeOpacity={0.8}>
                <Icon name="settings" size={20} color={colors.textSecondary} />
              </TouchableOpacity>
            )}
            <TouchableOpacity style={styles.saveButton} onPress={onSaveOutfit} activeOpacity={0.8}>
              <Text style={styles.saveButtonText}>Save Outfit</Text>
            </TouchableOpacity>
          </View>
        </View>
      </BlurView>
    </View>
  )
})

const styles = StyleSheet.create({
  container: {
    marginBottom: spacing.md,
  },
  blurContainer: {
    borderRadius: 16,
    overflow: "hidden",
    marginHorizontal: spacing.md,
    marginTop: spacing.sm,
  },
  content: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.sm,
    backgroundColor: "rgba(255, 255, 255, 0.9)",
  },
  searchContainer: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "rgba(255, 255, 255, 0.8)",
    borderRadius: 12,
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
    flex: 1,
    marginRight: spacing.sm,
  },
  searchInput: {
    marginLeft: spacing.xs,
    flex: 1,
    fontSize: typography.body.fontSize,
    color: colors.textPrimary,
  },
  logo: {
    fontSize: typography.h2.fontSize,
    fontWeight: typography.h2.fontWeight as any,
    color: colors.primary,
    marginHorizontal: spacing.sm,
  },
  actions: {
    flexDirection: "row",
    alignItems: "center",
    gap: spacing.sm,
  },
  settingsButton: {
    padding: spacing.sm,
  },
  saveButton: {
    backgroundColor: colors.primary,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.sm,
    borderRadius: 12,
  },
  saveButtonText: {
    color: colors.white,
    fontSize: typography.button.fontSize,
    fontWeight: typography.button.fontWeight as any,
  },
})

export default Header
