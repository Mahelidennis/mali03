#!/bin/bash

# Mali Web Deployment Script (GitHub Pages)
echo "🚀 Deploying Mali to GitHub Pages 💅✨"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build for web
echo "🌐 Building for web..."
flutter build web --release

# Commit and push to GitHub (this triggers GitHub Pages deployment)
echo "📤 Pushing to GitHub..."
git add .
git commit -m "Update Mali web build 💅✨"
git push

echo "✅ Deployment complete! Mali is now live! 💅✨"
echo "🌐 Web version: https://mahelidennis.github.io/mali03/"
echo "📱 Mobile builds will be available in GitHub Actions" 