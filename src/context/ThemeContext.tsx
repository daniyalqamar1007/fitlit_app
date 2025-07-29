"use client"

import { createContext, useContext, type ReactNode } from "react"
import { colors, spacing, typography } from "../theme"

interface ThemeContextType {
  colors: typeof colors
  spacing: typeof spacing
  typography: typeof typography
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined)

export const useTheme = () => {
  const context = useContext(ThemeContext)
  if (!context) {
    throw new Error("useTheme must be used within a ThemeProvider")
  }
  return context
}

interface ThemeProviderProps {
  children: ReactNode
}

export const ThemeProvider = ({ children }: ThemeProviderProps) => {
  return <ThemeContext.Provider value={{ colors, spacing, typography }}>{children}</ThemeContext.Provider>
}
