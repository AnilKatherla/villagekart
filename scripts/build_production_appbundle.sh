#!/bin/bash

# Exit on any error
set -e

echo "🚀 Starting Production Build (customer flavor)..."

# # 1. Clean the project
# echo "🧹 Cleaning project..."
# flutter clean

# # 2. Get dependencies
# echo "📦 Fetching dependencies..."
# flutter pub get

# 3. Build the AppBundle
echo "🏗️ Building AppBundle..."
flutter build appbundle --flavor customer --dart-define=ENV_FILE=config/prod.env --release

echo "✅ Build Complete!"
echo "📍 Output: build/app/outputs/bundle/customerRelease/app-customer-release.aab"
