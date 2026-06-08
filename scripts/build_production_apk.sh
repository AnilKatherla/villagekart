#!/bin/bash

# Exit on any error
set -e

echo "🚀 Starting Production APK Build (customer flavor)..."

# 1. Clean the project
echo "🧹 Cleaning project..."
flutter clean

# 2. Get dependencies
echo "📦 Fetching dependencies..."
flutter pub get

# 3. Build the APK
echo "🏗️ Building APK..."
flutter build apk --flavor customer --dart-define=ENV_FILE=config/prod.env --release



echo "✅ Build Complete!"
echo "📍 Output: build/app/outputs/flutter-apk/app-customer-release.apk"
