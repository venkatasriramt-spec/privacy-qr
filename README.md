# Privacy QR

A privacy-preserving mobile wallet application that generates single-use, service-bound, cryptographic QR credentials for students. 

## Features
- **Local Authentication**: Unlocks the credential wallet using native Biometrics (Face ID/Fingerprint) or PIN.
- **Dynamic Privacy QR**: Generates short-lived (60s), single-use QR codes.
- **Selective Disclosure**: Reveals only the minimum data required based on the service context (Library, Lab, Gate, etc.).
- **Firebase Backend (Upcoming)**: Token verification, single-use consumption, and audit logging.

## Tech Stack
- **Frontend**: Flutter (Dart)
- **Authentication**: `local_auth` for Biometrics
- **Cryptography**: `crypto` (HMAC-SHA256), `uuid`
- **QR Generation**: `qr_flutter`

## Getting Started
To run the app on an Android Emulator:
```bash
flutter run
```

For a detailed log of development phases, bugs, and architecture decisions, see [project_history.md](project_history.md).
