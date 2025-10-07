# CodeMagic Setup Guide for Time Capsule Camera

## Overview
This guide will help you set up CodeMagic CI/CD to automatically build and distribute your Time Capsule Camera iOS app to TestFlight and the App Store.

## What Was Fixed
The `codemagic.yaml` file has been updated with:
- ✅ Correct workflow name: `ios-tcc`
- ✅ App Store Connect publishing configuration
- ✅ TestFlight automatic submission
- ✅ Email notifications
- ✅ Swift Package Manager support (Firebase dependencies)
- ✅ Proper code signing setup with automatic profile fetching
- ✅ Correct bundle identifier: `com.mkyoung.timecapsulecamera`
- ✅ Proper keychain initialization and certificate management

## Prerequisites

### 1. Apple Developer Account
- Enroll in the Apple Developer Program: https://developer.apple.com/programs/
- Cost: $99/year
- Make sure you have access to App Store Connect

### 2. CodeMagic Account
- Sign up at: https://codemagic.io/
- Connect your GitHub account (mkyoung23/TCC)

## Step-by-Step Setup

### Step 1: Create App Store Connect API Key

This is the MOST IMPORTANT step to fix the authentication error.

1. **Log in to App Store Connect**
   - Go to: https://appstoreconnect.apple.com/
   - Sign in with your Apple ID

2. **Navigate to Users and Access**
   - Click "Users and Access" in the top navigation
   - Select the "Keys" tab under "Integrations"

3. **Generate API Key**
   - Click the "+" button to create a new key
   - Name it: "CodeMagic CI/CD" or "TCC Build Key"
   - Access: Select "App Manager" or "Admin"
   - Click "Generate"

4. **Download the Key**
   - **IMPORTANT**: Download the `.p8` file immediately (you can only download it once!)
   - Save it somewhere safe on your computer
   - Note down:
     - **Key ID** (e.g., `ABC123DEFG`)
     - **Issuer ID** (e.g., `12345678-1234-1234-1234-123456789012`)

### Step 2: Add App Store Connect Integration to CodeMagic

1. **Open CodeMagic Dashboard**
   - Go to: https://codemagic.io/apps
   - Select your TCC project (or add it if not there)

2. **Go to Team Integrations**
   - Click on your profile icon (top right)
   - Select "Teams"
   - Click on your team name
   - Click "Integrations" in the left sidebar

3. **Add App Store Connect Integration**
   - Click "Add integration"
   - Select "App Store Connect"
   - Name it: **`TCC_ASC_KEY`** (this MUST match the name in codemagic.yaml line 6)
   - Upload your `.p8` key file
   - Enter your Key ID
   - Enter your Issuer ID
   - Click "Save"

### Step 3: Register Your App in App Store Connect

1. **Create App in App Store Connect**
   - Go to: https://appstoreconnect.apple.com/
   - Click "My Apps" → "+" → "New App"
   - Platform: iOS
   - Name: Time Capsule Camera
   - Bundle ID: `com.mkyoung.timecapsulecamera`
   - SKU: `timecapsulecamera` (or any unique identifier)
   - User Access: Full Access

2. **Note the App ID** (optional)
   - After creating, find your App Store App ID
   - It's a number like `1234567890`
   - This is useful for tracking but not required for the build

### Step 4: Create TestFlight Beta Group

1. **In App Store Connect**
   - Go to your app → TestFlight tab
   - Click "Internal Testing" or "External Testing"
   - Create a new group named: **"Beta Testers"** (this matches line 51 in codemagic.yaml)
   - Add testers (email addresses of friends you want to test with)

### Step 5: Verify Bundle Identifier

Currently using: `com.mkyoung.timecapsulecamera`

This bundle identifier is already configured in:
- ✅ Xcode project settings
- ✅ `codemagic.yaml` (lines 10 and 14)
- Make sure it matches in App Store Connect when you create your app

### Step 6: Start Your First Build

1. **Commit and Push Changes**
   ```bash
   cd C:\Users\mkyou\OneDrive\Desktop\TCC
   git add codemagic.yaml CODEMAGIC_SETUP.md
   git commit -m "Fix CodeMagic configuration with correct bundle identifier and auth settings"
   git push origin main
   ```

2. **Trigger Build in CodeMagic**
   - Go to CodeMagic dashboard
   - Select your app
   - Click "Start new build"
   - Select the `ios-tcc` workflow
   - Select your branch (main/master)
   - Click "Start new build"

3. **Monitor the Build**
   - Watch the build logs for any errors
   - Build should take 15-30 minutes
   - You'll get an email when it's done

### Step 7: Test with Friends

Once the build succeeds:

1. **Check TestFlight**
   - Your app will automatically be submitted to TestFlight
   - TestFlight will send invitation emails to your beta testers

2. **Share with Friends**
   - Friends will receive an email invitation
   - They download the TestFlight app from App Store
   - Open the email and accept the invitation
   - Install Time Capsule Camera from TestFlight

## How the Build Process Works

The `codemagic.yaml` configuration:

1. **Keychain Setup**: Initializes a secure keychain for code signing
2. **Fetch Signing Files**: Automatically downloads/creates provisioning profiles from App Store Connect
3. **Add Certificates**: Adds your distribution certificate to the keychain
4. **Use Profiles**: Configures Xcode to use the fetched profiles
5. **Resolve Packages**: Downloads Firebase and other Swift Package dependencies
6. **Build Archive**: Creates a release build and archives it
7. **Export IPA**: Exports the archive as an IPA file ready for distribution
8. **Upload to TestFlight**: Automatically submits to TestFlight
9. **Email Notification**: Sends you an email with build results

## Troubleshooting

### "Authentication information is missing"
- Make sure the integration name in CodeMagic is exactly **`TCC_ASC_KEY`** (line 6 of codemagic.yaml)
- Verify your App Store Connect API key is active
- Check that Key ID and Issuer ID are correct

### "No provisioning profile found"
- The config uses automatic code signing with `app-store-connect fetch-signing-files`
- This will automatically fetch and create provisioning profiles
- Make sure the bundle ID matches: `com.mkyoung.timecapsulecamera`

### "Scheme not found"
- Verify the scheme name in Xcode matches `TimeCapsuleCamera`
- Make sure the scheme is shared (in Xcode: Product → Scheme → Manage Schemes → check "Shared")

### Build fails with Firebase errors
- Make sure `GoogleService-Info.plist` is included in the Xcode project
- Verify it's in the target's "Copy Bundle Resources" build phase
- Check that Swift Package dependencies are properly configured

### Build fails with code signing errors
- Verify the App Store Connect integration name is exactly `TCC_ASC_KEY`
- Check that your Apple Developer account has access to the bundle ID
- Make sure you have an active paid Apple Developer membership ($99/year)

### "exportOptionsPlist not found"
- The current config references `/Users/builder/export_options.plist`
- If this fails, you may need to create this file or use Xcode's built-in export
- Consider using `xcodebuild -exportArchive` with `-allowProvisioningUpdates` flag

## Next Steps

After successful TestFlight distribution:

1. **Test Thoroughly**
   - Test all features with your friends
   - Check video recording, playback, capsule creation
   - Verify Firebase integration works
   - Test push notifications

2. **Submit to App Store** (when ready)
   - In `codemagic.yaml`, you can add:
     ```yaml
     submit_to_app_store: true
     ```
   - Add app screenshots and description in App Store Connect
   - Submit for review

3. **Monitor Analytics**
   - Set up Firebase Analytics
   - Monitor crash reports
   - Track user engagement

## Important Notes

- **Never commit** your `.p8` key file to Git
- **Keep secure**: Your App Store Connect credentials
- **Test first**: Always test on TestFlight before App Store submission
- **Regular updates**: Keep your app and dependencies up to date
- **Development Team**: The Xcode project has team ID `6XNH7D52V6` configured

## Configuration Summary

Key configuration in `codemagic.yaml`:
- **Workflow**: `ios-tcc`
- **Integration**: `TCC_ASC_KEY` (must match your CodeMagic integration name)
- **Bundle ID**: `com.mkyoung.timecapsulecamera`
- **Xcode Project**: `time_capsule_camera/TimeCapsuleCamera.xcodeproj`
- **Scheme**: `TimeCapsuleCamera`
- **TestFlight**: Auto-submit enabled
- **Beta Group**: "Beta Testers"
- **Email**: Build notifications to mkyoung23@gmail.com

## Support

If you need help:
- CodeMagic Docs: https://docs.codemagic.io/
- CodeMagic YAML reference: https://docs.codemagic.io/yaml-basic-configuration/yaml-getting-started/
- Apple Developer Support: https://developer.apple.com/support/
- Firebase Docs: https://firebase.google.com/docs/ios/setup

## Alternative Installation Guides

There are two other installation guides in the repo:
- `EASY_INSTALLATION_GUIDE.md` - For web-based deployment
- `FINAL_INSTALLATION_INSTRUCTIONS.md` - Additional deployment info

---

**You're all set! Your Time Capsule Camera app will now automatically build and deploy to TestFlight every time you push to GitHub!** 🚀📱
