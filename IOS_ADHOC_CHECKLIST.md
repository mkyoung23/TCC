# iOS Ad-hoc Distribution Checklist

Follow this checklist every time you want to produce a Codemagic build that installs directly onto registered devices (like your iPhone 14 Pro) without TestFlight.

---

## 1. Collect Tester Details
- For each physical device that needs to install the IPA, gather:
  - Device name (example: `iPhone 14 Pro – Mikaela`).
  - Device model (displayed automatically once added).
  - UDID (example from the request: `00008120-0016753C0CC3A01E`).
- Ask friends to grab their UDIDs via Finder (plug in device → click the serial number → copy) or Apple Configurator 2.

> ✅ You must repeat the rest of the checklist whenever you add or replace devices. Apple requires every device to be listed in the provisioning profile before it can install an ad-hoc build.

---

## 2. Register Devices in Apple Developer Portal
1. Sign in at [https://developer.apple.com/account](https://developer.apple.com/account) with the Apple ID tied to your developer team.
2. Navigate to **Certificates, IDs & Profiles → Devices**.
3. Click the **+** button and choose **iOS, tvOS, watchOS**.
4. Enter the device name and UDID (for the provided sample, paste `00008120-0016753C0CC3A01E`).
5. Repeat for every tester device.
6. Click **Continue**, then **Register** to save the list.

---

## 3. Regenerate the Ad-hoc Provisioning Profile
1. While still in the Apple Developer portal, go to **Certificates, IDs & Profiles → Profiles**.
2. Find the ad-hoc profile that matches the Time Capsule Camera bundle identifier.
3. Click the profile, then choose **Edit**.
4. Ensure the correct distribution certificate is selected.
5. Scroll to the **Devices** section, tick every device (including new ones) that should install the build.
6. Click **Continue** → **Generate** → **Download** to grab the refreshed `.mobileprovision` file.

> 📝 If you prefer to keep TestFlight builds too, repeat the steps above only for the ad-hoc profile; the App Store profile does not need device UDIDs.

---

## 4. Update Codemagic Secrets
1. Open a terminal (Mac, Windows, or Linux) in the folder containing the downloaded files.
2. Convert the signing assets to base64 strings using either the bundled helper script or your system tools:
   ```bash
   python scripts/encode_base64.py cert.p12 --env-var IOS_CERT_BASE64
   python scripts/encode_base64.py TimeCapsuleCamera.mobileprovision --env-var IOS_PROFILE_BASE64
   ```
   - On macOS you can still run `base64 cert.p12 | pbcopy` if you prefer.
3. In Codemagic, open the app → **Environment variables**.
4. Edit the `ios_signing` group and replace:
   - `IOS_CERT_BASE64` with the new certificate string (if you re-exported it).
   - `IOS_PROFILE_BASE64` with the newly generated provisioning profile string.
5. Double-check `IOS_CERT_PASSWORD`, `IOS_BUNDLE_ID`, and `APPLE_TEAM_ID` are correct for your account.
6. Click **Save**.

> 🔐 Prefer secure files? Upload the `.p12` and `.mobileprovision` to Codemagic’s Secure storage, then set `IOS_CERT_PATH` and `IOS_PROFILE_PATH` instead of base64 values.

---

## 5. Kick Off a Codemagic Build
1. Go to the **Builds** tab in Codemagic.
2. Click **Start new build**.
3. Choose the branch and the `ios-build` workflow.
4. Leave `IOS_EXPORT_METHOD` as `ad-hoc` (default) so the exported IPA stays installable on registered devices.
5. Start the build and wait for it to finish (typically 6–10 minutes).

During the build, Codemagic will:
- Import the certificate and provisioning profile into a temporary keychain.
- Archive the Xcode project with manual signing.
- Export the IPA with your ad-hoc profile.

---

## 6. Install the IPA on Test Devices
1. When the build completes, open the build details → **Artifacts**.
2. Download the `.ipa` file.
3. Install on each registered device using one of these methods:
   - **Apple Configurator 2** (drag the IPA onto the device).
   - **Finder** (macOS 10.15+) by dragging the IPA into the **Files** tab of the device.
   - A trusted over-the-air service like [https://www.installonair.com](https://www.installonair.com) (upload the IPA, send the generated link to testers).
4. Launch the app and sign in—everyone should connect to the same Firebase backend and time capsule data.

---

## 7. Keep Testers in Sync
- When friends upgrade phones or you add new testers, repeat steps 1–5 before shipping a new IPA.
- If a tester cannot install ("App cannot be installed because its integrity could not be verified"), confirm their UDID is in the profile and re-run the build.
- For larger groups, switch `IOS_EXPORT_METHOD` to `app-store` and configure the App Store Connect API variables (see `CODEMAGIC_SETUP.md`) so you can invite testers through TestFlight without collecting UDIDs.

---

## 8. Quick Re-run Checklist
- [ ] All tester UDIDs are registered in Apple Developer.
- [ ] Ad-hoc provisioning profile regenerated after adding devices.
- [ ] `IOS_PROFILE_BASE64` (or secure file path) updated in Codemagic.
- [ ] `IOS_CERT_BASE64` matches the distribution certificate referenced by the profile.
- [ ] Codemagic `ios-build` workflow uses `ad-hoc` export.
- [ ] Latest IPA downloaded and installed on each tester’s device.

Following this flow guarantees your own iPhone 14 Pro—and any friends’ devices you add—can install the Time Capsule Camera test builds generated by Codemagic.
