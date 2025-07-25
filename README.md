# 📱 Time Capsule Camera

**Capture memories with friends and unlock them together in the future!**

A beautiful iOS app built with SwiftUI and Firebase that lets you and your friends create collaborative video time capsules. Add videos together, watch the countdown, and experience your shared memories when the capsule automatically unseals.

## ✨ Features

### 🎥 Core Functionality
- **Collaborative Video Collection**: Friends can add videos to shared capsules
- **Automatic Unsealing**: Capsules unseal automatically at scheduled times
- **Beautiful Countdown**: Visual countdown timer with progress indicators
- **Seamless Playback**: Professional video player with contributor information
- **Real-time Updates**: See when friends add new videos instantly

### 👥 Social Features
- **Group Management**: Invite friends via email to join capsules
- **Member Avatars**: See who's in your capsule at a glance
- **Multi-Capsule Support**: Create different capsules for different friend groups
- **Live Statistics**: Track total capsules, active, and unsealed counts

### 🎨 Beautiful Design
- **Modern UI**: Gradient backgrounds and smooth animations
- **Professional Video Player**: Full-screen playback with overlay information
- **Intuitive Navigation**: Easy-to-use interface for all age groups
- **Visual Feedback**: Progress indicators and status badges throughout

### 🔧 Technical Excellence
- **Firebase Backend**: Secure cloud storage and real-time database
- **Automatic Sync**: Changes sync across all devices instantly
- **Error Handling**: Graceful error handling with helpful messages
- **Performance Optimized**: Efficient video streaming and caching

## 🚀 Quick Start

### Prerequisites
- **iOS 16.0+**
- **Xcode 14+**
- **Active Firebase Project**

### Setup Instructions

#### 1. Clone Repository
```bash
git clone https://github.com/mkyoung23/TCC.git
cd TCC
```

#### 2. Firebase Configuration
The app includes a pre-configured Firebase project, but you can set up your own:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing
3. Add an iOS app with bundle ID: `com.mycompany.lifelapse`
4. Download `GoogleService-Info.plist`
5. Replace the existing file in the project

#### 3. Enable Firebase Services
In your Firebase project console:
- **Authentication**: Enable Email/Password provider
- **Firestore Database**: Create in production mode
- **Storage**: Enable for video file uploads

#### 4. Build and Run
1. Open `TimeCapsuleCamera.xcodeproj` in Xcode
2. Select your development team
3. Build and run on simulator or device

## 📖 How to Use

### For Individual Users

#### Getting Started
1. **Download and install** the app
2. **Create account** with email and password
3. **Choose a display name** for your profile

#### Creating Your First Capsule
1. **Tap the "+" button** on the main screen
2. **Enter capsule name** (e.g., "Summer Vacation 2024")
3. **Set unseal date** when you want memories revealed
4. **Tap "Create"** to make your capsule

### For Groups

#### Forming a Group
1. **One person creates** the capsule
2. **Invite friends** using their email addresses
3. **Friends will see** the capsule in their app
4. **Everyone can add videos** while sealed

#### Adding Memories
1. **Open any sealed capsule**
2. **Tap "Add Video Clip"**
3. **Select video** from camera roll or record new
4. **Wait for upload** completion
5. **Video is added** to shared collection

#### Experiencing Unsealed Capsules
1. **Capsules automatically unseal** at scheduled time
2. **Status changes** from "SEALED" to "UNSEALED"
3. **Tap unsealed capsule** to watch videos
4. **Navigate through clips** with playback controls
5. **See contributor info** on each video

## 🧪 Testing with Friends

### Quick Test Setup (5 minutes)
1. **Each friend creates** an account
2. **One person creates** a test capsule
3. **Set unseal time** to 2-3 minutes from now
4. **Invite all friends** via email
5. **Everyone adds** a short video
6. **Wait for automatic unsealing**
7. **Experience the playback** together

### Real-World Usage
- **Plan ahead**: Create capsules for future events
- **Set meaningful dates**: Graduations, birthdays, reunions
- **Different groups**: Work friends, family, college buddies
- **Various occasions**: Vacations, parties, milestones

For detailed testing instructions, see [TESTING_GUIDE.md](TESTING_GUIDE.md)

## 🏗️ Architecture

### Frontend (iOS/SwiftUI)
- **TimeCapsuleCameraApp.swift**: App entry point and navigation
- **Views/**: SwiftUI views for all screens
- **ViewModels/**: Business logic and state management
- **Models/**: Data models for Capsule and Clip

### Backend (Firebase)
- **Authentication**: User accounts and security
- **Firestore**: Real-time database for capsules and metadata
- **Storage**: Video file hosting and streaming
- **Automatic Functions**: Capsule unsealing logic

### Key Components
```
TimeCapsuleCamera/
├── Models/
│   ├── Capsule.swift          # Capsule data model
│   └── Clip.swift             # Video clip model
├── Services/
│   ├── FirebaseManager.swift  # Firebase integration
│   └── CapsuleManager.swift   # Business logic
├── ViewModels/
│   └── AuthViewModel.swift    # Authentication state
├── Views/
│   ├── AuthenticationView.swift    # Login/signup
│   ├── CapsuleListView.swift       # Main capsule list
│   ├── CapsuleDetailView.swift     # Capsule viewer
│   ├── NewCapsuleView.swift        # Capsule creation
│   ├── InviteMembersView.swift     # Friend invitations
│   ├── CountdownView.swift         # Countdown timer
│   └── VideoPicker.swift           # Video selection
└── TimeCapsuleCameraApp.swift      # App entry point
```

## 🔒 Privacy & Security

- **Firebase Authentication**: Secure user accounts
- **Private Capsules**: Only invited members can access
- **Encrypted Storage**: Videos stored securely in Firebase
- **Email Verification**: Members must have registered accounts
- **No Public Discovery**: Capsules are private by design

## 🤝 Contributing

This is a personal project, but feedback and suggestions are welcome!

### Reporting Issues
- Open an issue on GitHub
- Include device info and steps to reproduce
- Screenshots or videos helpful for UI issues

### Suggesting Features
- Check existing issues first
- Describe your use case
- Explain how it would improve the experience

## 📄 License

This project is for educational and personal use. See repository license for details.

## 🙏 Acknowledgments

- **Firebase**: Backend infrastructure and real-time capabilities
- **SwiftUI**: Modern iOS UI framework
- **AVFoundation**: Video playback and processing
- **Community**: iOS development community for inspiration

## 📞 Support

For technical issues or questions:
- **GitHub Issues**: Bug reports and feature requests
- **Documentation**: Check TESTING_GUIDE.md for common solutions
- **Firebase**: Official Firebase documentation for backend issues

---

**Made with ❤️ for capturing and sharing life's special moments**

*Time Capsule Camera - Where memories wait for their perfect moment* ✨ 
