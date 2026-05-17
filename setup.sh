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

# Open project
echo "✅ Setup complete!"
echo "Opening DailyExpenseAIPro.xcodeproj..."
open DailyExpenseAIPro.xcodeproj

echo ""
echo "📝 Next steps:"
echo "   1. Build the project (Cmd+B)"
echo "   2. Run on simulator (Cmd+R)"
echo "   3. Configure signing in Xcode"
echo "   4. Test on device"