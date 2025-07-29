#!/bin/bash

echo "🧹 Cleaning MetaPerson Android Project..."

# Make gradlew executable
chmod +x ./gradlew

# Clean project
echo "Cleaning project..."
./gradlew clean

# Clear build cache
echo "Clearing build cache..."
rm -rf .gradle/
rm -rf app/build/
rm -rf build/

# Rebuild project
echo "Rebuilding project..."
./gradlew assembleDebug --stacktrace

echo "✅ Clean build completed!"
