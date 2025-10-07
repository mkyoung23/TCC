# Codemagic Zero-Mac Checklist

Follow this short checklist whenever you need a fresh build that installs on your iPhone or ships to friends without touching Xcode.

## 1. Collect Apple assets
1. Sign in to [Apple Developer → Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/).
2. Download the **distribution certificate** (`.p12`) and note the password you set when exporting it.
3. Download the **provisioning profile** that matches your app ID (`com.mkyoung.timecapsulecamera`).
   * For personal installs, include your iPhone 14 Pro UDID.
   * For friends, either add their UDIDs and regenerate the profile or plan to use TestFlight instead.
4. (Optional, for TestFlight) Visit [App Store Connect → Users and Access → Keys](https://appstoreconnect.apple.com/access/users) and create/download an **App Store Connect API key** (`.p8`).

## 2. Encode everything with the helper
1. Run `python scripts/setup_codmagic.py`.
2. Answer the prompts with the file paths you downloaded in step 1.
3. Choose the export method:
   * `ad-hoc` for UDID-based installs.
   * `app-store` for automatic TestFlight uploads.
4. When the wizard finishes, it writes `codemagic.env.local` (or your chosen file) containing every required secret.

## 3. Verify before uploading
1. Source the file locally: `source codemagic.env.local`.
2. Run `python scripts/check_codmagic_env.py`.
3. Confirm it ends with `✅ All required Codemagic signing secrets are present.`
   * If any values are missing, edit the env file and rerun the checker.

## 4. Mirror values in Codemagic
1. In Codemagic, open **Application settings → Environment variables**.
2. Create (or open) the `ios_signing` variable group.
3. Copy each key/value from `codemagic.env.local`.
   * Mark secret values (certificate/profile/API key) as **Secure**.
4. Save the group and ensure it’s attached to the `ios-build` workflow.

## 5. Trigger and monitor the build
1. Start the `ios-build` workflow.
2. Wait for the “Decode signing assets” step to succeed—if it fails, the missing variable is listed in the log.
3. Once the workflow finishes:
   * For ad-hoc, download the IPA from **Artifacts** and install it via Finder, Apple Configurator, or a trusted OTA service.
   * For TestFlight, watch App Store Connect for the new build and move it to **TestFlight → Internal Testing** (or External) once processing completes.

## 6. Share with friends
* **Ad-hoc:** Everyone installing must have their UDID baked into the provisioning profile you used in step 1. Update the profile and rebuild when the tester list changes.
* **TestFlight:** Invite testers from App Store Connect → TestFlight. They’ll receive an email and install through the TestFlight app—no UDIDs required.

## 7. Repeat for updates
Whenever you push new code:
1. Rerun `python scripts/setup_codmagic.py` only if your signing assets changed.
2. Kick off another `ios-build` run in Codemagic.
3. Distribute the fresh IPA/TestFlight build.

That’s it—you can manage signing assets, build in Codemagic, and deliver updates without owning a Mac.
