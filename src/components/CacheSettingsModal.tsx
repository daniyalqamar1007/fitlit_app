"use client"

import { memo, useState } from "react"
import { View, Text, TouchableOpacity, StyleSheet, Alert, Switch } from "react-native"
import Modal from "react-native-modal"
import Icon from "react-native-vector-icons/Feather"
import { BlurView } from "expo-blur"
import * as Haptics from "expo-haptics"
import { colors, spacing, typography } from "../theme"
import { useCacheManager } from "../hooks/useOptimizedAvatar"

interface CacheSettingsModalProps {
  visible: boolean
  onClose: () => void
}

const CacheSettingsModal = memo(({ visible, onClose }: CacheSettingsModalProps) => {
  const { cacheStats, refreshStats, clearCache } = useCacheManager()
  const [autoPreload, setAutoPreload] = useState(true)
  const [highQualityCache, setHighQualityCache] = useState(true)

  const formatFileSize = (bytes: number): string => {
    if (bytes === 0) return "0 B"
    const k = 1024
    const sizes = ["B", "KB", "MB", "GB"]
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return `${Number.parseFloat((bytes / Math.pow(k, i)).toFixed(1))} ${sizes[i]}`
  }

  const formatDate = (timestamp: number): string => {
    if (timestamp === 0) return "Never"
    return new Date(timestamp).toLocaleDateString()
  }

  const handleClearCache = () => {
    Alert.alert(
      "Clear Cache",
      "This will delete all cached avatar images. They will need to be downloaded again when accessed.",
      [
        { text: "Cancel", style: "cancel" },
        {
          text: "Clear",
          style: "destructive",
          onPress: async () => {
            try {
              await clearCache()
              Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success)
              Alert.alert("Success", "Cache cleared successfully!")
            } catch (error) {
              Alert.alert("Error", "Failed to clear cache. Please try again.")
            }
          },
        },
      ],
    )
  }

  const handleRefreshStats = async () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light)
    await refreshStats()
  }

  const handleClose = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light)
    onClose()
  }

  return (
    <Modal
      isVisible={visible}
      style={styles.modal}
      animationIn="slideInUp"
      animationOut="slideOutDown"
      backdropOpacity={0.7}
      onBackdropPress={handleClose}
      onBackButtonPress={handleClose}
    >
      <BlurView intensity={20} style={styles.container}>
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.title}>Cache Settings</Text>
          <TouchableOpacity style={styles.closeButton} onPress={handleClose} activeOpacity={0.8}>
            <Icon name="x" size={24} color={colors.textSecondary} />
          </TouchableOpacity>
        </View>

        {/* Cache Statistics */}
        <View style={styles.section}>
          <View style={styles.sectionHeader}>
            <Text style={styles.sectionTitle}>Cache Statistics</Text>
            <TouchableOpacity onPress={handleRefreshStats} activeOpacity={0.8}>
              <Icon name="refresh-cw" size={20} color={colors.primary} />
            </TouchableOpacity>
          </View>

          <View style={styles.statsGrid}>
            <View style={styles.statItem}>
              <Icon name="hard-drive" size={24} color={colors.primary} />
              <Text style={styles.statValue}>{formatFileSize(cacheStats.totalSize)}</Text>
              <Text style={styles.statLabel}>Total Size</Text>
            </View>

            <View style={styles.statItem}>
              <Icon name="image" size={24} color={colors.info} />
              <Text style={styles.statValue}>{cacheStats.itemCount}</Text>
              <Text style={styles.statLabel}>Cached Items</Text>
            </View>

            <View style={styles.statItem}>
              <Icon name="calendar" size={24} color={colors.success} />
              <Text style={styles.statValue}>{formatDate(cacheStats.oldestItem)}</Text>
              <Text style={styles.statLabel}>Oldest Item</Text>
            </View>

            <View style={styles.statItem}>
              <Icon name="clock" size={24} color={colors.warning} />
              <Text style={styles.statValue}>{formatDate(cacheStats.newestItem)}</Text>
              <Text style={styles.statLabel}>Newest Item</Text>
            </View>
          </View>
        </View>

        {/* Cache Settings */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Settings</Text>

          <View style={styles.settingItem}>
            <View style={styles.settingInfo}>
              <Icon name="download" size={20} color={colors.textPrimary} />
              <View style={styles.settingText}>
                <Text style={styles.settingTitle}>Auto Preload</Text>
                <Text style={styles.settingDescription}>Automatically cache recent avatars for faster loading</Text>
              </View>
            </View>
            <Switch
              value={autoPreload}
              onValueChange={setAutoPreload}
              trackColor={{ false: colors.lightGray, true: colors.primaryLight }}
              thumbColor={autoPreload ? colors.primary : colors.gray}
            />
          </View>

          <View style={styles.settingItem}>
            <View style={styles.settingInfo}>
              <Icon name="image" size={20} color={colors.textPrimary} />
              <View style={styles.settingText}>
                <Text style={styles.settingTitle}>High Quality Cache</Text>
                <Text style={styles.settingDescription}>Cache full resolution images (uses more storage)</Text>
              </View>
            </View>
            <Switch
              value={highQualityCache}
              onValueChange={setHighQualityCache}
              trackColor={{ false: colors.lightGray, true: colors.primaryLight }}
              thumbColor={highQualityCache ? colors.primary : colors.gray}
            />
          </View>
        </View>

        {/* Actions */}
        <View style={styles.actions}>
          <TouchableOpacity style={styles.clearButton} onPress={handleClearCache} activeOpacity={0.8}>
            <Icon name="trash-2" size={20} color={colors.white} />
            <Text style={styles.clearButtonText}>Clear All Cache</Text>
          </TouchableOpacity>
        </View>

        {/* Cache Info */}
        <View style={styles.infoSection}>
          <Text style={styles.infoText}>
            Cache helps load avatars faster by storing them locally. Clearing cache will free up storage but avatars
            will need to be downloaded again.
          </Text>
        </View>
      </BlurView>
    </Modal>
  )
})

const styles = StyleSheet.create({
  modal: {
    margin: 0,
    justifyContent: "flex-end",
  },
  container: {
    maxHeight: "80%",
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    overflow: "hidden",
    backgroundColor: "rgba(255, 255, 255, 0.95)",
  },
  header: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: colors.border,
  },
  title: {
    fontSize: typography.h2.fontSize,
    fontWeight: typography.h2.fontWeight as any,
    color: colors.primary,
  },
  closeButton: {
    padding: spacing.sm,
  },
  section: {
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: colors.borderLight,
  },
  sectionHeader: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    marginBottom: spacing.md,
  },
  sectionTitle: {
    fontSize: typography.h3.fontSize,
    fontWeight: typography.h3.fontWeight as any,
    color: colors.textPrimary,
  },
  statsGrid: {
    flexDirection: "row",
    flexWrap: "wrap",
    justifyContent: "space-between",
  },
  statItem: {
    width: "48%",
    alignItems: "center",
    padding: spacing.md,
    backgroundColor: colors.surface,
    borderRadius: 12,
    marginBottom: spacing.sm,
  },
  statValue: {
    fontSize: typography.h3.fontSize,
    fontWeight: typography.h3.fontWeight as any,
    color: colors.textPrimary,
    marginTop: spacing.xs,
  },
  statLabel: {
    fontSize: typography.caption.fontSize,
    color: colors.textSecondary,
    marginTop: spacing.xs,
    textAlign: "center",
  },
  settingItem: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingVertical: spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: colors.borderLight,
  },
  settingInfo: {
    flexDirection: "row",
    alignItems: "center",
    flex: 1,
  },
  settingText: {
    marginLeft: spacing.md,
    flex: 1,
  },
  settingTitle: {
    fontSize: typography.body.fontSize,
    fontWeight: typography.body.fontWeight as any,
    color: colors.textPrimary,
    marginBottom: spacing.xs,
  },
  settingDescription: {
    fontSize: typography.caption.fontSize,
    color: colors.textSecondary,
  },
  actions: {
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.md,
  },
  clearButton: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: colors.error,
    paddingVertical: spacing.md,
    borderRadius: 12,
  },
  clearButtonText: {
    color: colors.white,
    fontSize: typography.button.fontSize,
    fontWeight: typography.button.fontWeight as any,
    marginLeft: spacing.sm,
  },
  infoSection: {
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.md,
    backgroundColor: colors.primaryLight,
  },
  infoText: {
    fontSize: typography.caption.fontSize,
    color: colors.primary,
    textAlign: "center",
    lineHeight: 18,
  },
})

export default CacheSettingsModal
