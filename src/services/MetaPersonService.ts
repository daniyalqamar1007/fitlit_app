import AsyncStorage from "@react-native-async-storage/async-storage"
import { MetaPersonConfig } from "../config/metaperson"

export interface AvatarData {
  id: string
  url: string
  format: string
  createdAt: string
  thumbnailUrl?: string
  metadata?: {
    lod: number
    textureProfile: string
    fileSize?: number
  }
}

class MetaPersonService {
  private static instance: MetaPersonService
  private avatars: AvatarData[] = []

  static getInstance(): MetaPersonService {
    if (!MetaPersonService.instance) {
      MetaPersonService.instance = new MetaPersonService()
    }
    return MetaPersonService.instance
  }

  // Save avatar data - matches Android AsyncStorage pattern
  async saveAvatar(url: string): Promise<AvatarData> {
    const avatarData: AvatarData = {
      id: this.generateAvatarId(),
      url,
      format: MetaPersonConfig.EXPORT_FORMAT,
      createdAt: new Date().toISOString(),
      metadata: {
        lod: MetaPersonConfig.EXPORT_LOD,
        textureProfile: MetaPersonConfig.EXPORT_TEXTURE_PROFILE,
      },
    }

    try {
      // Save to AsyncStorage
      await AsyncStorage.setItem("currentAvatar", JSON.stringify(avatarData))

      // Add to avatars list
      this.avatars.unshift(avatarData)
      await this.saveAvatarsList()

      console.log("Avatar saved successfully:", avatarData.id)
      return avatarData
    } catch (error) {
      console.error("Error saving avatar:", error)
      throw new Error("Failed to save avatar")
    }
  }

  // Get current avatar
  async getCurrentAvatar(): Promise<AvatarData | null> {
    try {
      const avatarJson = await AsyncStorage.getItem("currentAvatar")
      return avatarJson ? JSON.parse(avatarJson) : null
    } catch (error) {
      console.error("Error getting current avatar:", error)
      return null
    }
  }

  // Get all avatars
  async getAllAvatars(): Promise<AvatarData[]> {
    try {
      const avatarsJson = await AsyncStorage.getItem("avatarsList")
      this.avatars = avatarsJson ? JSON.parse(avatarsJson) : []
      return this.avatars
    } catch (error) {
      console.error("Error getting avatars list:", error)
      return []
    }
  }

  // Delete avatar
  async deleteAvatar(avatarId: string): Promise<boolean> {
    try {
      this.avatars = this.avatars.filter((avatar) => avatar.id !== avatarId)
      await this.saveAvatarsList()

      // If deleted avatar was current, clear current
      const current = await this.getCurrentAvatar()
      if (current?.id === avatarId) {
        await AsyncStorage.removeItem("currentAvatar")
      }

      return true
    } catch (error) {
      console.error("Error deleting avatar:", error)
      return false
    }
  }

  // Clear all avatars
  async clearAllAvatars(): Promise<void> {
    try {
      await AsyncStorage.removeItem("currentAvatar")
      await AsyncStorage.removeItem("avatarsList")
      this.avatars = []
    } catch (error) {
      console.error("Error clearing avatars:", error)
      throw new Error("Failed to clear avatars")
    }
  }

  // Private methods
  private async saveAvatarsList(): Promise<void> {
    await AsyncStorage.setItem("avatarsList", JSON.stringify(this.avatars))
  }

  private generateAvatarId(): string {
    return `avatar_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
  }

  // Validate avatar URL
  isValidAvatarUrl(url: string): boolean {
    try {
      const urlObj = new URL(url)
      return urlObj.protocol === "https:" && url.includes("avatarsdk")
    } catch {
      return false
    }
  }

  // Get avatar file size (if available)
  async getAvatarFileSize(url: string): Promise<number | null> {
    try {
      const response = await fetch(url, { method: "HEAD" })
      const contentLength = response.headers.get("content-length")
      return contentLength ? Number.parseInt(contentLength, 10) : null
    } catch (error) {
      console.error("Error getting avatar file size:", error)
      return null
    }
  }
}

export default MetaPersonService
