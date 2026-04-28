#!/bin/bash
# DailyExpenseAIPro Setup Script
# Run this on MacinCloud to generate and configure the Xcode project

set -e

echo "🚀 Setting up DailyExpenseAIPro..."

# Check if xcodegen is installed
if ! command -v xcodegen &> /dev/null; then
    echo "⚠️ xcodegen not found. Installing..."
    brew install xcodegen
fi

# Generate Xcode project
echo "📦 Generating Xcode project with xcodegen..."
xcodegen

# Create Configs directory
mkdir -p Configs

# Create Debug.xcconfig
cat > Configs/Debug.xcconfig << 'DEBUG_EOF'
#include "Pods/Target Support Files/Pods-DailyExpenseAIPro/Pods-DailyExpenseAIPro.debug.xcconfig"
SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG
DEBUG_EOF

# Create Release.xcconfig
cat > Configs/Release.xcconfig << 'RELEASE_EOF'
#include "Pods/Target Support Files/Pods-DailyExpenseAIPro/Pods-DailyExpenseAIPro.release.xcconfig"
SWIFT_OPTIMIZATION_LEVEL = "-Owholemodule"
RELEASE_EOF

# Install CocoaPods dependencies (if needed)
if [ -f "Podfile" ]; then
    echo "📦 Installing CocoaPods dependencies..."
    pod install
fi

# Set team in project
echo "🔧 Configuring development team..."
/usr/libexec/PlistBuddy -c "Set :objects:$(grep -A1 'DEVELOPMENT_TEAM' DailyExpenseAIPro.xcodeproj/project.pbxproj | tail -1 | cut -d' ' -f1 | tr -d ';'):value 9L6N2ZF26B" DailyExpenseAIPro.xcodeproj/project.pbxproj 2>/dev/null || true

# Open project
echo "✅ Setup complete!"
echo "Opening DailyExpenseAIPro.xcodeproj..."
open DailyExpenseAIPro.xcodeproj

echo ""
echo "📝 Next steps:"
echo "   1. Build the project (Cmd+B)"
echo "   2. Run on simulator (Cmd+R)"
echo "   3. Configure signing in Xcode"
echo "   4. Add app icons in Assets.xcassets"
echo "   5. Test on device"
