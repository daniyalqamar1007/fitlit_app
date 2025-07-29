import AsyncStorage from "@react-native-async-storage/async-storage"
import * as FileSystem from "expo-file-system"
import { Image } from "react-native"

export interface CacheConfig {
  maxCacheSize: number // in MB
  maxCacheAge: number // in milliseconds
  compressionQuality: number // 0-1
  thumbnailSize: { width: number; height: number }
  preloadCount: number // number of avatars to preload
}

export interface CachedAvatar {
  id: string
  originalUrl: string
  localPath: string
  thumbnailPath: string
  fileSize: number
  cachedAt: number
  lastAccessed: number
  metadata: {
    width: number
    height: number
    format: string
    compressed: boolean
  }
}

class AvatarCacheService {
  private static instance: AvatarCacheService
  private cacheDir: string
  private thumbnailDir: string
  private config: CacheConfig
  private memoryCache: Map<string, string> = new Map()
  private downloadQueue: Map<string, Promise<CachedAvatar>> = new Map()
  private preloadQueue: Set<string> = new Set()

  private constructor() {
    this.cacheDir = `${FileSystem.cacheDirectory}avatars/`
    this.thumbnailDir = `${FileSystem.cacheDirectory}thumbnails/`
    this.config = {
      maxCacheSize: 100, // 100MB
      maxCacheAge: 7 * 24 * 60 * 60 * 1000, // 7 days
      compressionQuality: 0.8,
      thumbnailSize: { width: 200, height: 300 },
      preloadCount: 5,
    }
    this.initializeCacheDirectories()
  }

  static getInstance(): AvatarCacheService {
    if (!AvatarCacheService.instance) {
      AvatarCacheService.instance = new AvatarCacheService()
    }
    return AvatarCacheService.instance
  }

  private async initializeCacheDirectories(): Promise<void> {
    try {
      const cacheInfo = await FileSystem.getInfoAsync(this.cacheDir)
      if (!cacheInfo.exists) {
        await FileSystem.makeDirectoryAsync(this.cacheDir, { intermediates: true })
      }

      const thumbnailInfo = await FileSystem.getInfoAsync(this.thumbnailDir)
      if (!thumbnailInfo.exists) {
        await FileSystem.makeDirectoryAsync(this.thumbnailDir, { intermediates: true })
      }

      // Clean up old cache on startup
      this.cleanupExpiredCache()
    } catch (error) {
      console.error("Error initializing cache directories:", error)
    }
  }

  // Get cached avatar with progressive loading
  async getCachedAvatar(
    url: string,
    options: {
      priority?: "high" | "normal" | "low"
      progressive?: boolean
      preload?: boolean
    } = {},
  ): Promise<{
    thumbnail: string | null
    fullImage: string | null
    isLoading: boolean
    progress: number
  }> {
    const { priority = "normal", progressive = true, preload = false } = options
    const avatarId = this.generateCacheId(url)

    try {
      // Check memory cache first
      const memoryPath = this.memoryCache.get(avatarId)
      if (memoryPath) {
        const info = await FileSystem.getInfoAsync(memoryPath)
        if (info.exists) {
          await this.updateLastAccessed(avatarId)
          return {
            thumbnail: memoryPath,
            fullImage: memoryPath,
            isLoading: false,
            progress: 1,
          }
        }
      }

      // Check if already cached
      const cached = await this.getCachedAvatarInfo(avatarId)
      if (cached && !this.isCacheExpired(cached)) {
        // Update last accessed
        await this.updateLastAccessed(avatarId)
        this.memoryCache.set(avatarId, cached.localPath)

        return {
          thumbnail: cached.thumbnailPath,
          fullImage: cached.localPath,
          isLoading: false,
          progress: 1,
        }
      }

      // Check if download is in progress
      const existingDownload = this.downloadQueue.get(avatarId)
      if (existingDownload) {
        const result = await existingDownload
        return {
          thumbnail: result.thumbnailPath,
          fullImage: result.localPath,
          isLoading: false,
          progress: 1,
        }
      }

      // Start download with progressive loading
      const downloadPromise = this.downloadAndCacheAvatar(url, { priority, progressive })
      this.downloadQueue.set(avatarId, downloadPromise)

      if (preload) {
        // For preload, don't wait for completion
        return {
          thumbnail: null,
          fullImage: null,
          isLoading: true,
          progress: 0,
        }
      }

      const result = await downloadPromise
      this.downloadQueue.delete(avatarId)

      return {
        thumbnail: result.thumbnailPath,
        fullImage: result.localPath,
        isLoading: false,
        progress: 1,
      }
    } catch (error) {
      console.error("Error getting cached avatar:", error)
      this.downloadQueue.delete(avatarId)
      return {
        thumbnail: null,
        fullImage: null,
        isLoading: false,
        progress: 0,
      }
    }
  }

  // Download and cache avatar with optimization
  private async downloadAndCacheAvatar(
    url: string,
    options: { priority: string; progressive: boolean },
  ): Promise<CachedAvatar> {
    const avatarId = this.generateCacheId(url)
    const localPath = `${this.cacheDir}${avatarId}.jpg`
    const thumbnailPath = `${this.thumbnailDir}${avatarId}_thumb.jpg`

    try {
      // Download with progress tracking
      const downloadResult = await FileSystem.downloadAsync(url, localPath, {
        sessionType: FileSystem.FileSystemSessionType.BACKGROUND,
      })

      if (downloadResult.status !== 200) {
        throw new Error(`Download failed with status: ${downloadResult.status}`)
      }

      // Get image dimensions
      const dimensions = await this.getImageDimensions(localPath)

      // Generate optimized thumbnail
      await this.generateThumbnail(localPath, thumbnailPath)

      // Get file size
      const fileInfo = await FileSystem.getInfoAsync(localPath)
      const fileSize = fileInfo.size || 0

      // Create cache entry
      const cachedAvatar: CachedAvatar = {
        id: avatarId,
        originalUrl: url,
        localPath,
        thumbnailPath,
        fileSize,
        cachedAt: Date.now(),
        lastAccessed: Date.now(),
        metadata: {
          width: dimensions.width,
          height: dimensions.height,
          format: "jpg",
          compressed: true,
        },
      }

      // Save cache info
      await this.saveCacheInfo(cachedAvatar)

      // Add to memory cache
      this.memoryCache.set(avatarId, localPath)

      // Check cache size and cleanup if needed
      this.checkCacheSizeAndCleanup()

      return cachedAvatar
    } catch (error) {
      // Cleanup failed downloads
      await this.cleanupFailedDownload(localPath, thumbnailPath)
      throw error
    }
  }

  // Generate optimized thumbnail
  private async generateThumbnail(sourcePath: string, thumbnailPath: string): Promise<void> {
    try {
      // For now, we'll copy the original as thumbnail
      // In a real implementation, you'd use image processing library
      await FileSystem.copyAsync({
        from: sourcePath,
        to: thumbnailPath,
      })
    } catch (error) {
      console.error("Error generating thumbnail:", error)
    }
  }

  // Get image dimensions
  private async getImageDimensions(imagePath: string): Promise<{ width: number; height: number }> {
    return new Promise((resolve) => {
      Image.getSize(
        imagePath,
        (width, height) => resolve({ width, height }),
        () => resolve({ width: 0, height: 0 }),
      )
    })
  }

  // Preload avatars in background
  async preloadAvatars(urls: string[]): Promise<void> {
    const preloadPromises = urls.slice(0, this.config.preloadCount).map(async (url) => {
      const avatarId = this.generateCacheId(url)

      // Skip if already preloading or cached
      if (this.preloadQueue.has(avatarId) || this.memoryCache.has(avatarId)) {
        return
      }

      this.preloadQueue.add(avatarId)

      try {
        await this.getCachedAvatar(url, { priority: "low", preload: true })
      } catch (error) {
        console.error("Error preloading avatar:", error)
      } finally {
        this.preloadQueue.delete(avatarId)
      }
    })

    await Promise.allSettled(preloadPromises)
  }

  // Cache management
  private async getCachedAvatarInfo(avatarId: string): Promise<CachedAvatar | null> {
    try {
      const cacheInfoJson = await AsyncStorage.getItem(`cache_${avatarId}`)
      return cacheInfoJson ? JSON.parse(cacheInfoJson) : null
    } catch (error) {
      return null
    }
  }

  private async saveCacheInfo(cachedAvatar: CachedAvatar): Promise<void> {
    try {
      await AsyncStorage.setItem(`cache_${cachedAvatar.id}`, JSON.stringify(cachedAvatar))
    } catch (error) {
      console.error("Error saving cache info:", error)
    }
  }

  private async updateLastAccessed(avatarId: string): Promise<void> {
    try {
      const cached = await this.getCachedAvatarInfo(avatarId)
      if (cached) {
        cached.lastAccessed = Date.now()
        await this.saveCacheInfo(cached)
      }
    } catch (error) {
      console.error("Error updating last accessed:", error)
    }
  }

  private isCacheExpired(cached: CachedAvatar): boolean {
    return Date.now() - cached.cachedAt > this.config.maxCacheAge
  }

  // Cache cleanup
  private async cleanupExpiredCache(): Promise<void> {
    try {
      const keys = await AsyncStorage.getAllKeys()
      const cacheKeys = keys.filter((key) => key.startsWith("cache_"))

      for (const key of cacheKeys) {
        const cacheInfoJson = await AsyncStorage.getItem(key)
        if (cacheInfoJson) {
          const cached: CachedAvatar = JSON.parse(cacheInfoJson)
          if (this.isCacheExpired(cached)) {
            await this.removeCachedAvatar(cached.id)
          }
        }
      }
    } catch (error) {
      console.error("Error cleaning up expired cache:", error)
    }
  }

  private async checkCacheSizeAndCleanup(): Promise<void> {
    try {
      const cacheSize = await this.getCacheSize()
      const maxSizeBytes = this.config.maxCacheSize * 1024 * 1024

      if (cacheSize > maxSizeBytes) {
        await this.cleanupLeastRecentlyUsed()
      }
    } catch (error) {
      console.error("Error checking cache size:", error)
    }
  }

  private async getCacheSize(): Promise<number> {
    try {
      const keys = await AsyncStorage.getAllKeys()
      const cacheKeys = keys.filter((key) => key.startsWith("cache_"))
      let totalSize = 0

      for (const key of cacheKeys) {
        const cacheInfoJson = await AsyncStorage.getItem(key)
        if (cacheInfoJson) {
          const cached: CachedAvatar = JSON.parse(cacheInfoJson)
          totalSize += cached.fileSize
        }
      }

      return totalSize
    } catch (error) {
      console.error("Error getting cache size:", error)
      return 0
    }
  }

  private async cleanupLeastRecentlyUsed(): Promise<void> {
    try {
      const keys = await AsyncStorage.getAllKeys()
      const cacheKeys = keys.filter((key) => key.startsWith("cache_"))
      const cachedItems: CachedAvatar[] = []

      for (const key of cacheKeys) {
        const cacheInfoJson = await AsyncStorage.getItem(key)
        if (cacheInfoJson) {
          cachedItems.push(JSON.parse(cacheInfoJson))
        }
      }

      // Sort by last accessed (oldest first)
      cachedItems.sort((a, b) => a.lastAccessed - b.lastAccessed)

      // Remove oldest 25% of items
      const itemsToRemove = Math.ceil(cachedItems.length * 0.25)
      for (let i = 0; i < itemsToRemove; i++) {
        await this.removeCachedAvatar(cachedItems[i].id)
      }
    } catch (error) {
      console.error("Error cleaning up LRU cache:", error)
    }
  }

  private async removeCachedAvatar(avatarId: string): Promise<void> {
    try {
      const cached = await this.getCachedAvatarInfo(avatarId)
      if (cached) {
        // Remove files
        await FileSystem.deleteAsync(cached.localPath, { idempotent: true })
        await FileSystem.deleteAsync(cached.thumbnailPath, { idempotent: true })

        // Remove from AsyncStorage
        await AsyncStorage.removeItem(`cache_${avatarId}`)

        // Remove from memory cache
        this.memoryCache.delete(avatarId)
      }
    } catch (error) {
      console.error("Error removing cached avatar:", error)
    }
  }

  private async cleanupFailedDownload(localPath: string, thumbnailPath: string): Promise<void> {
    try {
      await FileSystem.deleteAsync(localPath, { idempotent: true })
      await FileSystem.deleteAsync(thumbnailPath, { idempotent: true })
    } catch (error) {
      console.error("Error cleaning up failed download:", error)
    }
  }

  // Utility methods
  private generateCacheId(url: string): string {
    // Simple hash function for URL
    let hash = 0
    for (let i = 0; i < url.length; i++) {
      const char = url.charCodeAt(i)
      hash = (hash << 5) - hash + char
      hash = hash & hash // Convert to 32-bit integer
    }
    return Math.abs(hash).toString(36)
  }

  // Public API methods
  async clearCache(): Promise<void> {
    try {
      await FileSystem.deleteAsync(this.cacheDir, { idempotent: true })
      await FileSystem.deleteAsync(this.thumbnailDir, { idempotent: true })
      await this.initializeCacheDirectories()

      // Clear AsyncStorage cache info
      const keys = await AsyncStorage.getAllKeys()
      const cacheKeys = keys.filter((key) => key.startsWith("cache_"))
      await AsyncStorage.multiRemove(cacheKeys)

      // Clear memory cache
      this.memoryCache.clear()
    } catch (error) {
      console.error("Error clearing cache:", error)
    }
  }

  async getCacheStats(): Promise<{
    totalSize: number
    itemCount: number
    oldestItem: number
    newestItem: number
  }> {
    try {
      const keys = await AsyncStorage.getAllKeys()
      const cacheKeys = keys.filter((key) => key.startsWith("cache_"))
      let totalSize = 0
      let oldestItem = Date.now()
      let newestItem = 0

      for (const key of cacheKeys) {
        const cacheInfoJson = await AsyncStorage.getItem(key)
        if (cacheInfoJson) {
          const cached: CachedAvatar = JSON.parse(cacheInfoJson)
          totalSize += cached.fileSize
          oldestItem = Math.min(oldestItem, cached.cachedAt)
          newestItem = Math.max(newestItem, cached.cachedAt)
        }
      }

      return {
        totalSize,
        itemCount: cacheKeys.length,
        oldestItem,
        newestItem,
      }
    } catch (error) {
      console.error("Error getting cache stats:", error)
      return { totalSize: 0, itemCount: 0, oldestItem: 0, newestItem: 0 }
    }
  }
}

export default AvatarCacheService
