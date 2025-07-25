# Time Capsule Camera - Deployment Guide

## Overview
This guide covers how to deploy the Time Capsule Camera app to iOS devices for testing and App Store distribution.

## Prerequisites

### 1. Apple Developer Account
- Sign up for an Apple Developer Program account at [developer.apple.com](https://developer.apple.com)
- Cost: $99/year for individual developers

### 2. Xcode
- Install Xcode from the Mac App Store
- Minimum version: Xcode 15.0 or later

### 3. Firebase Setup
- The app already includes Firebase configuration
- Project ID: `lifelapse-27e17`
- Services enabled: Authentication, Firestore, Storage

## Build Configuration

### 1. Update Bundle Identifier
In Xcode project settings, update the bundle identifier to be unique:
- Current: `com.mycompany.lifelapse`
- Recommended: `com.yourname.timecapsulecamera`

### 2. Code Signing
1. Open TimeCapsuleCamera.xcodeproj in Xcode
2. Select the project in navigator
3. Under "Signing & Capabilities":
   - Select your team (Apple Developer Account)
   - Choose "Automatically manage signing"
   - Verify bundle identifier is unique

### 3. Device Testing
To test on physical devices:
1. Connect iPhone/iPad via USB
2. Select device in Xcode
3. Build and run (⌘+R)
4. Trust the developer certificate on device (Settings > General > VPN & Device Management)

### 4. TestFlight Distribution
For beta testing with friends:
1. Archive the app (Product > Archive)
2. Upload to App Store Connect
3. Create TestFlight beta
4. Invite testers via email

### 5. App Store Release
For public release:
1. Create app listing in App Store Connect
2. Upload screenshots and metadata
3. Submit for review
4. App Review takes 1-7 days

## Required Assets

### App Icon
- Create app icons for all required sizes (20x20 to 1024x1024)
- Place in Assets.xcassets/AppIcon.appiconset/
- Use a design tool like Sketch, Figma, or online icon generators

### Screenshots
Required for App Store:
- iPhone screenshots (various sizes)
- iPad screenshots (if supporting iPad)
- Take screenshots of key app features

## Configuration Files

### Info.plist
Already configured with:
- Privacy usage descriptions
- Supported interface orientations
- Launch screen configuration

### GoogleService-Info.plist
- Current file is configured for Firebase project
- Keep this file secure and don't commit to public repos

## Build Settings

### Deployment Target
- Current: iOS 16.0+
- Can be lowered to iOS 15.0 for wider compatibility

### Architectures
- arm64 (required for App Store)
- x86_64 (for simulator testing)

## Testing Checklist

Before releasing:
- [ ] Test user registration and login
- [ ] Test capsule creation
- [ ] Test video upload
- [ ] Test video playback when unsealed
- [ ] Test invite functionality
- [ ] Test on multiple device sizes
- [ ] Test offline behavior
- [ ] Test with poor network conditions

## Troubleshooting

### Common Issues

1. **Build Failures**
   - Verify Firebase dependencies are properly linked
   - Check code signing configuration
   - Clean build folder (Product > Clean Build Folder)

2. **Firebase Connection Issues**
   - Verify GoogleService-Info.plist is included in bundle
   - Check Firebase project configuration
   - Ensure app bundle ID matches Firebase configuration

3. **Permission Denials**
   - Verify usage descriptions in Info.plist
   - Test permission flows on device
   - Check camera/microphone access

## Distribution Options

### 1. TestFlight (Recommended for testing)
- Up to 10,000 beta testers
- 90-day testing period
- No App Store review required for internal testing

### 2. Ad Hoc Distribution
- Up to 100 devices per year
- Requires device UUIDs
- Good for small team testing

### 3. App Store
- Public distribution
- Requires App Store review
- Worldwide availability

## Post-Launch

### Analytics and Monitoring
Consider adding:
- Firebase Analytics (already partially configured)
- Crash reporting (Firebase Crashlytics)
- Performance monitoring

### Updates
- Use semantic versioning (1.0.0, 1.0.1, 1.1.0, etc.)
- Test updates thoroughly before release
- Communicate changes to users

## Support

For technical issues:
- Check Firebase documentation
- Review Apple Developer documentation
- Test on multiple devices and iOS versions