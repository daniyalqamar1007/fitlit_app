import { memo } from "react"
import { View, Text, TouchableOpacity, StyleSheet, Dimensions } from "react-native"
import FastImage from "react-native-fast-image"
import Icon from "react-native-vector-icons/Feather"
import { BlurView } from "expo-blur"
import { colors, spacing, typography } from "../theme"

const { width: SCREEN_WIDTH } = Dimensions.get("window")

const SocialPanel = memo(() => {
  return (
    <BlurView intensity={20} style={styles.container}>
      <View style={styles.content}>
        {/* Header */}
        <Text style={styles.title}>Social Media Page</Text>

        {/* Profile */}
        <View style={styles.profile}>
          <View style={styles.avatarContainer}>
            <FastImage
              source={{ uri: "/placeholder.svg?height=60&width=60" }}
              style={styles.profileAvatar}
              resizeMode={FastImage.resizeMode.cover}
            />
          </View>
          <Text style={styles.username}>Johnny Cage</Text>
          <Text style={styles.email}>johnnycage@gmail.com</Text>
        </View>

        {/* Current Outfit */}
        <View style={styles.outfitSection}>
          <View style={styles.outfitHeader}>
            <Text style={styles.outfitLabel}>Current Outfit</Text>
            <Text style={styles.outfitDate}>11 July</Text>
          </View>
        </View>

        {/* Avatar Preview */}
        <View style={styles.previewSection}>
          <FastImage
            source={{ uri: "/placeholder.svg?height=120&width=80" }}
            style={styles.previewAvatar}
            resizeMode={FastImage.resizeMode.contain}
          />
        </View>

        {/* Social Actions */}
        <View style={styles.actions}>
          <TouchableOpacity style={[styles.actionButton, styles.likeButton]} activeOpacity={0.8}>
            <Icon name="heart" size={16} color={colors.white} />
            <Text style={styles.actionText}>Like Outfit</Text>
          </TouchableOpacity>

          <TouchableOpacity style={[styles.actionButton, styles.commentButton]} activeOpacity={0.8}>
            <Icon name="message-circle" size={16} color={colors.white} />
            <Text style={styles.actionText}>Comment</Text>
          </TouchableOpacity>

          <TouchableOpacity style={[styles.actionButton, styles.shareButton]} activeOpacity={0.8}>
            <Icon name="share" size={16} color={colors.white} />
            <Text style={styles.actionText}>Share</Text>
          </TouchableOpacity>
        </View>

        {/* Stats */}
        <View style={styles.stats}>
          <Text style={styles.statsText}>x 100 views today</Text>
        </View>
      </View>
    </BlurView>
  )
})

const styles = StyleSheet.create({
  container: {
    borderRadius: 20,
    overflow: "hidden",
    marginTop: spacing.md,
  },
  content: {
    padding: spacing.md,
    backgroundColor: "rgba(255, 255, 255, 0.9)",
  },
  title: {
    fontSize: typography.h3.fontSize,
    fontWeight: typography.h3.fontWeight as any,
    color: colors.primary,
    textAlign: "center",
    marginBottom: spacing.md,
  },
  profile: {
    alignItems: "center",
    marginBottom: spacing.md,
  },
  avatarContainer: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: colors.primaryLight,
    justifyContent: "center",
    alignItems: "center",
    marginBottom: spacing.sm,
  },
  profileAvatar: {
    width: 48,
    height: 48,
    borderRadius: 24,
  },
  username: {
    fontSize: typography.body.fontSize,
    fontWeight: typography.body.fontWeight as any,
    color: colors.textPrimary,
    marginBottom: spacing.xs,
  },
  email: {
    fontSize: typography.caption.fontSize,
    color: colors.textSecondary,
  },
  outfitSection: {
    marginBottom: spacing.md,
  },
  outfitHeader: {
    backgroundColor: colors.primaryLight,
    borderRadius: 12,
    padding: spacing.md,
    alignItems: "center",
  },
  outfitLabel: {
    fontSize: typography.caption.fontSize,
    color: colors.primary,
    marginBottom: spacing.xs,
  },
  outfitDate: {
    fontSize: typography.h3.fontSize,
    fontWeight: typography.h3.fontWeight as any,
    color: colors.primary,
  },
  previewSection: {
    backgroundColor: colors.gradientLight,
    borderRadius: 12,
    padding: spacing.md,
    alignItems: "center",
    marginBottom: spacing.md,
  },
  previewAvatar: {
    width: 60,
    height: 90,
  },
  actions: {
    marginBottom: spacing.md,
  },
  actionButton: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    paddingVertical: spacing.sm,
    borderRadius: 12,
    marginBottom: spacing.sm,
  },
  likeButton: {
    backgroundColor: colors.error,
  },
  commentButton: {
    backgroundColor: colors.info,
  },
  shareButton: {
    backgroundColor: colors.success,
  },
  actionText: {
    color: colors.white,
    fontSize: typography.caption.fontSize,
    fontWeight: typography.button.fontWeight as any,
    marginLeft: spacing.xs,
  },
  stats: {
    paddingTop: spacing.md,
    borderTopWidth: 1,
    borderTopColor: colors.border,
    alignItems: "center",
  },
  statsText: {
    fontSize: typography.caption.fontSize,
    color: colors.textSecondary,
  },
})

export default SocialPanel
