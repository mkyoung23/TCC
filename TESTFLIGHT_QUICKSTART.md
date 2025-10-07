# 🚀 Quick Device Preview & TestFlight Checklist

This is the shortest path to (1) see Time Capsule Camera on your iPhone right now and (2) invite friends through TestFlight without collecting UDIDs. Follow each step in order—no guesswork.

---

## Part A — Preview on *Your* iPhone (≈10 minutes, optional)
> 💡 **No Mac? Skip to Part B and let Codemagic/TestFlight handle everything.**

1. **Install Xcode** from the Mac App Store (skip if already installed).
2. **Open** `time_capsule_camera/TimeCapsuleCamera.xcodeproj`.
3. **Plug in your iPhone** → tap **Trust** on the device.
4. In Xcode’s top toolbar, **choose your iPhone** from the device picker.
5. Go to **Signing & Capabilities** → sign in with your Apple ID when prompted.
6. **Set a unique bundle ID** (e.g., `com.<yourname>.timecapsule`).
7. Press **⌘ + R** (Run). Xcode installs the app on your phone.
8. On the phone, open **Settings → General → VPN & Device Management** and **Trust** your Apple ID if asked.

> ✅ Result (optional sanity check): The app is running on your iPhone. Tweak UI, log in, or capture video before inviting friends.

---

## Part B — Prepare Codemagic for TestFlight (one-time setup)
1. **Create an App Store Connect API key:**
   - App Store Connect → Users and Access → Keys → **+**.
   - Role: **App Manager**.
   - Download the `AuthKey_<KEY_ID>.p8` file.
2. Run `python scripts/setup_codmagic.py` (any platform) and follow the prompts. It will:
   - Base64-encode your certificate, provisioning profile, and the App Store Connect API key you downloaded above.
   - Ask for the bundle ID, team ID, and export method.
   - Save everything into `codemagic.env.local` so you can `source` it locally or copy/paste the values into Codemagic.
   > Prefer manual control? You can still base64 files yourself with `python scripts/encode_base64.py <file> --env-var ...` or `base64 <file>` on macOS.
3. In Codemagic, open your app → **Environment variables** → create/extend the `ios_signing` group with:
   - `IOS_CERT_BASE64` → Base64 `.p12` signing certificate (or `IOS_CERT_PATH` for secure files).
   - `IOS_CERT_PASSWORD` → Password used when exporting the `.p12` (blank if none).
   - `IOS_PROFILE_BASE64` → Base64 provisioning profile (or `IOS_PROFILE_PATH`).
   - `IOS_BUNDLE_ID` → Your bundle ID from Part A.
   - `IOS_EXPORT_METHOD=app-store` → Forces TestFlight-ready exports.
   - `APP_STORE_CONNECT_KEY_ID` → From App Store Connect.
   - `APP_STORE_CONNECT_ISSUER_ID` → Also from App Store Connect.
   - `APP_STORE_CONNECT_API_KEY_BASE64` → Base64 string from step 2.
4. Attach the `ios_signing` group to the `ios-build` workflow.
5. Under **Build triggers**, make sure **Manual** is enabled so you can start builds on demand.

> 📌 Tip: Already using ad-hoc secrets? Leave them in place—switching `IOS_EXPORT_METHOD` to `app-store` is enough once the App Store Connect keys are set.

---

## Part C — Kick Off Your First TestFlight Build
1. In Codemagic → **Builds** → **Start new build**.
2. Select the branch you want to test.
3. Confirm the `ios-build` workflow and start the run.
4. Wait for Codemagic to finish (usually 6–10 minutes). The log will say **"Upload to TestFlight"** when complete.
5. In App Store Connect → **TestFlight**, you’ll see the new build processing. Processing typically takes 5–15 minutes.

---

## Part D — Invite Testers (zero UDIDs!)
1. In App Store Connect → Your app → **TestFlight**:
   - **Internal testers** (your team) are ready immediately.
   - **External testers** need a short beta review—fill out the compliance form once.
2. Click **Add Testers** → enter their email addresses.
3. Testers get an email plus a redemption code inside the TestFlight app.
4. They install TestFlight (free on the App Store), tap your invite, and the app downloads automatically.

> 🎉 Everyone now has the same build without touching UDIDs or Finder/Configurator installs.

---

## Part E — When You Ship New Builds
1. Push commits to GitHub (or trigger Codemagic manually).
2. Codemagic rebuilds and uploads the new IPA to TestFlight.
3. Testers get an automatic notification from TestFlight—no extra steps needed.
4. Mark feedback in App Store Connect or gather it directly from testers.

---

## Quick Reference
- **Need more detail?** Review the [Codemagic Setup Guide](CODEMAGIC_SETUP.md) for deep dives and fallbacks.
- **Still want an IPA for manual installs?** Set `IOS_EXPORT_METHOD=ad-hoc` on a per-build basis—Codemagic keeps the TestFlight keys for the next run.
- **Switching bundle IDs?** Update Firebase (`GoogleService-Info.plist`) and the `IOS_BUNDLE_ID` secret so login/upload keep working.

You now have a repeatable flow: run locally to sanity check, let Codemagic push to TestFlight, and keep everyone in sync with zero manual device management.
