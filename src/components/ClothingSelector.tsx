"use client"

import { memo, useCallback } from "react"
import { View, Text, TouchableOpacity, StyleSheet, Dimensions } from "react-native"
import { FlatGrid } from "react-native-super-grid"
import FastImage from "react-native-fast-image"
import { BlurView } from "expo-blur"
import { colors, spacing, typography } from "../theme"
import { clothingItems } from "../data/clothingData"

const { width: SCREEN_WIDTH } = Dimensions.get("window")
const ITEM_SIZE = (SCREEN_WIDTH - spacing.md * 4) / 2

interface ClothingSelectorProps {
  selectedCategory: "shirts" | "pants"
  onCategoryChange: (category: "shirts" | "pants") => void
  onItemSelect: (item: any, category: "shirts" | "pants") => void
  currentOutfit: {
    shirt: any
    pants: any
  }
}

const ClothingSelector = memo(
  ({ selectedCategory, onCategoryChange, onItemSelect, currentOutfit }: ClothingSelectorProps) => {
    const renderClothingItem = useCallback(
      ({ item }: { item: any }) => {
        const isSelected = currentOutfit[selectedCategory === "shirts" ? "shirt" : "pants"]?.id === item.id

        return (
          <TouchableOpacity
            style={[styles.clothingItem, isSelected && styles.selectedItem]}
            onPress={() => onItemSelect(item, selectedCategory)}
            activeOpacity={0.8}
          >
            <BlurView intensity={10} style={styles.itemBlur}>
              <FastImage
                source={{ uri: item.image }}
                style={styles.itemImage}
                resizeMode={FastImage.resizeMode.cover}
              />
              <Text style={styles.itemName} numberOfLines={1}>
                {item.name}
              </Text>
            </BlurView>
          </TouchableOpacity>
        )
      },
      [selectedCategory, currentOutfit, onItemSelect],
    )

    return (
      <View style={styles.container}>
        {/* Category Headers */}
        <View style={styles.categoryHeader}>
          <TouchableOpacity
            style={styles.categoryButton}
            onPress={() => onCategoryChange("shirts")}
            activeOpacity={0.8}
          >
            <Text style={[styles.categoryText, selectedCategory === "shirts" && styles.activeCategoryText]}>
              Shirts
            </Text>
            {selectedCategory === "shirts" && <View style={styles.categoryIndicator} />}
          </TouchableOpacity>

          <TouchableOpacity style={styles.categoryButton} onPress={() => onCategoryChange("pants")} activeOpacity={0.8}>
            <Text style={[styles.categoryText, selectedCategory === "pants" && styles.activeCategoryText]}>Pants</Text>
            {selectedCategory === "pants" && <View style={styles.categoryIndicator} />}
          </TouchableOpacity>
        </View>

        {/* Clothing Grid */}
        <FlatGrid
          itemDimension={ITEM_SIZE}
          data={clothingItems[selectedCategory]}
          style={styles.grid}
          spacing={spacing.sm}
          renderItem={renderClothingItem}
          maxItemsPerRow={2}
          showsVerticalScrollIndicator={false}
        />
      </View>
    )
  },
)

const styles = StyleSheet.create({
  container: {
    paddingHorizontal: spacing.md,
  },
  categoryHeader: {
    flexDirection: "row",
    justifyContent: "space-around",
    marginBottom: spacing.lg,
  },
  categoryButton: {
    alignItems: "center",
    paddingVertical: spacing.sm,
  },
  categoryText: {
    fontSize: typography.h3.fontSize,
    fontWeight: typography.h3.fontWeight as any,
    color: colors.textSecondary,
  },
  activeCategoryText: {
    color: colors.primary,
  },
  categoryIndicator: {
    width: 40,
    height: 3,
    backgroundColor: colors.primary,
    borderRadius: 2,
    marginTop: spacing.xs,
  },
  grid: {
    flex: 1,
  },
  clothingItem: {
    borderRadius: 16,
    overflow: "hidden",
    elevation: 2,
    shadowColor: colors.shadow,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  selectedItem: {
    borderWidth: 2,
    borderColor: colors.primary,
  },
  itemBlur: {
    padding: spacing.md,
    alignItems: "center",
    backgroundColor: "rgba(255, 255, 255, 0.9)",
  },
  itemImage: {
    width: 60,
    height: 60,
    borderRadius: 12,
    marginBottom: spacing.sm,
  },
  itemName: {
    fontSize: typography.caption.fontSize,
    fontWeight: typography.caption.fontWeight as any,
    color: colors.textPrimary,
    textAlign: "center",
  },
})

export default ClothingSelector
