"use client"

import { createContext, useContext, useState, useEffect, type ReactNode } from "react"
import MetaPersonService, { type AvatarData } from "../services/MetaPersonService"
import { validateMetaPersonConfig } from "../config/metaperson"

interface AvatarContextType {
  // Current avatar
  avatarUrl: string | null
  currentAvatar: AvatarData | null
  setAvatarUrl: (url: string | null) => void

  // Avatar management
  avatars: AvatarData[]
  isLoading: boolean
  error: string | null

  // Actions
  saveAvatar: (url: string) => Promise<void>
  deleteAvatar: (avatarId: string) => Promise<void>
  refreshAvatars: () => Promise<void>
  clearError: () => void

  // MetaPerson integration status
  isMetaPersonConfigured: boolean
}

const AvatarContext = createContext<AvatarContextType | undefined>(undefined)

export const useAvatar = () => {
  const context = useContext(AvatarContext)
  if (!context) {
    throw new Error("useAvatar must be used within an AvatarProvider")
  }
  return context
}

interface AvatarProviderProps {
  children: ReactNode
}

export const AvatarProvider = ({ children }: AvatarProviderProps) => {
  const [avatarUrl, setAvatarUrlState] = useState<string | null>(null)
  const [currentAvatar, setCurrentAvatar] = useState<AvatarData | null>(null)
  const [avatars, setAvatars] = useState<AvatarData[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [isMetaPersonConfigured, setIsMetaPersonConfigured] = useState(false)

  const metaPersonService = MetaPersonService.getInstance()

  useEffect(() => {
    initializeAvatarContext()
  }, [])

  const initializeAvatarContext = async () => {
    try {
      setIsLoading(true)

      // Check MetaPerson configuration
      const isConfigured = validateMetaPersonConfig()
      setIsMetaPersonConfigured(isConfigured)

      if (!isConfigured) {
        setError("MetaPerson is not configured. Please check your credentials.")
        return
      }

      // Load current avatar
      const current = await metaPersonService.getCurrentAvatar()
      if (current) {
        setCurrentAvatar(current)
        setAvatarUrlState(current.url)
      }

      // Load all avatars
      const allAvatars = await metaPersonService.getAllAvatars()
      setAvatars(allAvatars)
    } catch (err) {
      console.error("Error initializing avatar context:", err)
      setError("Failed to load avatar data")
    } finally {
      setIsLoading(false)
    }
  }

  const setAvatarUrl = async (url: string | null) => {
    try {
      if (url) {
        // Validate URL
        if (!metaPersonService.isValidAvatarUrl(url)) {
          throw new Error("Invalid avatar URL")
        }

        // Save avatar
        const avatarData = await metaPersonService.saveAvatar(url)
        setCurrentAvatar(avatarData)
        setAvatarUrlState(url)

        // Refresh avatars list
        await refreshAvatars()
      } else {
        setCurrentAvatar(null)
        setAvatarUrlState(null)
      }
    } catch (err) {
      console.error("Error setting avatar URL:", err)
      setError("Failed to save avatar")
    }
  }

  const saveAvatar = async (url: string) => {
    try {
      setIsLoading(true)
      const avatarData = await metaPersonService.saveAvatar(url)
      setCurrentAvatar(avatarData)
      setAvatarUrlState(url)
      await refreshAvatars()
    } catch (err) {
      console.error("Error saving avatar:", err)
      setError("Failed to save avatar")
      throw err
    } finally {
      setIsLoading(false)
    }
  }

  const deleteAvatar = async (avatarId: string) => {
    try {
      setIsLoading(true)
      const success = await metaPersonService.deleteAvatar(avatarId)

      if (success) {
        // If deleted avatar was current, clear current
        if (currentAvatar?.id === avatarId) {
          setCurrentAvatar(null)
          setAvatarUrlState(null)
        }

        await refreshAvatars()
      } else {
        throw new Error("Failed to delete avatar")
      }
    } catch (err) {
      console.error("Error deleting avatar:", err)
      setError("Failed to delete avatar")
      throw err
    } finally {
      setIsLoading(false)
    }
  }

  const refreshAvatars = async () => {
    try {
      const allAvatars = await metaPersonService.getAllAvatars()
      setAvatars(allAvatars)
    } catch (err) {
      console.error("Error refreshing avatars:", err)
      setError("Failed to refresh avatars")
    }
  }

  const clearError = () => {
    setError(null)
  }

  return (
    <AvatarContext.Provider
      value={{
        avatarUrl,
        currentAvatar,
        setAvatarUrl,
        avatars,
        isLoading,
        error,
        saveAvatar,
        deleteAvatar,
        refreshAvatars,
        clearError,
        isMetaPersonConfigured,
      }}
    >
      {children}
    </AvatarContext.Provider>
  )
}
