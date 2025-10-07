# Codemagic Setup Guide for Time Capsule Camera

This guide walks you through configuring Codemagic so you and your friends can build, sign, and download the same Time Capsule Camera iOS app for testing.

---

## TL;DR: Pick Your Distribution Path

| Your goal | Use this flow | Why it’s easy |
| --- | --- | --- |
| **See the app on your iPhone in <10 minutes** | Follow the "Your iPhone Preview" steps in the [Quick Device Preview & TestFlight Checklist](TESTFLIGHT_QUICKSTART.md) | No provisioning profiles required—just Xcode and your Apple ID |
| **Let friends install without collecting UDIDs** | Configure **TestFlight** in Codemagic (see the checklist above and Section 2 below) | Testers only need an email invite via the TestFlight app |
| **Share an IPA with a handful of registered devices** | Stay on the default **Ad-hoc** workflow (Section 2) | Works offline if everyone’s UDID is pre-registered |

Once you know which path you want, come back here for the deeper setup details.

---

## 1. Connect the Repository
1. Log in to [Codemagic](https://codemagic.io/).
2. Click **Add application** → **Connect repository**.
3. Select GitHub and authorize access if prompted.
4. Pick the `TCC` repository and choose the `main` branch (or the branch you want to build).

---

## 2. Create an Environment Variable Group
Codemagic stores secrets in **Environment Variable Groups**. Create one called `ios_signing` with the following variables:

> 🚀 **Fastest option:** run `python scripts/setup_codmagic.py` and answer the prompts. It base64-encodes your certificate, provisioning profile, and optional App Store Connect key, then writes a ready-to-source `codemagic.env.local` that mirrors every variable below. Open the file, copy/paste the values into Codemagic, and you’re done.

### Step-by-step in the Codemagic UI

1. In Codemagic, open your app → **Environment variables**.
2. Click **Add group**, set the **Group name** to `ios_signing`, and press **Add**.
3. For each row in the table below, click **Add variable**, type the **Variable** name exactly as written, paste the **Value** from your helper script or template, and toggle **Secure** to the value listed in the last column.
4. Press **Save** after you finish adding every variable so the group persists.

| Variable | Paste this value | Secure? |
| --- | --- | --- |
| `IOS_CERT_BASE64` | Base64 of your `.p12` signing certificate. | ✅ Yes |
| `IOS_CERT_PASSWORD` | Password you set when exporting the `.p12` (leave blank if you didn’t set one). | ✅ Yes |
| `IOS_PROFILE_BASE64` | Base64 of the provisioning profile that matches your bundle ID. | ✅ Yes |
| `IOS_BUNDLE_ID` | `com.mkyoung.timecapsulecamera` *(or your custom bundle ID).* | ✅ Yes |
| `IOS_EXPORT_METHOD` *(optional)* | `ad-hoc`, `app-store`, or `development`. Defaults to `ad-hoc` if omitted. | ❌ No |
| `IOS_CODE_SIGN_IDENTITY` *(optional)* | Usually `Apple Distribution` or `Apple Development`. | ❌ No |
| `APPLE_TEAM_ID` *(optional)* | Your 10-character team ID such as `6XNH7D52V6`. | ❌ No |
| `APP_STORE_CONNECT_KEY_ID` *(optional)* | API key ID such as `WLY4NFDU6L`. | ✅ Yes |
| `APP_STORE_CONNECT_ISSUER_ID` *(optional)* | Issuer UUID such as `f94e54a5-8ebc-49c0-b581-1099125c304f`. | ✅ Yes |
| `APP_STORE_CONNECT_API_KEY_BASE64` *(optional)* | Base64 of your `AuthKey_<KEY_ID>.p8` file. | ✅ Yes |

> 🔐 Marking a variable as **Secure** hides its value in Codemagic’s UI and build logs. Anything that contains a password, certificate, profile, or API key should be secure. Plain-text metadata (bundle ID, export method, signing identity) can remain non-secure for clarity, but you may secure them as well if you prefer.

**After the table is filled in:**

1. Click **Save** in the `ios_signing` group.
2. Attach the group to your workflow: open **App settings → Workflows → ios-build → Environment**, tick `ios_signing`, and save.
3. Double-check you set `IOS_EXPORT_METHOD` to `app-store` if you plan to invite friends through TestFlight; leave it on `ad-hoc` if you only need an installable IPA for registered UDIDs.
4. Proceed to [Section 4](#4-start-a-build) to trigger your first build.

| Variable | Description | How to obtain |
| --- | --- | --- |
| `IOS_CERT_BASE64` | Base64 string of your Distribution or Development `.p12` signing certificate. | Export from Keychain Access → right-click certificate → **Export** as `.p12` → run `base64 cert.p12 | pbcopy` on macOS **or** `python scripts/encode_base64.py cert.p12 --env-var IOS_CERT_BASE64` on any platform. Windows-only instructions live in the [Apple signing assets guide](WINDOWS_SIGNING_ASSETS.md). |
| `IOS_CERT_PASSWORD` | Password used when exporting the `.p12`. Leave empty if none. | Choose when you export the `.p12`. |
| `IOS_PROFILE_BASE64` | Base64 string of the provisioning profile that matches your bundle ID and distribution method. | Download profile from Apple Developer portal → run `base64 profile.mobileprovision | pbcopy` **or** `python scripts/encode_base64.py profile.mobileprovision --env-var IOS_PROFILE_BASE64`. Windows-only instructions live in the [Apple signing assets guide](WINDOWS_SIGNING_ASSETS.md). |
| `IOS_BUNDLE_ID` | Bundle identifier the profile was created for. | e.g. `com.yourname.timecapsule`. |
| `IOS_EXPORT_METHOD` *(optional)* | `ad-hoc`, `app-store`, or `development`. Defaults to `ad-hoc` to quickly share builds with registered devices. | Choose based on how you distribute the build. |
| `IOS_CODE_SIGN_IDENTITY` *(optional)* | Usually `Apple Distribution` or `Apple Development`. Defaults to `Apple Distribution`. | Match the certificate you exported. |
| `APPLE_TEAM_ID` *(optional)* | Your 10-character Apple Developer Team ID. Defaults to `6XNH7D52V6`; override with your own. | Found in Apple Developer portal → Membership. |
| `APP_STORE_CONNECT_KEY_ID` *(optional)* | Short identifier (ex: `ABC123XYZ`) for your App Store Connect API key. | App Store Connect → Users and Access → Keys. |
| `APP_STORE_CONNECT_ISSUER_ID` *(optional)* | 36-character issuer ID for the App Store Connect API. | Same Keys page as above. |
| `APP_STORE_CONNECT_API_KEY_BASE64` *(optional)* | Base64 string of the `.p8` API key file used for TestFlight uploads. | Download the `.p8`, then run `base64 AuthKey_ABC123XYZ.p8 | pbcopy` **or** `python scripts/encode_base64.py AuthKey_ABC123XYZ.p8 --env-var APP_STORE_CONNECT_API_KEY_BASE64`. |

> 💡 **Tip:** No Mac? Use the included [`scripts/encode_base64.py`](scripts/encode_base64.py) helper: `python scripts/encode_base64.py cert.p12 --env-var IOS_CERT_BASE64`. It prints a single line you can paste into Codemagic on Windows, Linux, or GitHub Codespaces. Detailed Windows-only export steps—covering CSR generation, certificate conversion, profile download, and Base64 encoding—are available in [Exporting Apple Signing Assets on Windows](WINDOWS_SIGNING_ASSETS.md). On macOS, `base64 cert.p12 | pbcopy` still works if you prefer the built-in tool.

> 🔁 **Already using `APPSTORECONNECT_*` variables elsewhere?** Keep them. The workflow now reads both the dashed (`APP_STORE_CONNECT_*`) and undashed (`APPSTORECONNECT_*`) names, so you don’t need to rename existing secret groups.

### Quick sanity check before you build

1. Either run `python scripts/setup_codmagic.py` **or** copy `codemagic.env.example` to a private location (for example `cp codemagic.env.example codemagic.env`).
2. If you used the template, fill in the placeholders with your actual base64 strings, bundle ID, and App Store Connect metadata. The interactive script does this for you automatically.
3. Load the file in your shell (`source codemagic.env.local` or the filename you chose).
4. Run [`scripts/check_codmagic_env.py`](scripts/check_codmagic_env.py). It prints which secrets are present, calls out anything missing, and exits with a non-zero code if the required values aren’t populated.

When the script reports `✅ All required Codemagic signing secrets are present.`, mirror the same values inside Codemagic’s `ios_signing` group. This removes guesswork and prevents the “unbound variable” errors you saw earlier.

Prefer Codemagic’s **Secure files** instead of inline base64? Upload your `.p12` and `.mobileprovision` there and map their extracted paths to the optional variables below (Codemagic injects them under `/tmp/secure_files` by default):

| Optional variable | Expected value |
| --- | --- |
| `IOS_CERT_PATH` *(or `IOS_CERT_FILE`)* | Absolute path to the certificate file downloaded from Secure files during the build. |
| `IOS_PROFILE_PATH` *(or `IOS_PROFILE_FILE`)* | Absolute path to the provisioning profile file downloaded from Secure files. |

The workflow also accepts the legacy `CERTIFICATE_BASE64` / `PROVISIONING_PROFILE_BASE64` names as well as Codemagic’s `CM_CERTIFICATE_BASE64` / `CM_PROVISIONING_PROFILE_BASE64` fallbacks, so you can reuse existing secret groups without renaming variables.

Attach the `ios_signing` group to the **Time Capsule Camera iOS** workflow under the **Environment** tab.

---

### Optional: Enable TestFlight Uploads (Skip UDIDs)

If you’d rather avoid collecting UDIDs and let friends install through Apple’s TestFlight app:

1. In App Store Connect, go to **Users and Access → Keys** and create a new **App Store Connect API key** with the *App Manager* role.
2. Download the generated `AuthKey_<KEY_ID>.p8` file immediately (Apple only lets you grab it once).
3. Base64-encode the `.p8` file:
   - macOS shortcut: `base64 AuthKey_<KEY_ID>.p8 | pbcopy`
   - Any platform: `python scripts/encode_base64.py AuthKey_<KEY_ID>.p8 --env-var APP_STORE_CONNECT_API_KEY_BASE64`
   Paste the output into `APP_STORE_CONNECT_API_KEY_BASE64`.
4. Copy the **Key ID** into `APP_STORE_CONNECT_KEY_ID` and the **Issuer ID** into `APP_STORE_CONNECT_ISSUER_ID`.
5. Switch `IOS_EXPORT_METHOD` to `app-store` (either in the variable group or for a single build run) so the exported archive is eligible for TestFlight/App Store Connect.

With those values set, the workflow’s **Upload to TestFlight (optional)** step will automatically push the freshly generated `.ipa` to App Store Connect. TestFlight testers only need an email invite—no device registration required.

You can keep both ad-hoc and TestFlight flows by duplicating the workflow in Codemagic: one copy stays on `ad-hoc` for quick internal checks, the other uses `app-store` plus the App Store Connect keys for beta distribution.

---

## 3. Configure Build Triggers
1. In Codemagic, open the app settings → **Build triggers**.
2. Enable **Manual builds** so you can start builds anytime.
3. (Optional) Enable **On push** to build automatically when new commits arrive.

---

## 4. Start a Build
1. Go to the **Builds** tab.
2. Click **Start new build**.
3. Choose the branch and the `ios-build` workflow.
4. Click **Start build**. Codemagic will:
   - Import your signing assets into a temporary keychain.
   - Archive the Xcode project in release mode.
   - Export an IPA using the method you specified (`ad-hoc` by default).

Build time is usually 6-10 minutes.

---

## 5. Download the IPA
After the build finishes:
1. Open the build details page.
2. Scroll to **Artifacts**.
3. Download the `.ipa` file.
4. Distribute it:
   - **Ad-hoc**: Install with Apple Configurator 2, Finder, or a trusted OTA service (devices must appear in the provisioning profile). Follow the step-by-step [iOS Ad-hoc Distribution Checklist](IOS_ADHOC_CHECKLIST.md) to keep everyone in sync.
   - **Development**: Install with Xcode or Apple Configurator 2.
   - **App Store**: Upload the `.ipa` from Codemagic to App Store Connect.

Codemagic also stores the `.xcarchive` artifact so you can re-export later if needed.

---

## 6. Invite Friends to Test
1. Decide how you want friends to install:
   - **Ad-hoc IPA**: Share the `.ipa` file through a secure channel (Slack, email link, etc.). Testers install with Apple Configurator 2, Finder, or a service like [installonair.com](https://www.installonair.com/). Their device UDIDs must be on the provisioning profile—see the [iOS Ad-hoc Distribution Checklist](IOS_ADHOC_CHECKLIST.md).
   - **TestFlight (recommended for no-UDID installs)**: Make sure the App Store Connect variables above are configured, run an `app-store` export, then invite testers from App Store Connect → **TestFlight**. They’ll get an email invite and can install through the TestFlight app with zero device registration.
2. If you stick with ad-hoc, ensure each tester’s device UDID is included in the provisioning profile before re-running the Codemagic build. Without it, iOS will block installation.

---

## 7. Troubleshooting Checklist
- **Build fails before archiving:** Double-check the base64 strings and password in the `ios_signing` group.
- **`IOS_CERT_BASE64: unbound variable` or similar:** Confirm the `ios_signing` group is attached to the workflow and that your certificate/profile variables use one of the accepted names (`IOS_*`, `CM_*`, or the legacy `CERTIFICATE_BASE64`/`PROVISIONING_PROFILE_BASE64`).
- **Archive succeeds but export fails:** Confirm the provisioning profile matches the export method (e.g., ad-hoc profiles for `ad-hoc`).
- **App crashes on launch:** Ensure the bundled `GoogleService-Info.plist` matches the `IOS_BUNDLE_ID` used in Firebase.
- **Friends can’t install the IPA:** Make sure their UDIDs are present in the provisioning profile or use TestFlight.

---

## 8. Automating Versioning (Optional)
To tag builds automatically, add the following script step before “Build archive”:
```yaml
- name: Bump build number
  script: |
    cd time_capsule_camera
    agvtool new-version -all $BUILD_NUMBER
```
Codemagic automatically exposes `BUILD_NUMBER` when you enable **Build versioning** in the workflow settings.

---

## 9. Next Steps
1. Pick the right distribution per build: ad-hoc for fast internal installs, or TestFlight for effortless external testing without UDIDs.
2. Reconfirm access when you add ad-hoc testers: add their UDIDs, re-download the provisioning profile, and update the base64 or secure-file copy in Codemagic so new devices (including new iPhone models) can keep installing successfully.
3. Monitor Firebase usage (Auth, Firestore, Storage) from the Firebase console.
4. Collect tester feedback and iterate on UI/UX updates.
5. When ready for public release, keep `IOS_EXPORT_METHOD` on `app-store`, fill out App Store metadata, and submit for review.
6. Document each release in `CHANGELOG.md` (create one if needed) to keep the team aligned.

Happy building! 🎉
