#!/bin/bash

# Mali Mobile Build Script
echo "📱 Building Mali Mobile Apps 💅✨"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build Android APK
echo "🤖 Building Android APK..."
flutter build apk --release

# Build iOS (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Building iOS app..."
    flutter build ios --release --no-codesign
    echo "✅ iOS build complete (unsigned)"
else
    echo "⚠️  iOS build skipped (requires macOS)"
fi

echo "✅ Mobile builds complete! 💅✨"
echo "📱 Android APK: build/app/outputs/flutter-apk/app-release.apk"
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 iOS app: build/ios/iphoneos/Runner.app"
fi 