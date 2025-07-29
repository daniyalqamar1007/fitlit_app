#!/bin/bash

echo "🔧 Fixing ADB Connection..."

# Kill ADB server
adb kill-server

# Start ADB server
adb start-server

# Wait a moment
sleep 2

# Check devices
echo "Connected devices:"
adb devices

# Try to uninstall old app
echo "Attempting to uninstall old app..."
adb uninstall com.avatarsdk.metaperson 2>/dev/null || echo "App not installed or already removed"

echo "✅ ADB setup completed!"
