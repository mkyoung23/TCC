# 📱 Time Capsule Camera - Easy Installation Guide

## 🎯 Quick Start: Get the App on Your Phone in 5 Steps

### Step 1: Install Xcode (One-time setup)
1. **Download Xcode from Mac App Store** (free, ~15GB)
2. **Wait for installation** (~30-60 minutes depending on internet)
3. **Open Xcode** once to accept license agreements

### Step 2: Open the Project
1. **Navigate to** `/Users/mkyou/Desktop/TCC/time_capsule_camera/`
2. **Double-click** `TimeCapsuleCamera.xcodeproj`
3. **Wait for Xcode to load** the project (1-2 minutes first time)

### Step 3: Connect Your iPhone
1. **Connect your iPhone** to your Mac with USB cable
2. **Trust the computer** on iPhone when prompted
3. **In Xcode**, select your iPhone from the device dropdown (top left)

### Step 4: Set Up Your Apple ID (One-time)
1. In Xcode, go to **Preferences > Accounts**
2. **Click "+"** and sign in with your Apple ID
3. **Select the project** in left panel → **Signing & Capabilities**
4. **Choose your team** (your Apple ID)
5. **Change Bundle Identifier** to something unique like `com.yourname.timecapsule`

### Step 5: Build and Install
1. **Press ⌘+R** (or click the ▶️ play button)
2. **Wait 2-3 minutes** for the app to build and install
3. **Trust Developer** on iPhone: Settings → General → VPN & Device Management → Trust your certificate

**🎉 Done! The app is now on your phone!**

---

## 👥 Sharing with Friends: 3 Methods

### Method A: TestFlight (Recommended - Up to 10,000 friends!)

**What is TestFlight?**
- Apple's official beta testing platform
- Friends get the app through App Store
- Easy to update and manage
- No need for friends' devices or Apple IDs upfront

**Steps:**

1. **Archive the App**
   - In Xcode: Product → Archive
   - Wait 3-5 minutes for archive to complete
   - Click "Distribute App" → "App Store Connect"

2. **Upload to App Store Connect**
   - Create free Apple Developer account at [developer.apple.com](https://developer.apple.com) ($99/year for distribution)
   - Upload takes 10-15 minutes
   - App processes automatically

3. **Create TestFlight Beta**
   - Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
   - Click your app → TestFlight
   - Add build and enable testing

4. **Invite Friends**
   - Add testers by email
   - Friends get email with TestFlight link
   - They install TestFlight app, then your app

### Method B: Direct Device Installation (Up to 3 friends)

**Steps:**
1. **Get friends' device UUIDs**:
   - Friend connects iPhone to Mac
   - Opens System Information → USB → iPhone
   - Copies "Serial Number" (this is UUID)

2. **Add UUIDs to Xcode**:
   - Window → Devices and Simulators
   - Add each friend's device

3. **Build for Each Device**:
   - Select each device and press ⌘+R
   - Repeat for each friend

### Method C: Ad Hoc Distribution (Advanced)

For tech-savvy friends who want the .ipa file:

1. **Create Ad Hoc Archive**
   - Product → Archive
   - Distribute App → Ad Hoc
   - Export .ipa file

2. **Friends Install**
   - Use tools like 3uTools or Xcode
   - Install .ipa file directly

---

## 🔥 Common Issues & Solutions

### "Developer cannot be verified"
**Solution:** Settings → General → VPN & Device Management → Trust your certificate

### "App won't install"
**Solutions:**
- Check Bundle ID is unique
- Ensure device is trusted
- Try disconnecting/reconnecting iPhone
- Restart Xcode

### "Build failed"
**Solutions:**
- Product → Clean Build Folder
- Ensure all Firebase files are included
- Check internet connection
- Update Xcode to latest version

### "Firebase not working"
**Solutions:**
- Ensure `GoogleService-Info.plist` is in project
- Check Bundle ID matches Firebase project
- Verify internet connection

---

## 🚀 Advanced: App Store Release (Optional)

Want to put your app on the real App Store? Here's how:

### Requirements
- **Apple Developer Account** ($99/year)
- **App Store assets** (screenshots, icon, description)
- **App Review** (1-7 days)

### Steps
1. **Prepare Assets**
   - App icon (1024x1024)
   - Screenshots for different iPhone sizes
   - App description and keywords

2. **Submit for Review**
   - App Store Connect → My Apps
   - Upload final build
   - Fill out app information
   - Submit for review

3. **Review Process**
   - Apple reviews app (usually 1-3 days)
   - Fix any issues and resubmit
   - Once approved, app goes live!

---

## 📋 Quick Reference

### Essential Commands
- **Build & Run**: ⌘+R
- **Clean Build**: ⌘+Shift+K
- **Archive**: Product → Archive

### Essential Files
- `TimeCapsuleCamera.xcodeproj` - Main project file
- `GoogleService-Info.plist` - Firebase configuration
- `Info.plist` - App permissions and settings

### Essential Settings
- **Bundle Identifier**: Must be unique (com.yourname.appname)
- **Team**: Your Apple ID
- **Deployment Target**: iOS 16.0+

---

## 🆘 Need Help?

### Check These First
1. **Xcode Console** (⌘+Shift+Y) for error messages
2. **Device Logs** in Window → Devices and Simulators
3. **Firebase Console** at [console.firebase.google.com](https://console.firebase.google.com)

### Still Stuck?
1. **Google the error message** with "Xcode iOS"
2. **Check Apple Developer Forums**
3. **Stack Overflow** has solutions for most issues

---

## 🎊 Congratulations!

You now have a fully functional Time Capsule Camera app that:
- ✅ Records and uploads videos with original timestamps
- ✅ Shares capsules with friends and family
- ✅ Automatically unseals at the right time
- ✅ Plays videos chronologically
- ✅ Works offline and syncs when online
- ✅ Has beautiful, intuitive UI

**Start creating your first time capsule and make some memories! 📸⏰**

---

*Last updated: August 2025*