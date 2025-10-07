# Simple TestFlight Setup (No Mac Required)

Follow these exact steps to build the iOS app in Codemagic and deliver it to yourself and your friends through TestFlight.

## 1. Collect the Apple assets (only done once)

1. Sign in to [Apple Developer](https://developer.apple.com/account/resources/certificates/list).
2. Download your **Distribution certificate** (`.p12`).
3. Download your **App Store provisioning profile** (`.mobileprovision`) for `com.mkyoung.timecapsulecamera`.
4. Visit [App Store Connect → Users and Access → Keys](https://appstoreconnect.apple.com/access/api).
5. Create an API key named however you like, enable **App Store Connect API**, and download the `.p8` file.
6. Copy the **Issuer ID** and **Key ID** from the API key details page.

Keep these three files on your computer; you will encode them in the next section.

## 2. Let the repo gather the secrets for you

1. Install Python 3 if it is not already on your computer.
2. Open a terminal (Command Prompt, PowerShell, or macOS/Linux shell) and change into the cloned repository folder.
3. Run the interactive helper:

   ```bash
   python scripts/setup_codmagic.py
   ```

4. Answer the prompts:
   - Provide the paths to the `.p12`, `.mobileprovision`, and `.p8` files you downloaded in Step 1.
   - Enter the certificate password (if any), bundle ID, and team ID.
   - Choose `app-store` so Codemagic knows to upload to TestFlight.

5. When the script finishes you’ll have a `codemagic.env.local` file containing every variable Codemagic expects. Keep it safe—it holds signing secrets—and use it in the next step.

## 3. Configure the `ios_signing` group in Codemagic

1. In [Codemagic](https://codemagic.io), open your app → **Settings** → **Environment variables**.
2. Create or edit the `ios_signing` group and add the following variables (all as **Secure** values). Open `codemagic.env.local` side-by-side and copy the values directly:

   | Variable | Value |
   | --- | --- |
   | `IOS_CERT_BASE64` | Paste the certificate string from step 2. |
   | `IOS_PROFILE_BASE64` | Paste the provisioning profile string. |
   | `IOS_CERT_PASSWORD` | The password you used when exporting the `.p12` (leave blank if none). |
   | `IOS_EXPORT_METHOD` | `app-store` |
   | `APP_STORE_CONNECT_API_KEY_BASE64` | Paste the `.p8` base64 string (already in your `codemagic.env.local`). |
   | `APP_STORE_CONNECT_KEY_ID` | The Key ID from App Store Connect. |
   | `APP_STORE_CONNECT_ISSUER_ID` | The Issuer ID from App Store Connect. |
   | `IOS_BUNDLE_ID` | `com.mkyoung.timecapsulecamera` |
   | `APPLE_TEAM_ID` | `6XNH7D52V6` |

3. Press **Save**. Make sure the `ios_signing` group is attached to the `ios-build` workflow.

## 4. Run the Codemagic build

1. Go to the **Builds** tab and click **Start new build**.
2. Choose the `ios-build` workflow and the branch you want to ship (usually `main`).
3. Wait for the pipeline to finish (takes ~10 minutes). Codemagic will automatically upload the build to TestFlight when it succeeds.

## 5. Accept the build in App Store Connect

1. In [App Store Connect](https://appstoreconnect.apple.com), open **My Apps → Time Capsule Camera → TestFlight**.
2. Select the latest build, add the required compliance answers, and click **Submit for Review** (internal testers can skip review).
3. Once the build status shows **Ready to Test**, you will receive an email in the Apple ID inbox that owns the developer account.

## 6. Install on your device and invite friends

1. Install the **TestFlight** app from the App Store on your iPhone 14 Pro.
2. Open the invitation email, tap **View in TestFlight**, and install the build.
3. To add friends, go to **App Store Connect → Users and Access → TestFlight** and add them as testers (internal = up to 25 team members, external = up to 10,000 email addresses).
4. Friends will receive their own TestFlight invitations and can install the app without sharing UDIDs.

## 7. Rerun for future updates

Whenever you push new commits to GitHub, repeat **Step 4** to trigger a fresh Codemagic build. TestFlight will notify everyone automatically when a new version is available.

That’s it—no Mac required once the assets are in place.
