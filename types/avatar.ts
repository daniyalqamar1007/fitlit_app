export interface AvatarConfig {
  id: string
  url: string
  format: "glb" | "fbx" | "gltf"
  lod: number
  textureProfile: string
  createdAt: Date
}

export interface OutfitItem {
  id: number
  name: string
  image: string
  color: string
  category: "shirts" | "pants" | "accessories"
  brand?: string
  price?: number
}

export interface UserOutfit {
  id: string
  userId: string
  avatar: AvatarConfig
  items: OutfitItem[]
  name: string
  createdAt: Date
  likes: number
  isPublic: boolean
}

export interface SocialPost {
  id: string
  userId: string
  username: string
  userAvatar: string
  outfit: UserOutfit
  caption: string
  likes: number
  comments: number
  shares: number
  createdAt: Date
}
