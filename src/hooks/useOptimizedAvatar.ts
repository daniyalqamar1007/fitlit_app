"use client"

import { useState, useEffect, useCallback, useRef } from "react"
import AvatarCacheService from "../services/AvatarCacheService"

interface UseOptimizedAvatarOptions {
  priority?: "high" | "normal" | "low"
  progressive?: boolean
  preload?: boolean
  fallbackUrl?: string
}

interface OptimizedAvatarState {
  thumbnail: string | null
  fullImage: string | null
  isLoading: boolean
  progress: number
  error: string | null
  retry: () => void
}

export const useOptimizedAvatar = (
  url: string | null,
  options: UseOptimizedAvatarOptions = {},
): OptimizedAvatarState => {
  const [state, setState] = useState<OptimizedAvatarState>({
    thumbnail: null,
    fullImage: null,
    isLoading: false,
    progress: 0,
    error: null,
    retry: () => {},
  })

  const cacheService = useRef(AvatarCacheService.getInstance())
  const abortController = useRef<AbortController | null>(null)
  const retryCount = useRef(0)
  const maxRetries = 3

  const loadAvatar = useCallback(async () => {
    if (!url) {
      setState((prev) => ({
        ...prev,
        thumbnail: null,
        fullImage: null,
        isLoading: false,
        progress: 0,
        error: null,
      }))
      return
    }

    // Cancel previous request
    if (abortController.current) {
      abortController.current.abort()
    }
    abortController.current = new AbortController()

    setState((prev) => ({
      ...prev,
      isLoading: true,
      error: null,
      progress: 0,
    }))

    try {
      const result = await cacheService.current.getCachedAvatar(url, {
        priority: options.priority || "normal",
        progressive: options.progressive !== false,
        preload: options.preload || false,
      })

      // Check if request was aborted
      if (abortController.current?.signal.aborted) {
        return
      }

      setState((prev) => ({
        ...prev,
        thumbnail: result.thumbnail,
        fullImage: result.fullImage,
        isLoading: result.isLoading,
        progress: result.progress,
        error: null,
      }))

      retryCount.current = 0
    } catch (error) {
      // Check if request was aborted
      if (abortController.current?.signal.aborted) {
        return
      }

      console.error("Error loading optimized avatar:", error)

      setState((prev) => ({
        ...prev,
        thumbnail: options.fallbackUrl || null,
        fullImage: options.fallbackUrl || null,
        isLoading: false,
        progress: 0,
        error: error instanceof Error ? error.message : "Failed to load avatar",
      }))
    }
  }, [url, options.priority, options.progressive, options.preload, options.fallbackUrl])

  const retry = useCallback(() => {
    if (retryCount.current < maxRetries) {
      retryCount.current++
      loadAvatar()
    }
  }, [loadAvatar])

  useEffect(() => {
    loadAvatar()

    return () => {
      if (abortController.current) {
        abortController.current.abort()
      }
    }
  }, [loadAvatar])

  return {
    ...state,
    retry,
  }
}

// Hook for preloading multiple avatars
export const useAvatarPreloader = () => {
  const cacheService = useRef(AvatarCacheService.getInstance())
  const [isPreloading, setIsPreloading] = useState(false)

  const preloadAvatars = useCallback(async (urls: string[]) => {
    if (urls.length === 0) return

    setIsPreloading(true)
    try {
      await cacheService.current.preloadAvatars(urls)
    } catch (error) {
      console.error("Error preloading avatars:", error)
    } finally {
      setIsPreloading(false)
    }
  }, [])

  return {
    preloadAvatars,
    isPreloading,
  }
}

// Hook for cache management
export const useCacheManager = () => {
  const cacheService = useRef(AvatarCacheService.getInstance())
  const [cacheStats, setCacheStats] = useState({
    totalSize: 0,
    itemCount: 0,
    oldestItem: 0,
    newestItem: 0,
  })

  const refreshStats = useCallback(async () => {
    try {
      const stats = await cacheService.current.getCacheStats()
      setCacheStats(stats)
    } catch (error) {
      console.error("Error refreshing cache stats:", error)
    }
  }, [])

  const clearCache = useCallback(async () => {
    try {
      await cacheService.current.clearCache()
      await refreshStats()
    } catch (error) {
      console.error("Error clearing cache:", error)
    }
  }, [refreshStats])

  useEffect(() => {
    refreshStats()
  }, [refreshStats])

  return {
    cacheStats,
    refreshStats,
    clearCache,
  }
}
