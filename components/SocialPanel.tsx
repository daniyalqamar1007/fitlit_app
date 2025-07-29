"use client"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Heart, MessageCircle, Share } from "lucide-react"

export default function SocialPanel() {
  return (
    <Card className="bg-white/90 backdrop-blur-sm border-0 shadow-lg rounded-2xl overflow-hidden">
      <div className="p-6">
        {/* Social Media Page Header */}
        <div className="text-center mb-6">
          <h3 className="text-lg font-semibold text-amber-800 mb-2">Social Media Page</h3>
          <div className="w-16 h-16 bg-gradient-to-br from-amber-200 to-orange-200 rounded-full mx-auto mb-3 flex items-center justify-center">
            <img src="/placeholder.svg?height=60&width=60" alt="Johnny Cage" className="w-12 h-12 rounded-full" />
          </div>
          <h4 className="font-semibold text-gray-800">Johnny Cage</h4>
          <p className="text-sm text-gray-600">johnnycage@gmail.com</p>
        </div>

        {/* Current Outfit Display */}
        <div className="mb-6">
          <div className="bg-amber-50 rounded-lg p-4 text-center">
            <div className="text-sm text-amber-800 mb-2">Current Outfit</div>
            <div className="text-lg font-semibold text-amber-900">11 July</div>
          </div>
        </div>

        {/* Avatar Preview */}
        <div className="mb-6">
          <div className="bg-gradient-to-b from-orange-100 to-amber-100 rounded-lg p-4 text-center">
            <img
              src="/placeholder.svg?height=120&width=80"
              alt="Avatar Preview"
              className="w-20 h-30 mx-auto object-contain"
            />
          </div>
        </div>

        {/* Social Actions */}
        <div className="space-y-3">
          <Button className="w-full bg-red-500 hover:bg-red-600 text-white" size="sm">
            <Heart className="w-4 h-4 mr-2" />
            Like Outfit
          </Button>
          <Button className="w-full bg-blue-500 hover:bg-blue-600 text-white" size="sm">
            <MessageCircle className="w-4 h-4 mr-2" />
            Comment
          </Button>
          <Button className="w-full bg-green-500 hover:bg-green-600 text-white" size="sm">
            <Share className="w-4 h-4 mr-2" />
            Share
          </Button>
        </div>

        {/* Stats */}
        <div className="mt-6 pt-4 border-t border-gray-200">
          <div className="text-center text-sm text-gray-600">
            <p>x 100 views today</p>
          </div>
        </div>
      </div>
    </Card>
  )
}
