"use client"

import { useRef, useEffect, useState } from "react"
import { X } from "lucide-react"
import { Button } from "@/components/ui/button"

interface MetaPersonAvatarProps {
  onAvatarCreated: (url: string) => void
  onClose: () => void
}

export default function MetaPersonAvatar({ onAvatarCreated, onClose }: MetaPersonAvatarProps) {
  const webviewRef = useRef<HTMLIFrameElement>(null)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      if (event.origin !== "https://mobile.metaperson.avatarsdk.com") return

      if (event.data?.source === "metaperson_creator") {
        const { eventName, url } = event.data

        if (eventName === "mobile_loaded") {
          setIsLoading(false)
          // Send authentication
          const authMessage = {
            eventName: "authenticate",
            clientId: "YOUR_CLIENT_ID", // Replace with your actual client ID
            clientSecret: "YOUR_CLIENT_SECRET", // Replace with your actual client secret
            exportTemplateCode: "",
          }

          webviewRef.current?.contentWindow?.postMessage(authMessage, "*")

          // Set export parameters
          const exportMessage = {
            eventName: "set_export_parameters",
            format: "glb",
            lod: 1,
            textureProfile: "2K.png",
          }

          webviewRef.current?.contentWindow?.postMessage(exportMessage, "*")
        }

        if (eventName === "model_exported" && url) {
          onAvatarCreated(url)
        }
      }
    }

    window.addEventListener("message", handleMessage)
    return () => window.removeEventListener("message", handleMessage)
  }, [onAvatarCreated])

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div className="bg-white rounded-2xl w-full max-w-md h-[600px] mx-4 overflow-hidden">
        {/* Header */}
        <div className="flex items-center justify-between p-4 border-b">
          <h2 className="text-xl font-bold text-amber-800">Create Your Avatar</h2>
          <Button variant="ghost" size="sm" onClick={onClose} className="text-gray-500 hover:text-gray-700">
            <X className="w-5 h-5" />
          </Button>
        </div>

        {/* Loading State */}
        {isLoading && (
          <div className="flex items-center justify-center h-full">
            <div className="text-center">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-amber-600 mx-auto mb-4"></div>
              <p className="text-gray-600">Loading MetaPerson Creator...</p>
            </div>
          </div>
        )}

        {/* MetaPerson WebView */}
        <iframe
          ref={webviewRef}
          src="https://mobile.metaperson.avatarsdk.com/"
          className={`w-full h-full border-0 ${isLoading ? "hidden" : ""}`}
          allow="camera; microphone; autoplay; encrypted-media; fullscreen"
          title="MetaPerson Creator"
        />

        {/* Instructions */}
        <div className="p-4 bg-amber-50 border-t">
          <p className="text-sm text-amber-800 text-center">
            Take a selfie or choose from templates to create your personalized avatar
          </p>
        </div>
      </div>
    </div>
  )
}
