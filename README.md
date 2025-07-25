# Time Capsule Camera

A home video camera app where you can be both the actor and the star. Create time capsules with friends and family, add videos throughout the day/week/month, and then watch them all together when the capsule unseals!

## ✨ Features

- **🔐 Time-locked Capsules**: Create capsules that automatically unseal at a future date
- **👥 Collaborative**: Invite friends and family to add videos to shared capsules
- **📱 Mobile-first**: Native iOS app built with SwiftUI
- **☁️ Cloud Storage**: Secure video storage with Firebase
- **🎬 Video Playback**: Seamless video queue playback with contributor information
- **⏰ Live Countdown**: Real-time countdown until capsule unsealing

## 🚀 Quick Start

### For Users
1. Download from TestFlight (link coming soon) or App Store
2. Create an account with email/password
3. Create your first time capsule
4. Invite friends and start adding videos!

### For Developers

#### Prerequisites
- macOS with Xcode 15.0+
- iOS 16.0+ device or simulator
- Apple Developer Account (for device testing)

#### Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/mkyoung23/TCC.git
   cd TCC/time_capsule_camera
   ```

2. Open in Xcode:
   ```bash
   open TimeCapsuleCamera.xcodeproj
   ```

3. Configure Firebase:
   - The app includes a pre-configured Firebase project
   - For production, replace `GoogleService-Info.plist` with your own

4. Build and run:
   - Select your target device/simulator
   - Press ⌘+R to build and run

#### Project Structure
```
time_capsule_camera/
├── Models/              # Data models (Capsule, Clip)
├── Views/              # SwiftUI views
├── ViewModels/         # Observable objects for state management
├── Services/           # Firebase integration
├── Assets.xcassets/    # App icons and images
├── Info.plist         # App configuration
└── LaunchScreen.storyboard
```

## 📱 How It Works

1. **Create a Capsule**: Set a name and future unlock date
2. **Add Members**: Invite friends via email
3. **Record Memories**: Everyone can add videos anytime
4. **Wait for Magic**: Videos stay locked until the seal date
5. **Enjoy Together**: Watch all videos in sequence when unsealed

## 🛠 Technical Stack

- **Frontend**: SwiftUI (iOS 16+)
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Video**: AVKit for playback
- **Storage**: Firebase Cloud Storage
- **Real-time**: Firestore real-time listeners

## 🔧 Configuration

### Firebase Services Used
- **Authentication**: Email/password sign-in
- **Firestore**: Real-time database for capsule metadata
- **Storage**: Secure video file storage
- **Cloud Messaging**: Push notifications (optional)

### Privacy & Permissions
- Camera access for video recording
- Photo library access for video selection
- Microphone access for audio recording

## 📋 Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions including:
- TestFlight distribution
- App Store submission
- Code signing setup
- Required assets

## 🧪 Testing

Run unit tests:
```bash
swift test
```

Key test areas:
- Model initialization
- Data validation
- Firebase integration
- Video upload/download

## 🚀 Production Readiness

The app is ready for production deployment with:
- ✅ Error handling and user feedback
- ✅ Loading states and progress indicators
- ✅ Offline data persistence
- ✅ Automatic capsule unsealing
- ✅ Secure Firebase integration
- ✅ Privacy permission handling
- ✅ Launch screen and app icons
- ✅ Proper navigation and user flows

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is proprietary software. All rights reserved.

## 📞 Support

For issues or questions:
- Create an issue in this repository
- Check the [DEPLOYMENT.md](DEPLOYMENT.md) guide
- Review Firebase documentation for backend issues

---

**Ready to capture memories that matter? Download Time Capsule Camera and start creating digital time capsules with your loved ones! 📸⏰**
