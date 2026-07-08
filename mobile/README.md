# Rokkhakoboch — Mobile (Flutter)

Bangla scam detection app for Android (iOS project included; SMS auto-scan is Android-only).

## Features

| Module | Screen | Notes |
|--------|--------|-------|
| 1 — SMS Sentinel | `ScanScreen` | Paste SMS; optional auto-scan (Settings) |
| 2 — Call Transcript | `ScanScreen` (call mode) | Multiline input + example hints |
| 3 — URL Guard | `UrlCheckScreen` | URL keyboard, risk score on result |
| 4 — QR / Payment | `QrScanScreen` | Camera scan → `/api/qr-check` combined verdict |
| 6 — Media (experimental) | `DeepfakeScreen` | Client-side ELA only |
| 7 — Device Protection | `DeviceProtectionScreen` | BD checklist + `permission_handler` status |
| 10 — Threat Intel | `FeedScreen`, `ThreatMapScreen` | Division labels, auto-loading map |

## Setup

```bash
cd mobile
flutter pub get
flutter analyze
```

## Build APK

```bash
# Release (distribution)
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk

# Debug (testing)
flutter build apk --debug
# → build/app/outputs/flutter-apk/app-debug.apk
```

## API configuration

Production backend URL is set in `lib/core/api/api_config.dart`. Default points to Railway production API.

For local development, change `ApiConfig.baseUrl` to `http://10.0.2.2:8000/api` (Android emulator) or your machine's LAN IP.

## Firebase (Android push)

1. Create Firebase project → add Android app
2. Download `google-services.json`
3. Place at `android/app/google-services.json` (gitignored — do not commit)

## Permissions (Android)

- **Camera** — QR scanning (Module 4)
- **SMS** — optional auto-scan (Module 1); finance-keyword filter only
- **Notifications** — Firebase + local alerts for high-risk SMS

## Tests

```bash
flutter test
```

Includes SMS filter unit tests (`test/mfs_sms_filter_test.dart`).

## Key packages

- `mobile_scanner` — QR camera
- `flutter_map` + `latlong2` — threat map (OpenStreetMap)
- `permission_handler` — device protection checklist
- `firebase_messaging` — push notifications
- `http` — API client
