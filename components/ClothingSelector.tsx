"use client"
import { Card } from "@/components/ui/card"

interface ClothingSelectorProps {
  selectedCategory: "shirts" | "pants"
  onCategoryChange: (category: "shirts" | "pants") => void
  onItemSelect: (item: any, category: "shirts" | "pants") => void
  currentOutfit: {
    shirt: any
    pants: any
  }
}

const clothingItems = {
  shirts: [
    { id: 1, name: "Orange Hoodie", image: "/placeholder.svg?height=80&width=80", color: "orange" },
    { id: 2, name: "Pink Shirt", image: "/placeholder.svg?height=80&width=80", color: "pink" },
    { id: 3, name: "Black Jacket", image: "/placeholder.svg?height=80&width=80", color: "black" },
    { id: 4, name: "Gray T-Shirt", image: "/placeholder.svg?height=80&width=80", color: "gray" },
  ],
  pants: [
    { id: 5, name: "Blue Jeans", image: "/placeholder.svg?height=80&width=80", color: "blue" },
    { id: 6, name: "Dark Pants", image: "/placeholder.svg?height=80&width=80", color: "dark" },
    { id: 7, name: "Black Jeans", image: "/placeholder.svg?height=80&width=80", color: "black" },
    { id: 8, name: "Red Pants", image: "/placeholder.svg?height=80&width=80", color: "red" },
  ],
}

export default function ClothingSelector({
  selectedCategory,
  onCategoryChange,
  onItemSelect,
  currentOutfit,
}: ClothingSelectorProps) {
  return (
    <div className="p-6">
      {/* Category Headers */}
      <div className="flex justify-between mb-6">
        <div className="text-center">
          <button
            onClick={() => onCategoryChange("shirts")}
            className={`text-lg font-semibold ${selectedCategory === "shirts" ? "text-amber-800" : "text-gray-500"}`}
          >
            Shirts
          </button>
          <div
            className={`h-1 w-16 mx-auto mt-2 rounded ${
              selectedCategory === "shirts" ? "bg-amber-600" : "bg-transparent"
            }`}
          />
        </div>
        <div className="text-center">
          <button
            onClick={() => onCategoryChange("pants")}
            className={`text-lg font-semibold ${selectedCategory === "pants" ? "text-amber-800" : "text-gray-500"}`}
          >
            Pants
          </button>
          <div
            className={`h-1 w-16 mx-auto mt-2 rounded ${
              selectedCategory === "pants" ? "bg-amber-600" : "bg-transparent"
            }`}
          />
        </div>
      </div>

      {/* Clothing Grid */}
      <div className="grid grid-cols-2 gap-4">
        {clothingItems[selectedCategory].map((item) => (
          <Card
            key={item.id}
            className={`cursor-pointer transition-all hover:shadow-lg ${
              currentOutfit[selectedCategory === "shirts" ? "shirt" : "pants"]?.id === item.id
                ? "ring-2 ring-amber-500"
                : ""
            }`}
            onClick={() => onItemSelect(item, selectedCategory)}
          >
            <div className="p-4 text-center">
              <img
                src={item.image || "/placeholder.svg"}
                alt={item.name}
                className="w-16 h-16 mx-auto mb-2 object-cover rounded-lg"
              />
              <p className="text-sm font-medium text-gray-700">{item.name}</p>
            </div>
          </Card>
        ))}
      </div>
    </div>
  )
}
