# Privacy QR — Project History & Development Timeline
This document records the chronological development of Privacy QR, including all major decisions, changes, bug fixes, and architectural pivots made during the project.

## Phase 1: Core App UI & Authentication
### 2026-09-24 — Project Inception & UI Setup
- Created initial Flutter project structure (`privacy_qr`).
- Initialized Git repository, ignored Firebase secrets (`google-services.json`, `GoogleService-Info.plist`), and pushed to `https://github.com/venkatasriramt-spec/privacy-qr`.
- Added dependencies: `firebase_core`, `firebase_auth`, `cloud_firestore`, `qr_flutter`, `mobile_scanner`, `local_auth`, `crypto`, `uuid`, `google_fonts`.
- Designed `lib/main.dart` with a premium dark mode, glassmorphic UI using `GoogleFonts.outfitTextTheme`.
- Built `lib/screens/login_screen.dart` with Biometric/PIN unlock via `local_auth`.
- Built `lib/screens/purpose_screen.dart` to allow users to select their access context (Library, Gate, Lab, etc.).
- Built `lib/screens/consent_screen.dart` to show mandatory disclosures before generating the QR.
- Built `lib/screens/qr_display_screen.dart` to generate a secure, 60-second time-bound token (UUID, nonce, exp, iat, claims) signed with HMAC-SHA256, encoded as a QR code.

### 2026-09-30 — Native Android Fixes
- **Bug Fix**: `LocalAuthException(code uiUnavailable)`.
  - Root Cause: Android requires `FlutterFragmentActivity` instead of `FlutterActivity` to display biometric prompts.
  - Fix: Updated `android/app/src/main/kotlin/com/example/privacy_qr/MainActivity.kt`.
- **Feature**: Added `USE_BIOMETRIC`, `USE_FINGERPRINT`, and `CAMERA` permissions to `android/app/src/main/AndroidManifest.xml`.
- **Bug Fix**: Updated deprecated `.withOpacity()` to `.withValues(alpha: ...)` across all Dart screens.
