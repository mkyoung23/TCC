# Time Capsule Camera (Skeleton)

This directory contains a SwiftUI skeleton for the **Time Capsule Camera** app.  It demonstrates the core architecture described in the attached report, including:

- Firebase integration (Authentication, Firestore, Storage).
- Capsule creation, listing and detail pages.
- Countdown timer until a capsule unseals.
- Video uploading via `PHPickerViewController`.
- Playback using `AVQueuePlayer` with overlay showing uploader name and date.

## Structure

- `TimeCapsuleCameraApp.swift` – entry point to configure Firebase and switch between authentication and main app.
- `ViewModels/` – contains `AuthViewModel` for authentication state.
- `Services/` – `FirebaseManager` centralizes Firebase references.
- `Models/` – `Capsule` and `Clip` models for Firestore documents.
- `Views/` – SwiftUI views for authentication, capsule list/detail, countdown timer and video picker.

## Next Steps

- Implement **Cloud Functions** to automatically unseal capsules when their `sealDate` passes.
- Add error handling, progress UI for uploads and downloads.
- Integrate dynamic links or invitation codes for capsule invitations.
- Add a Favorites feature and push notifications.

This skeleton is meant as a starting point; refer to the report for detailed guidance.
