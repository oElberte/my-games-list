# Firebase Setup Guide

This document describes the manual steps required to configure Firebase for both staging and production environments.

## 1. Create Firebase Projects

In the [Firebase Console](https://console.firebase.google.com/), create two projects:

- `mygameslist-staging` — for development and testing
- `mygameslist-production` — for production releases

For each project, enable the following services:

- **Authentication** — enable Google and Apple sign-in providers
- **Analytics** — enable Google Analytics
- **Crashlytics** — enable crash reporting
- **Cloud Messaging (FCM)** — enable push notifications

## 2. Install the FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

Make sure `~/.pub-cache/bin` is on your `PATH`.

## 3. Configure Staging

Run flutterfire configure for the staging project and output the Dart options file:

```bash
flutterfire configure \
  --project=mygameslist-staging \
  --out=lib/firebase_options_staging.dart
```

This will also generate the native config files. Copy them to the firebase/staging/ directory:

```bash
cp android/app/google-services.json firebase/staging/google-services.json
cp ios/Runner/GoogleService-Info.plist firebase/staging/GoogleService-Info.plist
```

## 4. Configure Production

Run flutterfire configure for the production project and output the Dart options file:

```bash
flutterfire configure \
  --project=mygameslist-production \
  --out=lib/firebase_options_production.dart
```

Copy the native config files to the firebase/production/ directory:

```bash
cp android/app/google-services.json firebase/production/google-services.json
cp ios/Runner/GoogleService-Info.plist firebase/production/GoogleService-Info.plist
```

⚠️ **Important:** After completing both configure runs, your native config files (`android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`) now point to production. Run `make setup-staging` (or manually copy the staging files back) before doing local development to avoid using the production Firebase project.

## 5. iOS — Add REVERSED_CLIENT_ID URL Scheme

For Google Sign-In on iOS, you must add the `REVERSED_CLIENT_ID` URL scheme to `ios/Runner/Info.plist`. Find the value in `firebase/staging/GoogleService-Info.plist` (or production) under the key `REVERSED_CLIENT_ID`, then add:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string><!-- REVERSED_CLIENT_ID value here --></string>
    </array>
  </dict>
</array>
```

## 6. Using the Makefile

The `Makefile` at the root of `app/` manages copying the correct native config files based on the target environment. See the `app/Makefile` for `setup-staging`, `run-staging`, `run-production`, `build-staging`, and `build-production` targets.

## 7. Go Backend — Service Account

The Go API uses a Firebase Admin SDK service account for token verification. Download the service account JSON from the Firebase Console:

- **Project Settings → Service Accounts → Generate new private key**

Store the path in `api/.env`:

```
FIREBASE_SERVICE_ACCOUNT_PATH=/path/to/service-account.json
```

See `api/.env.example` for the full list of required keys.
