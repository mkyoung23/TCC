#!/bin/bash
# iOS Build Script for Time Capsule Camera
# This builds the app without needing a pre-configured Xcode project

set -e

echo "🚀 Starting iOS build for Time Capsule Camera..."

# Clean previous builds
rm -rf build
mkdir -p build

# Create temporary project structure
echo "📁 Creating build structure..."
mkdir -p build/TCC
mkdir -p build/TCC/Sources
mkdir -p build/TCC/Resources

# Copy all Swift files to proper structure
echo "📝 Copying source files..."
cp TimeCapsuleCameraApp.swift build/TCC/Sources/
cp AppDelegate.swift build/TCC/Sources/
cp -r Models build/TCC/Sources/
cp -r Views build/TCC/Sources/
cp -r ViewModels build/TCC/Sources/
cp -r Services build/TCC/Sources/

# Copy resources
echo "🎨 Copying resources..."
cp -r Assets.xcassets build/TCC/Resources/
cp Info.plist build/TCC/
cp LaunchScreen.storyboard build/TCC/Resources/

# Create a simple xcconfig file
echo "⚙️ Creating build configuration..."
cat > build/TCC/Config.xcconfig << 'EOF'
PRODUCT_BUNDLE_IDENTIFIER = com.mkyoung.timecapsulecamera
DEVELOPMENT_TEAM = 6XNH7D52V6
PRODUCT_NAME = TimeCapsuleCamera
MARKETING_VERSION = 1.0
CURRENT_PROJECT_VERSION = 1
SWIFT_VERSION = 5.0
IPHONEOS_DEPLOYMENT_TARGET = 16.0
TARGETED_DEVICE_FAMILY = 1
CODE_SIGN_STYLE = Manual
EOF

# Create entitlements file
cat > build/TCC/TimeCapsuleCamera.entitlements << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>aps-environment</key>
    <string>production</string>
</dict>
</plist>
EOF

# Build the app using xcodebuild with direct compilation
echo "🔨 Building iOS app..."
cd build/TCC

# Create module map for Firebase
cat > module.modulemap << 'EOF'
module TimeCapsuleCamera {
    header "TimeCapsuleCamera-Bridging-Header.h"
    export *
}
EOF

# Create bridging header (even if empty)
touch TimeCapsuleCamera-Bridging-Header.h

# Compile Swift files into an iOS app
echo "📱 Compiling for iOS..."
xcrun -sdk iphoneos swiftc \
    -target arm64-apple-ios16.0 \
    -module-name TimeCapsuleCamera \
    -emit-executable \
    -o TimeCapsuleCamera \
    -parse-as-library \
    -Onone \
    Sources/TimeCapsuleCameraApp.swift \
    Sources/AppDelegate.swift \
    Sources/Models/*.swift \
    Sources/Views/*.swift \
    Sources/ViewModels/*.swift \
    Sources/Services/*.swift \
    -framework UIKit \
    -framework SwiftUI \
    -framework Foundation \
    -framework CoreGraphics

# Create app bundle structure
echo "📦 Creating app bundle..."
mkdir -p TimeCapsuleCamera.app
cp TimeCapsuleCamera TimeCapsuleCamera.app/
cp Info.plist TimeCapsuleCamera.app/
cp -r Resources/Assets.xcassets TimeCapsuleCamera.app/

# Sign the app (CodeMagic will handle this)
echo "✅ Build complete!"
echo "📍 App bundle created at: build/TCC/TimeCapsuleCamera.app"