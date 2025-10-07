# Exporting Apple Signing Assets on Windows

Follow these steps to gather the signing files Codemagic needs when you do not have access to a Mac.

---

## 1. Install the required tools

You need a shell with OpenSSL and Python 3. The easiest options are:

- **Git for Windows** – includes a "Git Bash" terminal with OpenSSL preinstalled. Download from [git-scm.com](https://git-scm.com/download/win) and install with the default settings.
- **Chocolatey** – if you prefer PowerShell, install [Chocolatey](https://chocolatey.org/install) and then run `choco install openssl-light python` to add OpenSSL and Python globally.

All commands below assume you are running either Git Bash or PowerShell from the folder where you want to store the signing files.

> 💡 If you already created a certificate on another machine, you can skip to [Step 4](#4-convert-the-certificate-to-p12) after downloading the existing `.cer` file from developer.apple.com.

---

## 2. Generate a certificate signing request (CSR)

Apple requires a CSR to create a distribution certificate. Run the following commands in Git Bash or PowerShell (replace the email and name values with your own):

```bash
openssl genrsa -out ios_distribution.key 2048
openssl req -new -key ios_distribution.key -out ios_distribution.csr \
  -subj "/emailAddress=mky014@aol.com, CN=Michael Young, C=US"
```

- `ios_distribution.key` is your private key. Keep it safe and never commit it to Git.
- `ios_distribution.csr` is the file you upload to Apple.

---

## 3. Create or retrieve the Apple Distribution certificate

1. Sign in to the [Apple Developer Certificates page](https://developer.apple.com/account/resources/certificates/list).
2. Click the **+** button and choose **Apple Distribution**.
3. When prompted, upload the `ios_distribution.csr` you generated in the previous step.
4. After Apple issues the certificate, download the resulting `.cer` file (for example `ios_distribution.cer`).

> 🔁 **Already have a distribution certificate?** Download the existing `.cer` file and make sure you still have the matching
> private key (`.key`) that was created with the original CSR. If you no longer have that key (for example, it lived on a Mac
> you cannot access), revoke the old certificate and create a new one using the CSR you generated in Step&nbsp;2.

Store the `.cer` file in the same folder as your key.

---

## 4. Convert the certificate to `.p12`

Codemagic expects a password-protected `.p12`. Use OpenSSL to convert the `.cer` file you downloaded:

```bash
openssl x509 -in ios_distribution.cer -inform DER -out ios_distribution.pem -outform PEM
openssl pkcs12 -export -inkey ios_distribution.key -in ios_distribution.pem \
  -out ios_distribution.p12
```

During the second command you will be asked for an export password. Remember this password—it becomes the value for `IOS_CERT_PASSWORD` in Codemagic.

You now have `ios_distribution.p12`, which is the certificate you will encode later.

---

## 5. Download the provisioning profile

1. Visit the [Profiles page](https://developer.apple.com/account/resources/profiles/list) in the Apple Developer portal.
2. Click the profile you already created for `com.mkyoung.timecapsulecamera` (or press **+** to create a new one).
3. Make sure the profile type matches the way you plan to export the build:
   - **App Store** for TestFlight/App Store uploads.
   - **Ad Hoc** if you want a UDID-based IPA.
4. Select the distribution certificate from Step 3 and include all required devices (for ad-hoc profiles).
5. Click **Download** to get the `.mobileprovision` file and save it next to your certificate.

---

## 6. Convert both files to Base64

From the root of the repository (or wherever the files live), run the helper script that already ships with the project:

```bash
python scripts/encode_base64.py ios_distribution.p12 --env-var IOS_CERT_BASE64
python scripts/encode_base64.py TimeCapsuleCamera_Profile.mobileprovision --env-var IOS_PROFILE_BASE64
```

Each command prints a single line you can copy directly into Codemagic’s `ios_signing` group. If you prefer PowerShell’s built-in tools, you can use:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("ios_distribution.p12"))
```

Repeat for the `.mobileprovision` file and paste the output into the appropriate variables.

---

## 7. Verify the environment locally

Before touching Codemagic, save the Base64 strings and password in a local env file so you can validate everything:

```bash
cp codemagic.env.example codemagic.env.local
```

Edit `codemagic.env.local` and paste the values next to the matching variable names. When the file is ready, load and test it:

```bash
set -a
source codemagic.env.local
set +a
python scripts/check_codmagic_env.py
```

The checker prints a ✅ message when all required variables are present (distribution certificate, password, provisioning profile, and App Store Connect key metadata).

## 8. Update Codemagic

1. Open Codemagic → **App settings → Environment variables**.
2. Edit the `ios_signing` group and paste the Base64 strings:
   - `IOS_CERT_BASE64` → output from the first command in Step&nbsp;6.
   - `IOS_CERT_PASSWORD` → password you set while exporting the `.p12`.
   - `IOS_PROFILE_BASE64` → output from the second command in Step&nbsp;6.
   - Keep the App Store Connect values you already configured (`APPSTORECONNECT_*`).
3. Save the group and re-run the `ios-build` workflow.

Once the build succeeds, Codemagic will sign and (optionally) upload your TestFlight build automatically.

---

## 8. Keep your files safe

- The `.key`, `.p12`, and `.mobileprovision` files are sensitive. Store them in an encrypted location (for example, BitLocker, 1Password, or another secure vault).
- Never commit these files to GitHub. Only the Base64 strings belong in Codemagic’s secure variables.

With the certificate and provisioning profile encoded, you are ready to run the project’s Codemagic/TestFlight pipeline from Windows. Use the Codemagic dashboard to confirm the `ios_signing` group is attached to the workflow, then start a fresh build.
