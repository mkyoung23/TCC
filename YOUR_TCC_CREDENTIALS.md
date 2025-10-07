# 🔐 YOUR TIME CAPSULE CAMERA - MASTER CREDENTIALS & SETUP

**SAVE THIS FILE - Everything you need in one place**

---

## ✅ YOUR APPLE DEVELOPER CREDENTIALS

### App Store Connect API Key
- **File**: `C:\Users\mkyou\OneDrive\Documents\AuthKey_68T7Y68ZWL.p8`
- **Key ID**: `68T7Y68ZWL`
- **Issuer ID**: `f94e54a5-8ebc-49c0-b581-1099125c304f`
- **Status**: ✅ Already uploaded to CodeMagic

### Apple Developer Info
- **Team ID**: `6XNH7D52V6`
- **Bundle ID**: `com.mkyoung.timecapsulecamera`
- **App Store App ID**: `6753696297`
- **App Name**: Time Capsule Camera (TCC)
- **SKU**: `timecapsulecamera001`

### Distribution Files (Downloaded)
- **Certificate**: `C:\Users\mkyou\OneDrive\Documents\_timecapsulecamera_dist_cert.p12`
- **Provisioning Profile**: `C:\Users\mkyou\OneDrive\Documents\TimeCapsuleCamera_Dist_Profile (6).mobileprovision`

---

## ✅ CODEMAGIC SETUP

### Account
- **URL**: https://codemagic.io/
- **Connected Repo**: `mkyoung23/TCC`
- **Workflow Name**: `ios-tcc`

### Environment Variables (Already Set)
```
IOS_EXPORT_METHOD = app-store
IOS_BUNDLE_ID = com.mkyoung.timecapsulecamera
APPSTORECONNECT_ISSUER_ID = f94e54a5-8ebc-49c0-b581-1099125c304f
APPSTORECONNECT_KEY_ID = 68T7Y68ZWL
APPSTORECONNECT_PRIVATE_KEY = ••••••••
```

### Build Configuration
- **Project**: `time_capsule_camera/TimeCapsuleCamera.xcodeproj`
- **Scheme**: `TimeCapsuleCamera`
- **Build Time**: ~15-20 minutes
- **Email Notifications**: mkyoung23@gmail.com

---

## ✅ APP STORE CONNECT

### App Info
- **URL**: https://appstoreconnect.apple.com/
- **App**: Time Capsule Camera (TCC)
- **Bundle ID**: com.mkyoung.timecapsulecamera
- **Category**: Photo & Video
- **Age Rating**: 4+
- **Status**: Ready for builds

### TestFlight Setup Needed
- **Beta Group Name**: Beta Testers
- **Add yourself first**: [your email]
- **Then add friends**: [friend emails]

---

## ✅ GITHUB REPOSITORY

- **Repo**: https://github.com/mkyoung23/TCC
- **Main Branch**: `main`
- **Config File**: `codemagic.yaml` (already correct)
- **Status**: Connected to CodeMagic ✅

---

## 🚀 YOUR SITUATION

### What You Have
- ✅ Windows computer (MSI) - **CAN'T run Xcode**
- ✅ All credentials downloaded and configured
- ✅ CodeMagic connected to GitHub
- ✅ App created in App Store Connect
- ✅ codemagic.yaml configured correctly

### What This Means
- ❌ Can't test locally with Xcode (no Mac)
- ✅ MUST use CodeMagic to build
- ✅ TestFlight is your ONLY way to test on phone
- ✅ You'll test via TestFlight like your friends will

### The Process
1. Add yourself as TestFlight tester (FIRST!)
2. Trigger CodeMagic build
3. Wait 20-30 minutes
4. You get TestFlight email
5. Download TestFlight app on your iPhone
6. Install Time Capsule Camera
7. **TEST IT YOURSELF FIRST**
8. If it's good, add friends to TestFlight
9. They get invites and test with you

---

## 🎯 YOUR GOALS

1. ✅ Get the app working perfectly
2. ✅ Test it yourself first
3. ✅ Make sure it looks great
4. ✅ Then share with friends easily
5. ✅ Test together and have fun

---

## 📱 APP FEATURES (What You Built)

Your Time Capsule Camera includes:

- ✅ **Time-locked capsules** - Videos unlock on future dates
- ✅ **Collaborative** - Friends can add videos to same capsule
- ✅ **Chronological playback** - Videos play in order recorded
- ✅ **Firebase backend** - Secure cloud storage
- ✅ **Beautiful UI** - Modern SwiftUI interface
- ✅ **Push notifications** - When capsules unseal
- ✅ **Sharing & invites** - Easy friend invitations
- ✅ **Offline support** - Works without internet, syncs later

---

## 🔄 HOW TO BUILD & TEST

### Step 1: Add Yourself to TestFlight
1. Go to: https://appstoreconnect.apple.com/
2. My Apps → Time Capsule Camera (TCC)
3. TestFlight tab → Internal Testing
4. Create group: "Beta Testers"
5. Add your email ONLY (test yourself first!)

### Step 2: Start Build
1. Go to: https://codemagic.io/apps
2. Click TCC app
3. Start new build → ios-tcc → main
4. Wait 15-20 minutes

### Step 3: Test It Yourself
1. Check email for TestFlight invite
2. Download TestFlight app from App Store
3. Open invite email, click link
4. Install Time Capsule Camera
5. **Test everything:**
   - Create account
   - Make a capsule
   - Record/upload video
   - Check UI and features
   - Make sure it's perfect

### Step 4: Invite Friends (After YOU Approve It)
1. Back to App Store Connect → TestFlight
2. Add friend emails to "Beta Testers" group
3. They get invites automatically
4. Test together!

---

## 🆘 TROUBLESHOOTING

### Build Fails
- Check CodeMagic logs for error
- Most common: Code signing issues
- Solution: Environment variables auto-handle this

### TestFlight Email Doesn't Arrive
- Check spam folder
- Can take up to 10 minutes
- Apple ID must match the email you added

### App Crashes on Launch
- Check Firebase configuration
- Verify GoogleService-Info.plist is included
- Check build logs for errors

### Can't Install from TestFlight
- Make sure iOS 16+ on your iPhone
- TestFlight app must be installed first
- Invitation must be accepted

---

## 📞 IMPORTANT LINKS

- **App Store Connect**: https://appstoreconnect.apple.com/
- **CodeMagic**: https://codemagic.io/apps
- **GitHub Repo**: https://github.com/mkyoung23/TCC
- **Apple Developer**: https://developer.apple.com/account/
- **TestFlight Help**: https://developer.apple.com/testflight/

---

## 💾 BACKUP YOUR CREDENTIALS

**Keep these files safe:**
- `AuthKey_68T7Y68ZWL.p8` - Your API key (can't download again!)
- `_timecapsulecamera_dist_cert.p12` - Distribution certificate
- `TimeCapsuleCamera_Dist_Profile (6).mobileprovision` - Provisioning profile
- This file (`YOUR_TCC_CREDENTIALS.md`) - Master reference

---

## ✅ CURRENT STATUS

- [x] Credentials downloaded and saved
- [x] CodeMagic configured with environment variables
- [x] GitHub repo connected to CodeMagic
- [x] App created in App Store Connect
- [x] codemagic.yaml file correct and pushed
- [ ] Add yourself to TestFlight
- [ ] Trigger first build
- [ ] Test app yourself
- [ ] Add friends as testers
- [ ] Test together and enjoy!

---

**🎯 YOU'RE ALMOST THERE! Just need to add yourself to TestFlight and start the build!**
