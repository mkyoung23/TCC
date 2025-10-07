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

### 4. TestFlight Distribution *(recommended for sharing with friends fast)*
For beta testing with friends (no UDIDs needed and no manual installs), follow the [Quick Device Preview & TestFlight Checklist](TESTFLIGHT_QUICKSTART.md) or the steps below:
1. In App Store Connect, create an **App Store Connect API key** (Users and Access → Keys) with the *App Manager* role and download the `AuthKey_<KEY_ID>.p8` file.
2. Add the following to your Codemagic `ios_signing` environment group (or configure them locally if you upload from Xcode). Use `python scripts/encode_base64.py AuthKey_<KEY_ID>.p8 --env-var APP_STORE_CONNECT_API_KEY_BASE64` if you are not on macOS.
   - `APP_STORE_CONNECT_KEY_ID`
   - `APP_STORE_CONNECT_ISSUER_ID`
   - `APP_STORE_CONNECT_API_KEY_BASE64` (base64-encoded contents of the `.p8` file)
3. Export the build with the `app-store` method. In Codemagic, set `IOS_EXPORT_METHOD=app-store`; in Xcode, choose **Any iOS Device (arm64)** and archive.
4. Let Codemagic’s **Upload to TestFlight (optional)** step push the `.ipa`, or from Xcode’s Organizer click **Distribute App → App Store Connect → Upload** and supply the API key when prompted.
5. In App Store Connect → **TestFlight**, add internal testers (immediate access) or external testers (requires a quick beta app review) and send them email invites. Testers install the TestFlight app and accept the invite—no device registration required.

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
- Requires device UDIDs to be embedded in the provisioning profile
- Good for small team testing when you control all devices
- Follow the [iOS Ad-hoc Distribution Checklist](IOS_ADHOC_CHECKLIST.md) to register new devices, refresh the provisioning profile, and update Codemagic secrets before kicking off a build.

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