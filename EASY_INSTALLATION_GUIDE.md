# 📱 Time Capsule Camera - Easy Installation Guide (No Mac Required)

This quick-start guide gets **your iPhone** and your **friends' iPhones** running the same Time Capsule Camera build using **Codemagic + TestFlight**. No local Mac or Xcode install is required.

---

## 🎯 5-Step Fast Track

1. **Download signing files** from [Apple Developer → Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/):
   - *Distribution certificate (`.p12`)* – create one if you do not have it yet.
   - *App Store provisioning profile (`.mobileprovision`)* using your bundle ID and "App Store" method.
2. **Base64 encode the files** so Codemagic can read them:
   - Any platform: `python scripts/encode_base64.py cert.p12 --env-var IOS_CERT_BASE64` and `python scripts/encode_base64.py profile.mobileprovision --env-var IOS_PROFILE_BASE64`
   - macOS shortcut: `base64 cert.p12 | pbcopy` and `base64 profile.mobileprovision | pbcopy`
   - Windows PowerShell alternative: `[Convert]::ToBase64String([IO.File]::ReadAllBytes("cert.p12"))`
3. **Open [Codemagic](https://codemagic.io/apps)** → choose the **TCC** repository → open the **Environment variables** tab → create (or edit) the `ios_signing` group with:
   - `IOS_CERT_BASE64` → paste encoded certificate
   - `IOS_CERT_PASSWORD` → certificate password (if you set one)
   - `IOS_PROFILE_BASE64` → paste encoded provisioning profile
   - `IOS_BUNDLE_ID` → e.g. `com.yourname.timecapsule`
   - `APPLE_TEAM_ID` → your 10-character Team ID
   - *(Optional but recommended for TestFlight uploads)* `APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`, `APP_STORE_CONNECT_API_KEY_BASE64`
4. **Start the `ios-build` workflow** from Codemagic. It archives the app, exports an IPA, and uploads to TestFlight automatically when App Store Connect keys are present.
5. **Install on devices**:
   - Personal device: open the TestFlight app → accept the invite → install.
   - Friends: add them in App Store Connect → they get the same TestFlight build instantly.

---

## 🛠️ Detailed Walkthrough

### 1. Prepare Apple assets (10 minutes)
1. Sign in at [developer.apple.com](https://developer.apple.com/account/) → Certificates, IDs & Profiles.
2. **Create/Download Distribution Certificate**
   - Certificates → `+` → "Apple Distribution".
   - Upload Certificate Signing Request (CSR) → download `.cer` → double-click on a Mac or use Keychain Access to export `.p12`.
3. **Provisioning Profile**
   - Profiles → `+` → App Store → select your bundle ID.
   - Add the distribution certificate you just exported → download `.mobileprovision`.

> ✅ Tip: Re-download both files whenever you add a new device or regenerate credentials.

### 2. Encode for Codemagic (5 minutes)

Codemagic stores these as secure environment variables.

| Platform | Command |
| --- | --- |
| Any platform | `python scripts/encode_base64.py cert.p12 --env-var IOS_CERT_BASE64` and `python scripts/encode_base64.py profile.mobileprovision --env-var IOS_PROFILE_BASE64` |
| macOS shortcut | `base64 cert.p12 | pbcopy` and `base64 profile.mobileprovision | pbcopy` |
| Windows PowerShell | `[Convert]::ToBase64String([IO.File]::ReadAllBytes("cert.p12"))` |

Paste the outputs into a safe document temporarily—you'll copy them into Codemagic next.

### 3. Configure Codemagic (8 minutes)
1. Go to **Codemagic → Apps → (TCC)**.
2. Click **Environment variables** → **Add group** → name it `ios_signing`.
3. Add the following variables (mark as *Secure*):
   - `IOS_CERT_BASE64`
   - `IOS_CERT_PASSWORD` *(empty if you exported with no password)*
   - `IOS_PROFILE_BASE64`
   - `IOS_BUNDLE_ID`
   - `APPLE_TEAM_ID`
   - `IOS_EXPORT_METHOD` → `app-store` (ensures TestFlight-compatible builds)
4. If you want TestFlight uploads (recommended):
   - Generate an App Store Connect API key (Users and Access → Keys → `+`).
   - Download the `.p8`, base64 encode it, and store in `APP_STORE_CONNECT_API_KEY_BASE64`.
   - Add `APP_STORE_CONNECT_KEY_ID` and `APP_STORE_CONNECT_ISSUER_ID` from the key details page.
5. Press **Save** and attach the `ios_signing` group to the `ios-build` workflow if it is not already attached.

### 4. Trigger the build (20 minutes)
1. Open the **Builds** tab → click **Start new build** → choose branch.
2. Confirm the workflow is `ios-build`.
3. (Optional) Override variables for this run—e.g., set `IOS_EXPORT_METHOD` to `ad-hoc` if you need an installable IPA without TestFlight.
4. Click **Start new build** and wait. Archiving and export take ~12 minutes; TestFlight upload adds ~5 minutes.
5. When the build is green, download artifacts if you need the raw IPA or XCArchive.

### 5. Install on devices (5 minutes)

**Via TestFlight (recommended)**
1. Visit [App Store Connect → My Apps → Time Capsule Camera → TestFlight](https://appstoreconnect.apple.com/apps).
2. Add yourself under *Internal Testing* if you need instant access; otherwise add friends as *External Testers*.
3. Send invites. Everyone receives an email that opens TestFlight and installs the build in two taps.

**Via direct IPA (ad-hoc)**
1. Ensure every tester's UDID is added to the provisioning profile before building.
2. Download the IPA artifact from Codemagic.
3. Use Apple Configurator 2 (macOS) or a service like Diawi/TestApp.io to sideload the IPA onto registered devices.

---

## 👥 Keeping Friends in Sync

| Scenario | What to do |
| --- | --- |
| Add/remove testers quickly | Use TestFlight → External Testers. They stay on the same capsule backend instantly. |
| Someone new joins without an Apple ID | Invite them by public TestFlight link (App Store Connect → TestFlight → Enable Public Link). |
| Need private builds for a tiny group | Use ad-hoc export and include only those UDIDs in the provisioning profile. |

---

## 🧪 Smoke Tests After Every Build
1. Log in, create a capsule, and add a clip.
2. Invite a friend, let them upload a clip, verify both clips appear.
3. Fast-forward the open date and confirm playback order matches capture timestamps.

---

## 🆘 Troubleshooting Cheat Sheet

| Issue | Fix |
| --- | --- |
| `IOS_CERT_BASE64` missing in build logs | Re-open Environment variables → ensure value is present and marked secure. |
| `Provisioning profile not found` | Regenerate App Store profile after changing bundle ID or certificates; update `IOS_PROFILE_BASE64`. |
| TestFlight upload skipped | Confirm `APP_STORE_CONNECT_*` variables are set and valid, and `IOS_EXPORT_METHOD=app-store`. |
| TestFlight build "Processing" forever | Visit App Store Connect → TestFlight → click the build → resolve any missing compliance info (encryption, export compliance). |
| App installs but Firebase fails | Re-download `GoogleService-Info.plist` with matching bundle ID and commit it before rebuilding. |

---

## 🚀 Ready for App Store Launch?
Follow the same workflow but submit the processed TestFlight build for App Review once you are satisfied with beta testing. All signing assets remain valid—you only need to provide screenshots, metadata, and privacy details in App Store Connect.

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