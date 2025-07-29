"use client"

import { useState } from "react"
import { Search, Sun } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Card } from "@/components/ui/card"
import MetaPersonAvatar from "@/components/MetaPersonAvatar"
import ClothingSelector from "@/components/ClothingSelector"
import SocialPanel from "@/components/SocialPanel"

export default function FitLitApp() {
  const [selectedCategory, setSelectedCategory] = useState<"shirts" | "pants">("shirts")
  const [avatarUrl, setAvatarUrl] = useState<string | null>(null)
  const [showAvatarCreator, setShowAvatarCreator] = useState(false)
  const [currentOutfit, setCurrentOutfit] = useState({
    shirt: null,
    pants: null,
  })

  const handleAvatarCreated = (url: string) => {
    setAvatarUrl(url)
    setShowAvatarCreator(false)
  }

  const handleClothingSelect = (item: any, category: "shirts" | "pants") => {
    setCurrentOutfit((prev) => ({
      ...prev,
      [category]: item,
    }))
  }

  const handleSaveOutfit = () => {
    // Save current outfit configuration
    console.log("Saving outfit:", currentOutfit)
    // You can implement save functionality here
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-orange-50 to-amber-50">
      <div className="container mx-auto px-4 py-6 max-w-md">
        {/* Header */}
        <header className="flex items-center justify-between mb-6">
          <div className="flex items-center space-x-3">
            <Search className="w-5 h-5 text-gray-600" />
            <Input placeholder="Search" className="border-none bg-white/80 backdrop-blur-sm" />
          </div>
          <h1 className="text-2xl font-bold text-amber-800">FITLIT</h1>
          <Button
            onClick={handleSaveOutfit}
            className="bg-amber-600 hover:bg-amber-700 text-white px-4 py-2 rounded-lg"
          >
            Save Outfit
          </Button>
        </header>

        {/* Date and Weather */}
        <div className="flex items-center justify-between mb-6">
          <div className="text-center">
            <div className="bg-amber-600 text-white px-4 py-2 rounded-lg">
              <div className="text-2xl font-bold">11</div>
              <div className="text-sm">July</div>
            </div>
            <div className="text-sm text-gray-600 mt-1">Sunday</div>
          </div>
          <div className="text-center">
            <div className="bg-yellow-200 p-3 rounded-lg">
              <Sun className="w-6 h-6 text-yellow-600 mx-auto" />
              <div className="text-lg font-semibold">93°F</div>
            </div>
            <div className="text-sm text-gray-600 mt-1">Dallas Tx</div>
          </div>
        </div>

        {/* Main Content */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Avatar Section */}
          <div className="lg:col-span-2">
            <Card className="bg-white/90 backdrop-blur-sm border-0 shadow-lg rounded-2xl overflow-hidden">
              <div className="relative">
                {/* Avatar Display */}
                <div className="flex justify-center py-8 bg-gradient-to-b from-orange-100 to-white">
                  {showAvatarCreator ? (
                    <MetaPersonAvatar
                      onAvatarCreated={handleAvatarCreated}
                      onClose={() => setShowAvatarCreator(false)}
                    />
                  ) : (
                    <div className="relative">
                      {avatarUrl ? (
                        <img
                          src={avatarUrl || "/placeholder.svg"}
                          alt="Your Avatar"
                          className="w-64 h-80 object-contain"
                        />
                      ) : (
                        <div className="w-64 h-80 bg-gradient-to-b from-orange-200 to-amber-200 rounded-2xl flex items-center justify-center">
                          <Button
                            onClick={() => setShowAvatarCreator(true)}
                            className="bg-amber-600 hover:bg-amber-700 text-white px-6 py-3 rounded-lg"
                          >
                            Create Avatar
                          </Button>
                        </div>
                      )}
                      {avatarUrl && (
                        <Button
                          onClick={() => setShowAvatarCreator(true)}
                          className="absolute bottom-4 right-4 bg-amber-600 hover:bg-amber-700 text-white px-4 py-2 rounded-lg text-sm"
                        >
                          Edit Avatar
                        </Button>
                      )}
                    </div>
                  )}
                </div>

                {/* Clothing Selection */}
                {!showAvatarCreator && (
                  <ClothingSelector
                    selectedCategory={selectedCategory}
                    onCategoryChange={setSelectedCategory}
                    onItemSelect={handleClothingSelect}
                    currentOutfit={currentOutfit}
                  />
                )}
              </div>
            </Card>
          </div>

          {/* Social Panel */}
          <div className="lg:col-span-1">
            <SocialPanel />
          </div>
        </div>
      </div>
    </div>
  )
}
