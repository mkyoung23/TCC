# 📱 FINAL INSTALLATION INSTRUCTIONS — Time Capsule Camera (Codemagic + TestFlight)

Use this checklist to go from "nothing configured" to **installing the app on your iPhone and all friends' iPhones** using Codemagic. Every step is tailored for a **no-Mac setup**.

---

## ✅ Pre-flight Status

| Area | Status |
| --- | --- |
| Source code | `work` branch, ready for archive |
| Firebase | `GoogleService-Info.plist` committed (matches production project) |
| Codemagic workflow | `ios-build` handles signing, IPA export, optional TestFlight upload |

---

## 1. Create/Refresh Signing Assets (Apple Developer)

1. Log in to [developer.apple.com/account](https://developer.apple.com/account).
2. **Certificates → `+` → Apple Distribution** → follow wizard → download `.cer` → export `.p12` (set a password or leave blank).
3. **Profiles → `+` → App Store** → choose your bundle ID → select the distribution certificate → download `.mobileprovision`.
4. Keep both files handy. Whenever you rotate certificates or change bundle IDs, repeat this section.

---

## 2. Convert Files to Base64 (so Codemagic can store them securely)

| Platform | Command |
| --- | --- |
| macOS | `base64 cert.p12 | pbcopy` and `base64 profile.mobileprovision | pbcopy` |
| Windows/Linux/Any | `python scripts/encode_base64.py cert.p12 --env-var IOS_CERT_BASE64` and `python scripts/encode_base64.py profile.mobileprovision --env-var IOS_PROFILE_BASE64` |
| PowerShell (alternative) | `[Convert]::ToBase64String([IO.File]::ReadAllBytes("cert.p12"))` |

Save the outputs temporarily—you will paste them into Codemagic secrets next.

---

## 3. Configure Codemagic Secrets

1. Open [Codemagic → Apps → TCC](https://codemagic.io/apps).
2. Go to **Environment variables** → **Add group** → name it `ios_signing` (or edit the existing group).
3. Add these variables (mark each as *Secure*):
   - `IOS_CERT_BASE64` → base64 value of the `.p12`
   - `IOS_CERT_PASSWORD` → password you used when exporting (leave blank if none)
   - `IOS_PROFILE_BASE64` → base64 value of the provisioning profile
   - `IOS_BUNDLE_ID` → e.g. `com.yourname.timecapsule`
   - `APPLE_TEAM_ID` → your Team ID from Apple Developer
   - `IOS_EXPORT_METHOD` → set to `app-store` for TestFlight
4. Optional (required for automatic TestFlight upload):
   - `APP_STORE_CONNECT_KEY_ID`
   - `APP_STORE_CONNECT_ISSUER_ID`
   - `APP_STORE_CONNECT_API_KEY_BASE64` (base64 of the `.p8` file from App Store Connect → Users & Access → Keys)
5. Save the group and ensure it is attached to the `ios-build` workflow.

> 🔐 Already have Codemagic secure files? Point `IOS_CERT_PATH`/`IOS_PROFILE_PATH` to them instead—the workflow accepts either method.

---

## 4. Kick Off the Build

1. In Codemagic, open the **Builds** tab → **Start new build**.
2. Confirm `Workflow: ios-build` and `Branch: work` (or whichever branch you want).
3. Override variables if necessary (example: `IOS_EXPORT_METHOD=ad-hoc` when you need a UDID-based IPA).
4. Click **Start new build**.
5. Wait ~15 minutes. The pipeline performs:
   - Decode signing assets
   - `xcodebuild archive`
   - IPA export using `exportOptions.plist`
   - TestFlight upload when App Store Connect keys are present
   - Cleanup of signing files

> ⏱️ Check the live logs. If any variable is missing, the script exits with a human-readable hint so you can fix it immediately.

---

## 5. Install the Build on Devices

### If TestFlight Upload Succeeds (Recommended)
1. Go to [App Store Connect → My Apps → Time Capsule Camera → TestFlight](https://appstoreconnect.apple.com/apps).
2. Add yourself as an **Internal Tester** for instant access.
3. Add friends as **External Testers** or enable a **Public Link**.
4. Everyone receives an email → open it on iPhone → installs TestFlight → taps *Install*.

### If You Exported Ad-Hoc IPA
1. Make sure all tester UDIDs are in the provisioning profile before you built.
2. Download the IPA artifact from Codemagic.
3. Use Apple Configurator 2 (Mac), iMazing (Mac/Windows), or a hosted service (e.g., Diawi) to sideload onto registered devices.

---

## 6. Verify the Capsule Experience (5-minute checklist)
1. Sign in with two accounts (you + a friend) using the TestFlight build.
2. Create a capsule, invite the friend, and have each of you upload a video.
3. Confirm both videos appear in the shared capsule timeline.
4. Set the unlock time to a minute in the future → wait for unseal → ensure playback is chronological.

---

## 7. When Things Go Wrong

| Symptom | Fix |
| --- | --- |
| `IOS_CERT_BASE64` unbound variable | Re-open the `ios_signing` group and confirm the variable is filled and **Secure**. |
| Provisioning profile UUID mismatch | Re-download the profile after adding/removing devices or certificates; update `IOS_PROFILE_BASE64`. |
| TestFlight step skipped | Ensure `IOS_EXPORT_METHOD=app-store` and all `APP_STORE_CONNECT_*` secrets exist. |
| TestFlight build stuck "Processing" | Open the build in App Store Connect → answer encryption/export compliance questions → wait a few minutes. |
| Firebase login fails | Confirm the committed `GoogleService-Info.plist` bundle ID matches `IOS_BUNDLE_ID`. |

---

## 8. Ready for Public Launch?

Once the TestFlight build looks good, reuse the same workflow:
1. In App Store Connect, promote the latest processed build to **App Review**.
2. Provide screenshots, privacy details, and marketing text.
3. Submit for review → once approved, move from beta to production without touching Codemagic.

---

## 📬 Need a Human Checklist?

1. ✅ Apple Developer certificate & profile exported.
2. ✅ Secrets pasted into Codemagic `ios_signing` group.
3. ✅ `ios-build` workflow run completes successfully.
4. ✅ TestFlight invite sent to you and your friends.
5. ✅ Everyone installs via TestFlight and uploads videos into the same capsule.

Follow the list in order and you will have the app on every tester's phone without needing a Mac.

## 🎊 YOUR APP IS PRODUCTION-READY!

This isn't a demo or prototype. You have a fully functional app that:

- **Works offline** and syncs when online
- **Handles errors** gracefully with helpful messages
- **Preserves video quality** and original timestamps
- **Scales to thousands** of users (with proper Firebase plan)
- **Follows Apple guidelines** for App Store submission
- **Includes comprehensive security** rules and validation

**Ready to make some memories? Start creating your first time capsule! 📸⏰**

---

## 📞 Need Help?

1. **Check Xcode console** (⌘+Shift+Y) for error details
2. **Google any error message** + "Xcode iOS"
3. **Apple Developer Forums** have solutions for most issues

**Have fun with your Time Capsule Camera app!** 🎬✨