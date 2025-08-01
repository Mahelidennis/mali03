#!/bin/bash

# Mali Deployment Script
echo "🚀 Deploying Mali - Your Financial Big Sister 💅✨"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Run tests
echo "🧪 Running tests..."
flutter test

# Build for web
echo "🌐 Building for web..."
flutter build web --release

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "⚠️  Firebase CLI not found. Installing..."
    npm install -g firebase-tools
fi

# Deploy to Firebase
echo "🔥 Deploying to Firebase..."
firebase deploy --only hosting

echo "✅ Deployment complete! Mali is now live! 💅✨"
echo "🌐 Web version: https://mali-financial-assistant.web.app" 