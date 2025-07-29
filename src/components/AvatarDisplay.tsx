"use client"

import { memo, useState, useEffect } from "react"
import { View, Text, TouchableOpacity, StyleSheet, Dimensions, Alert } from "react-native"
import { LinearGradient } from "expo-linear-gradient"
import { BlurView } from "expo-blur"
import Icon from "react-native-vector-icons/Feather"
import * as Haptics from "expo-haptics"
import OptimizedAvatarImage from "./OptimizedAvatarImage"
import { colors, spacing, typography } from "../theme"
import { useAvatar } from "../context/AvatarContext"
import { useAvatarPreloader } from "../hooks/useOptimizedAvatar"

const { width: SCREEN_WIDTH } = Dimensions.get("window")
const AVATAR_SIZE = { width: SCREEN_WIDTH * 0.6, height: SCREEN_WIDTH * 0.72 }

interface AvatarDisplayProps {
  avatarUrl: string | null
  onCreateAvatar: () => void
  onEditAvatar: () => void
}

const AvatarDisplay = memo(({ avatarUrl, onCreateAvatar, onEditAvatar }: AvatarDisplayProps) => {
  const { currentAvatar, deleteAvatar, isMetaPersonConfigured, error, avatars } = useAvatar()
  const { preloadAvatars, isPreloading } = useAvatarPreloader()
  const [imageLoadError, setImageLoadError] = useState<string | null>(null)

  // Preload recent avatars for better performance
  useEffect(() => {
    if (avatars.length > 1) {
      const recentAvatarUrls = avatars.slice(1, 4).map((avatar) => avatar.url)
      preloadAvatars(recentAvatarUrls)
    }
  }, [avatars, preloadAvatars])

  const handleDeleteAvatar = () => {
    if (!currentAvatar) return

    Alert.alert("Delete Avatar", "Are you sure you want to delete this avatar? This action cannot be undone.", [
      { text: "Cancel", style: "cancel" },
      {
        text: "Delete",
        style: "destructive",
        onPress: async () => {
          try {
            await deleteAvatar(currentAvatar.id)
            Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success)
          } catch (err) {
            Alert.alert("Error", "Failed to delete avatar. Please try again.")
          }
        },
      },
    ])
  }

  const handleCreateAvatar = () => {
    if (!isMetaPersonConfigured) {
      Alert.alert(
        "Configuration Required",
        "MetaPerson is not configured. Please check your credentials in the app settings.",
        [{ text: "OK", style: "default" }],
      )
      return
    }

    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light)
    onCreateAvatar()
  }

  const handleEditAvatar = () => {
    if (!isMetaPersonConfigured) {
      Alert.alert(
        "Configuration Required",
        "MetaPerson is not configured. Please check your credentials in the app settings.",
        [{ text: "OK", style: "default" }],
      )
      return
    }

    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light)
    onEditAvatar()
  }

  const handleImageLoad = () => {
    setImageLoadError(null)
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light)
  }

  const handleImageError = (errorMessage: string) => {
    setImageLoadError(errorMessage)
    console.error("Avatar image error:", errorMessage)
  }

  return (
    <BlurView intensity={20} style={styles.container}>
      <LinearGradient colors={[colors.gradientLight, colors.white]} style={styles.avatarContainer}>
        {avatarUrl && !imageLoadError ? (
          <View style={styles.avatarWrapper}>
            {/* Optimized Avatar Image */}
            <OptimizedAvatarImage
              url={avatarUrl}
              size={AVATAR_SIZE}
              priority="high"
              progressive={true}
              fallbackUrl="/placeholder.svg?height=300&width=240&text=Avatar"
              onLoad={handleImageLoad}
              onError={handleImageError}
              style={styles.avatarImage}
            />

            {/* Avatar Controls */}
            <View style={styles.avatarControls}>
              <TouchableOpacity style={styles.editButton} onPress={handleEditAvatar} activeOpacity={0.8}>
                <Icon name="edit-3" size={16} color={colors.white} />
                <Text style={styles.editButtonText}>Edit</Text>
              </TouchableOpacity>

              <TouchableOpacity style={styles.deleteButton} onPress={handleDeleteAvatar} activeOpacity={0.8}>
                <Icon name="trash-2" size={16} color={colors.white} />
              </TouchableOpacity>
            </View>

            {/* Avatar Info */}
            {currentAvatar && (
              <View style={styles.avatarInfo}>
                <Text style={styles.avatarInfoText}>
                  Created: {new Date(currentAvatar.createdAt).toLocaleDateString()}
                </Text>
                <Text style={styles.avatarInfoText}>Format: {currentAvatar.format.toUpperCase()}</Text>
                {currentAvatar.metadata?.fileSize && (
                  <Text style={styles.avatarInfoText}>
                    Size: {(currentAvatar.metadata.fileSize / 1024 / 1024).toFixed(1)} MB
                  </Text>
                )}
              </View>
            )}

            {/* Preloading Indicator */}
            {isPreloading && (
              <View style={styles.preloadingIndicator}>
                <Icon name="download" size={12} color={colors.primary} />
                <Text style={styles.preloadingText}>Optimizing...</Text>
              </View>
            )}
          </View>
        ) : (
          <View style={styles.placeholderContainer}>
            {error && !isMetaPersonConfigured ? (
              <View style={styles.errorPlaceholder}>
                <Icon name="alert-triangle" size={48} color={colors.warning} />
                <Text style={styles.errorTitle}>Configuration Required</Text>
                <Text style={styles.errorText}>Please configure your MetaPerson credentials to create avatars.</Text>
              </View>
            ) : imageLoadError ? (
              <View style={styles.errorPlaceholder}>
                <Icon name="image" size={48} color={colors.error} />
                <Text style={styles.errorTitle}>Image Load Error</Text>
                <Text style={styles.errorText}>{imageLoadError}</Text>
                <TouchableOpacity style={styles.retryButton} onPress={handleCreateAvatar} activeOpacity={0.8}>
                  <Icon name="refresh-cw" size={16} color={colors.white} />
                  <Text style={styles.retryButtonText}>Create New Avatar</Text>
                </TouchableOpacity>
              </View>
            ) : (
              <LinearGradient colors={[colors.primaryLight, colors.primary]} style={styles.placeholder}>
                <Icon name="user-plus" size={48} color={colors.white} />
                <TouchableOpacity style={styles.createButton} onPress={handleCreateAvatar} activeOpacity={0.8}>
                  <Text style={styles.createButtonText}>Create Avatar</Text>
                </TouchableOpacity>
                <Text style={styles.createSubtext}>Use MetaPerson to create your 3D avatar</Text>
              </LinearGradient>
            )}
          </View>
        )}
      </LinearGradient>
    </BlurView>
  )
})

const styles = StyleSheet.create({
  container: {
    borderRadius: 20,
    overflow: "hidden",
    marginBottom: spacing.md,
  },
  avatarContainer: {
    alignItems: "center",
    paddingVertical: spacing.xl,
    backgroundColor: "rgba(255, 255, 255, 0.9)",
  },
  avatarWrapper: {
    position: "relative",
    alignItems: "center",
  },
  avatarImage: {
    elevation: 8,
    shadowColor: colors.shadow,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
  },
  avatarControls: {
    position: "absolute",
    bottom: spacing.md,
    right: spacing.md,
    flexDirection: "row",
    gap: spacing.sm,
  },
  editButton: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: colors.primary,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.sm,
    borderRadius: 12,
    elevation: 4,
    shadowColor: colors.shadow,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
  },
  editButtonText: {
    color: colors.white,
    fontSize: typography.caption.fontSize,
    fontWeight: typography.button.fontWeight as any,
    marginLeft: spacing.xs,
  },
  deleteButton: {
    backgroundColor: colors.error,
    padding: spacing.sm,
    borderRadius: 12,
    justifyContent: "center",
    alignItems: "center",
    elevation: 4,
    shadowColor: colors.shadow,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
  },
  avatarInfo: {
    position: "absolute",
    bottom: -spacing.xl,
    alignItems: "center",
  },
  avatarInfoText: {
    fontSize: typography.caption.fontSize,
    color: colors.textSecondary,
    marginBottom: spacing.xs,
  },
  preloadingIndicator: {
    position: "absolute",
    top: spacing.sm,
    right: spacing.sm,
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "rgba(255, 255, 255, 0.9)",
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
    borderRadius: 8,
  },
  preloadingText: {
    fontSize: typography.caption.fontSize,
    color: colors.primary,
    marginLeft: spacing.xs,
    fontWeight: "600",
  },
  placeholderContainer: {
    alignItems: "center",
  },
  placeholder: {
    width: AVATAR_SIZE.width,
    height: AVATAR_SIZE.height,
    borderRadius: 16,
    justifyContent: "center",
    alignItems: "center",
    padding: spacing.lg,
  },
  createButton: {
    backgroundColor: "rgba(255, 255, 255, 0.2)",
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
    borderRadius: 12,
    marginTop: spacing.md,
  },
  createButtonText: {
    color: colors.white,
    fontSize: typography.button.fontSize,
    fontWeight: typography.button.fontWeight as any,
  },
  createSubtext: {
    color: "rgba(255, 255, 255, 0.8)",
    fontSize: typography.caption.fontSize,
    textAlign: "center",
    marginTop: spacing.sm,
  },
  errorPlaceholder: {
    width: AVATAR_SIZE.width,
    height: AVATAR_SIZE.height,
    justifyContent: "center",
    alignItems: "center",
    padding: spacing.lg,
  },
  errorTitle: {
    fontSize: typography.h3.fontSize,
    fontWeight: typography.h3.fontWeight as any,
    color: colors.textPrimary,
    marginTop: spacing.md,
    marginBottom: spacing.sm,
    textAlign: "center",
  },
  errorText: {
    fontSize: typography.body.fontSize,
    color: colors.textSecondary,
    textAlign: "center",
    marginBottom: spacing.md,
  },
  retryButton: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: colors.primary,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
    borderRadius: 12,
  },
  retryButtonText: {
    color: colors.white,
    fontSize: typography.button.fontSize,
    fontWeight: typography.button.fontWeight as any,
    marginLeft: spacing.xs,
  },
})

export default AvatarDisplay
