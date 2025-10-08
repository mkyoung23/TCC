# 🔧 TCC CodeMagic Troubleshooting Guide

## Quick Diagnostics Checklist

Before starting a build, verify:

- [ ] Environment variables are set correctly in CodeMagic
- [ ] Using **R9RRF25S4U** key (Admin), NOT WLY4NFDU6L
- [ ] "Beta Testers" group exists in App Store Connect TestFlight
- [ ] Latest code is pushed to GitHub main branch

---

## Common Error Messages & Fixes

### ❌ Error: "Authentication to App Store Connect failed"

**Cause**: Wrong API key or incorrect credentials

**Fix**:
1. Go to CodeMagic → Environment variables
2. Check `APP_STORE_CONNECT_KEY_IDENTIFIER` = `R9RRF25S4U`
3. Check `APP_STORE_CONNECT_ISSUER_ID` = `f94e54a5-8ebc-49c0-b581-1099125c304f`
4. Verify `APP_STORE_CONNECT_PRIVATE_KEY` contains the full private key from `AuthKey_R9RRF25S4U.p8`
5. Make sure private key includes the BEGIN/END lines

---

### ❌ Error: "No signing certificate found"

**Cause**: Provisioning profile is invalid or certificate doesn't exist

**Fix**:
1. Go to: https://developer.apple.com/account/resources/profiles
2. Find "TimeCapsuleCamera Dist Profile" - it shows **Invalid** status
3. **Option A**: Delete it and let CodeMagic recreate it (RECOMMENDED)
   - Click the profile → Delete
   - CodeMagic's `--create` flag will generate new one
4. **Option B**: Edit and add certificate manually
   - Click Edit → Select your distribution certificate → Save → Download
   - Upload to CodeMagic

**Or let CodeMagic auto-create** (easiest):
1. Delete ALL certificates in CodeMagic: Account → Code signing identities → Delete
2. The build will auto-generate everything

---

### ❌ Error: "could not find or load the private key"

**Cause**: Private key format is incorrect or has extra whitespace

**Fix**:
1. Open your `AuthKey_R9RRF25S4U.p8` file (in OneDrive/Documents)
2. Copy the ENTIRE contents including:
   ```
   -----BEGIN PRIVATE KEY-----
   (key content)
   -----END PRIVATE KEY-----
   ```
3. Paste into CodeMagic `APP_STORE_CONNECT_PRIVATE_KEY` variable
4. NO extra spaces or newlines before/after

---

### ❌ Error: "Command 'convert' not found"

**Cause**: Using old codemagic.yaml with ImageMagick

**Fix**:
Pull latest code from GitHub - I already fixed this:
```bash
cd C:\Users\mkyou\OneDrive\Desktop\TCC
git pull
```

The new version uses Python PIL instead of ImageMagick.

---

### ❌ Error: "export_options.plist not found"

**Cause**: Using old codemagic.yaml

**Fix**:
Pull latest code - I added automatic plist generation:
```bash
cd C:\Users\mkyou\OneDrive\Desktop\TCC
git pull
```

---

### ❌ Error: "Beta group 'Beta Testers' not found"

**Cause**: Group doesn't exist in App Store Connect

**Fix**:
1. Go to: https://appstoreconnect.apple.com
2. Time Capsule Camera → TestFlight
3. Create group named exactly: **Beta Testers**
4. Add yourself as a tester

---

### ❌ Error: "Provisioning profile doesn't include the currently selected device"

**Cause**: Using Development profile instead of Distribution

**Fix**:
The codemagic.yaml is configured for `IOS_APP_STORE` type. This is correct.

Check:
1. Apple Developer → Profiles → TimeCapsuleCamera Dist Profile
2. Type should be: **App Store**
3. Not: Development, Ad Hoc, or Enterprise

---

### ❌ Error: "The bundle identifier is invalid"

**Cause**: Mismatch between Xcode and CodeMagic

**Fix**:
Bundle ID should be: `com.mkyoung.timecapsulecamera`

Verify in:
1. Xcode project settings
2. codemagic.yaml `BUNDLE_ID` variable
3. Apple Developer Portal App ID
4. export_options.plist

All already configured correctly in my fixes.

---

### ❌ Error: "failed to fetch signing files"

**Cause**: API key doesn't have permission to create certificates

**Fix**:
Using the **R9RRF25S4U** key with **Admin** role should work.

If still failing:
1. Go to: https://appstoreconnect.apple.com/access/api
2. Click on "Codemagic CI" key (R9RRF25S4U)
3. Verify role is **Admin** (not App Manager)
4. If it's App Manager, delete and recreate with Admin role

---

### ❌ Error: "The request could not be completed because: Multiple profiles found"

**Cause**: Multiple provisioning profiles exist for same bundle ID

**Fix**:
1. Go to: https://developer.apple.com/account/resources/profiles
2. Search for: `com.mkyoung.timecapsulecamera`
3. Delete all EXCEPT: **TimeCapsuleCamera Dist Profile**
4. Or delete all and let CodeMagic recreate

---

## 🔍 How to Read Build Logs

CodeMagic shows step-by-step progress:

1. **Fetching code** - Should complete in 10 seconds
2. **Generate app icons** - Should create 9 PNG files
3. **Set up code signing** - Watch for "fetch-signing-files" output
4. **Create export options** - Creates plist file
5. **Resolve Swift packages** - Downloads dependencies
6. **Build archive** - Longest step (5-10 mins)
7. **Export IPA** - Creates .ipa file
8. **Publish to App Store Connect** - Uploads to TestFlight

**If it fails**: Note which step failed and check the error message.

---

## ✅ Successful Build Looks Like:

```
✓ Fetch code from GitHub
✓ Generate placeholder app icons
  - Created 9 icon files
✓ Set up code signing
  - Fetched distribution certificate
  - Fetched provisioning profile
  - Keychain configured
✓ Create export options
  - export_options.plist created
✓ Resolve Swift packages
  - Firebase packages downloaded
✓ Build archive
  - Build succeeded
  - Archive created: tcc.xcarchive
✓ Export IPA
  - Exported: TimeCapsuleCamera.ipa
✓ Publish to App Store Connect
  - Uploaded to TestFlight
  - Submitted to Beta Testers group
✓ Email notification sent
```

---

## 🆘 Still Having Issues?

**Send me the error message from the build log:**

1. Go to CodeMagic build
2. Click on the **failed step** (red X)
3. Copy the **last 20-30 lines** of the error
4. Send it to me

I'll diagnose and fix it immediately!

---

## 📋 Pre-Build Verification

Run this checklist before starting a build:

### CodeMagic Environment Variables:
```
✓ APP_STORE_CONNECT_ISSUER_ID = f94e54a5-8ebc-49c0-b581-1099125c304f
✓ APP_STORE_CONNECT_KEY_IDENTIFIER = R9RRF25S4U
✓ APP_STORE_CONNECT_PRIVATE_KEY = <full private key with BEGIN/END lines>
```

### Apple Developer Portal:
```
✓ Bundle ID exists: com.mkyoung.timecapsulecamera
✓ App exists in App Store Connect: Time Capsule Camera (TCC)
✓ API Key exists with Admin role: R9RRF25S4U
```

### App Store Connect TestFlight:
```
✓ "Beta Testers" group exists
✓ You are added to the group
```

### GitHub:
```
✓ Latest codemagic.yaml is pushed
✓ Repository is accessible at: https://github.com/mkyoung23/TCC
```

---

**Everything should work now. If you get errors, send me the log!** 🚀
