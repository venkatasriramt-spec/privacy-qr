# Privacy QR

A privacy-preserving mobile wallet application that generates single-use, service-bound, cryptographic QR credentials for students. Built as an Android-only Flutter app with Firebase backend security.

## Features
- **Cloud Authentication**: Firebase Email/Password login with Role-Based Access Control (Student, Security, Faculty, Admin).
- **Local Authentication**: Students unlock their credential wallet using native Biometrics (Fingerprint) or PIN.
- **Dynamic Privacy QR**: Generates short-lived (60s), single-use QR codes signed with HMAC-SHA256.
- **Selective Disclosure**: Reveals only the minimum data required based on the service context (Library, Lab, Gate, etc.).
- **Cryptographic Scanner**: Security personnel scan QR codes with real-time signature verification, expiry checks, and replay attack prevention via Firestore nonce tracking.
- **Firestore Security Rules**: Strict RBAC rules deployed to Firebase — students cannot escalate roles, and only authorized personnel can consume tokens.

## Tech Stack
- **Frontend**: Flutter (Dart) — Android only
- **Backend**: Firebase (Authentication, Cloud Firestore)
- **Cryptography**: `crypto` (HMAC-SHA256), `uuid`
- **QR Generation / Scanning**: `qr_flutter`, `mobile_scanner`
- **Auth**: `firebase_auth`, `local_auth`

## Architecture
```
CloudLoginScreen (Firebase Auth)
        │
        ▼
  RoleRouterScreen (reads Firestore role)
       / \
      /   \
Student    Security/Faculty/Admin
  │              │
  ▼              ▼
LoginScreen    ScannerScreen
(Biometrics)   (Camera + Crypto Verify)
  │
  ▼
PurposeScreen → ConsentScreen → QRDisplayScreen
```

## Getting Started
To run the app on an Android Emulator:

**Terminal 1** — Start the emulator (without Android Studio):
```powershell
& "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -avd <AVD_NAME> -memory 2048
```

**Terminal 2** — Run the app:
```powershell
flutter run
```

## Firebase Setup
This project requires a `google-services.json` file in `android/app/` (gitignored for security).
1. Go to the [Firebase Console](https://console.firebase.google.com/project/privacy-qr-b9813).
2. Download `google-services.json` for the Android app.
3. Place it in `android/app/`.

## Project History
For a detailed log of development phases, bugs, and architecture decisions, see [project_history.md](project_history.md).
