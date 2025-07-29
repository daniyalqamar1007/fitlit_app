"use client"

import { memo, useState, useCallback } from "react"
import { View, StyleSheet, Dimensions, ActivityIndicator } from "react-native"
import FastImage from "react-native-fast-image"
import { LinearGradient } from "expo-linear-gradient"
import { BlurView } from "expo-blur"
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withSpring,
  interpolate,
  runOnJS,
} from "react-native-reanimated"
import { useOptimizedAvatar } from "../hooks/useOptimizedAvatar"
import { colors, spacing } from "../theme"

const { width: SCREEN_WIDTH } = Dimensions.get("window")

interface OptimizedAvatarImageProps {
  url: string | null
  size?: { width: number; height: number }
  priority?: "high" | "normal" | "low"
  progressive?: boolean
  fallbackUrl?: string
  onLoad?: () => void
  onError?: (error: string) => void
  style?: any
}

const OptimizedAvatarImage = memo(
  ({
    url,
    size = { width: SCREEN_WIDTH * 0.6, height: SCREEN_WIDTH * 0.72 },
    priority = "normal",
    progressive = true,
    fallbackUrl,
    onLoad,
    onError,
    style,
  }: OptimizedAvatarImageProps) => {
    const { thumbnail, fullImage, isLoading, progress, error, retry } = useOptimizedAvatar(url, {
      priority,
      progressive,
      fallbackUrl,
    })

    const [thumbnailLoaded, setThumbnailLoaded] = useState(false)
    const [fullImageLoaded, setFullImageLoaded] = useState(false)

    // Animated values
    const thumbnailOpacity = useSharedValue(0)
    const fullImageOpacity = useSharedValue(0)
    const progressValue = useSharedValue(0)
    const scaleValue = useSharedValue(0.95)

    // Update progress animation
    progressValue.value = withTiming(progress, { duration: 300 })

    // Animated styles
    const thumbnailStyle = useAnimatedStyle(() => ({
      opacity: thumbnailOpacity.value,
    }))

    const fullImageStyle = useAnimatedStyle(() => ({
      opacity: fullImageOpacity.value,
      transform: [{ scale: scaleValue.value }],
    }))

    const progressStyle = useAnimatedStyle(() => ({
      width: `${interpolate(progressValue.value, [0, 1], [0, 100])}%`,
    }))

    const skeletonStyle = useAnimatedStyle(() => ({
      opacity: interpolate(progressValue.value, [0, 0.1, 1], [1, 1, 0]),
    }))

    // Handle thumbnail load
    const handleThumbnailLoad = useCallback(() => {
      setThumbnailLoaded(true)
      thumbnailOpacity.value = withTiming(1, { duration: 300 })
    }, [thumbnailOpacity])

    // Handle full image load
    const handleFullImageLoad = useCallback(() => {
      setFullImageLoaded(true)
      fullImageOpacity.value = withTiming(1, { duration: 500 })
      scaleValue.value = withSpring(1, { damping: 15, stiffness: 150 })

      // Fade out thumbnail after full image loads
      if (thumbnailLoaded) {
        thumbnailOpacity.value = withTiming(0, { duration: 300 })
      }

      if (onLoad) {
        runOnJS(onLoad)()
      }
    }, [fullImageOpacity, scaleValue, thumbnailOpacity, thumbnailLoaded, onLoad])

    // Handle errors
    const handleError = useCallback(
      (imageError: any) => {
        console.error("Image load error:", imageError)
        if (onError) {
          runOnJS(onError)(error || "Failed to load image")
        }
      },
      [error, onError],
    )

    return (
      <View style={[styles.container, { width: size.width, height: size.height }, style]}>
        {/* Skeleton Loader */}
        <Animated.View style={[styles.skeleton, skeletonStyle]}>
          <BlurView intensity={10} style={styles.skeletonBlur}>
            <LinearGradient
              colors={[colors.primaryLight, colors.primary, colors.primaryLight]}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 0 }}
              style={styles.skeletonGradient}
            >
              <View style={styles.skeletonContent}>
                <ActivityIndicator size="large" color={colors.white} />
              </View>
            </LinearGradient>
          </BlurView>
        </Animated.View>

        {/* Progress Bar */}
        {isLoading && progress > 0 && progress < 1 && (
          <View style={styles.progressContainer}>
            <View style={styles.progressTrack}>
              <Animated.View style={[styles.progressBar, progressStyle]} />
            </View>
          </View>
        )}

        {/* Thumbnail Image */}
        {thumbnail && (
          <Animated.View style={[styles.imageContainer, thumbnailStyle]}>
            <FastImage
              source={{ uri: thumbnail, priority: FastImage.priority.high }}
              style={styles.image}
              resizeMode={FastImage.resizeMode.cover}
              onLoad={handleThumbnailLoad}
              onError={handleError}
            />
          </Animated.View>
        )}

        {/* Full Resolution Image */}
        {fullImage && (
          <Animated.View style={[styles.imageContainer, fullImageStyle]}>
            <FastImage
              source={{
                uri: fullImage,
                priority: priority === "high" ? FastImage.priority.high : FastImage.priority.normal,
              }}
              style={styles.image}
              resizeMode={FastImage.resizeMode.cover}
              onLoad={handleFullImageLoad}
              onError={handleError}
            />
          </Animated.View>
        )}

        {/* Error State */}
        {error && !thumbnail && !fullImage && (
          <View style={styles.errorContainer}>
            <LinearGradient colors={[colors.error, colors.errorDark]} style={styles.errorGradient}>
              <View style={styles.errorContent}>
                <ActivityIndicator size="small" color={colors.white} />
              </View>
            </LinearGradient>
          </View>
        )}
      </View>
    )
  },
)

const styles = StyleSheet.create({
  container: {
    position: "relative",
    borderRadius: 16,
    overflow: "hidden",
    backgroundColor: colors.lightGray,
  },
  skeleton: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: 1,
  },
  skeletonBlur: {
    flex: 1,
  },
  skeletonGradient: {
    flex: 1,
  },
  skeletonContent: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },
  progressContainer: {
    position: "absolute",
    bottom: 0,
    left: 0,
    right: 0,
    zIndex: 2,
    paddingHorizontal: spacing.sm,
    paddingBottom: spacing.sm,
  },
  progressTrack: {
    height: 3,
    backgroundColor: "rgba(255, 255, 255, 0.3)",
    borderRadius: 2,
    overflow: "hidden",
  },
  progressBar: {
    height: "100%",
    backgroundColor: colors.primary,
    borderRadius: 2,
  },
  imageContainer: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  image: {
    width: "100%",
    height: "100%",
  },
  errorContainer: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: 3,
  },
  errorGradient: {
    flex: 1,
  },
  errorContent: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },
})

export default OptimizedAvatarImage
