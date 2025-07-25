# Vintage Capsule - Mobile Distribution Guide

## Overview
This guide explains how to build and distribute the Vintage Capsule iOS app for testing with friends and eventual App Store release.

## Prerequisites
- Xcode 15.0 or later
- iOS 16.0+ deployment target
- Apple Developer Account
- Firebase project with proper configuration

## Build Configuration

### 1. Bundle Identifier
Update the bundle identifier in your Xcode project:
- Recommended format: `com.yourname.vintage-capsule`
- Must be unique and match your Apple Developer Account

### 2. App Display Name
The app will appear as "Vintage Capsule" on the home screen (configured in Info.plist)

### 3. Version Information
- Version: 1.0
- Build: 1
- Update these for each release

## Firebase Setup

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create new project named "Vintage Capsule"
3. Enable iOS app with your bundle identifier

### 2. Download Configuration
1. Download `GoogleService-Info.plist` from Firebase
2. Replace the template file in the project
3. Ensure it's added to the Xcode target

### 3. Enable Services
Enable these Firebase services:
- **Authentication**: Email/Password provider
- **Firestore Database**: Production mode
- **Storage**: For video uploads

## App Store Connect Setup

### 1. Create App Record
1. Login to [App Store Connect](https://appstoreconnect.apple.com/)
2. Create new app with bundle identifier
3. Fill in app information:
   - Name: "Vintage Capsule"
   - Subtitle: "Home Video Camera"
   - Category: Photo & Video
   - Keywords: vintage, camera, memories, time capsule, video

### 2. App Description
```
Vintage Capsule transforms your iPhone into a nostalgic home video camera, bringing the magic of vintage filmmaking to modern memory-making.

✨ FEATURES
• Create time-locked memory capsules
• Record videos with authentic vintage effects
• Invite friends and family to contribute
• Automatic unsealing on your chosen date
• Film strip borders and classic viewfinder
• Share memories with your group

🎬 VINTAGE EXPERIENCE
Relive the golden age of home videos with:
• Retro camera interface with viewfinder overlay
• Classic film aesthetic and warm color tones
• Nostalgic UI reminiscent of old cameras
• Authentic recording experience

👥 SOCIAL MEMORIES
• Create group memory capsules
• Invite friends via email
• Everyone can add videos before sealing
• Watch together when the capsule opens

Perfect for birthdays, vacations, graduations, and any special moment you want to preserve with vintage charm.
```

### 3. Screenshots Required
You'll need screenshots for:
- iPhone 6.7" (iPhone 14 Pro Max)
- iPhone 6.5" (iPhone 14 Plus)
- iPhone 5.5" (iPhone 8 Plus)

## TestFlight Distribution

### 1. Archive Build
1. In Xcode: Product → Archive
2. Upload to App Store Connect
3. Wait for processing (10-15 minutes)

### 2. TestFlight Setup
1. Go to TestFlight tab in App Store Connect
2. Select your build
3. Add internal testers (up to 100)
4. External testing requires App Review

### 3. Invite Testers
Send TestFlight invitation links to friends:
- They'll need to install TestFlight app
- Provide feedback through TestFlight
- Test on various iPhone models

## Privacy and Permissions

### Required Permissions
The app requests:
- **Camera**: Record vintage videos
- **Microphone**: Audio for videos
- **Photo Library**: Select existing videos

### Privacy Policy
You'll need a privacy policy URL for App Store submission. Key points:
- Video content stored in Firebase
- User authentication via Firebase Auth
- No personal data sold to third parties
- Users control their own capsules and invitations

## Launch Checklist

### Before TestFlight
- [ ] Firebase configuration complete
- [ ] All vintage UI themes implemented
- [ ] Camera recording functionality tested
- [ ] Group invitation system working
- [ ] Countdown timers accurate
- [ ] Video upload/download tested
- [ ] App icons and launch screen added

### Before App Store
- [ ] TestFlight feedback incorporated
- [ ] Privacy policy URL ready
- [ ] App screenshots uploaded
- [ ] App description finalized
- [ ] Keywords and categories set
- [ ] Age rating completed
- [ ] Copyright information added

## Marketing Assets

### App Icon
- 1024x1024 pixels
- Vintage camera theme with warm colors
- No text or rounded corners (iOS adds automatically)

### App Store Screenshots
Create screenshots showing:
1. Authentication screen with vintage theme
2. Memory capsules list with film strip borders
3. Camera recording interface with viewfinder
4. Countdown timer for sealed capsule
5. Group invitation screen

## Support and Updates

### User Support
- Create support email: support@yourapp.com
- FAQ section on website
- TestFlight feedback monitoring

### Future Updates
Plan for version 1.1 features:
- Additional vintage filters
- Export to Camera Roll
- Push notifications for unsealing
- Video editing features
- Social sharing improvements

## Troubleshooting

### Common Issues
1. **Build Errors**: Check Firebase SDK installation
2. **Camera Not Working**: Verify permissions in Info.plist
3. **Upload Failures**: Check Firebase Storage rules
4. **Authentication Issues**: Verify Firebase Auth setup

### Testing Scenarios
- Multiple users in same capsule
- Capsule unsealing at exact time
- Video upload with poor network
- App backgrounding during recording
- Different iPhone screen sizes

## Contact
For development questions or support, contact the development team.

Built with ❤️ for preserving memories in vintage style.