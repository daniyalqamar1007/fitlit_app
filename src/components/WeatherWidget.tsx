import { memo } from "react"
import { View, Text, StyleSheet } from "react-native"
import Icon from "react-native-vector-icons/Feather"
import { colors, spacing, typography } from "../theme"

const WeatherWidget = memo(() => {
  return (
    <View style={styles.container}>
      {/* Date Widget */}
      <View style={styles.dateContainer}>
        <View style={styles.dateBox}>
          <Text style={styles.dateNumber}>11</Text>
          <Text style={styles.dateMonth}>July</Text>
        </View>
        <Text style={styles.dayText}>Sunday</Text>
      </View>

      {/* Weather Widget */}
      <View style={styles.weatherContainer}>
        <View style={styles.weatherBox}>
          <Icon name="sun" size={24} color={colors.warning} />
          <Text style={styles.temperature}>93°F</Text>
        </View>
        <Text style={styles.locationText}>Dallas Tx</Text>
      </View>
    </View>
  )
})

const styles = StyleSheet.create({
  container: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    paddingHorizontal: spacing.md,
    marginBottom: spacing.lg,
  },
  dateContainer: {
    alignItems: "center",
  },
  dateBox: {
    backgroundColor: colors.primary,
    borderRadius: 12,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.sm,
    alignItems: "center",
    minWidth: 60,
  },
  dateNumber: {
    fontSize: 24,
    fontWeight: "bold",
    color: colors.white,
  },
  dateMonth: {
    fontSize: 12,
    color: colors.white,
  },
  dayText: {
    fontSize: typography.caption.fontSize,
    color: colors.textSecondary,
    marginTop: spacing.xs,
  },
  weatherContainer: {
    alignItems: "center",
  },
  weatherBox: {
    backgroundColor: colors.warningLight,
    borderRadius: 12,
    padding: spacing.md,
    alignItems: "center",
    minWidth: 80,
  },
  temperature: {
    fontSize: typography.h3.fontSize,
    fontWeight: typography.h3.fontWeight as any,
    color: colors.textPrimary,
    marginTop: spacing.xs,
  },
  locationText: {
    fontSize: typography.caption.fontSize,
    color: colors.textSecondary,
    marginTop: spacing.xs,
  },
})

export default WeatherWidget
