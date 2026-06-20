# Firebase Setup Guide

This document describes the manual steps required to configure Firebase for both staging and production environments.

## 1. Create Firebase Projects

In the [Firebase Console](https://console.firebase.google.com/), create two projects:

- `mygameslist-staging` — for development and testing
- `mygameslist-production` — for production releases

For each project, enable the following services:

- **Authentication** — enable Google sign-in provider
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

## 5. iOS — REVERSED_CLIENT_ID URL Scheme

The `ios/Runner/Info.plist` file includes a `CFBundleURLTypes` entry required for Google Sign-In on iOS. The `REVERSED_CLIENT_ID` value is automatically updated by the Makefile when you run `make setup-staging` or `make setup-production`, so no manual editing is needed.

## 6. Using the Makefile

The `Makefile` at the root of `app/` manages copying the correct native config files based on the target environment. See the `app/Makefile` for `setup-staging`, `run-staging`, `run-production`, `build-staging`, and `build-production` targets.

## 7. Go Backend — Service Account

The Go API uses a Firebase Admin SDK service account for token verification.

**Download service account JSON files** from the Firebase Console for each project:

- **Project Settings → Service Accounts → Generate new private key**

Store them in the `api/firebase/` directory (already gitignored via `*service-account*.json`):

```
api/firebase/
  staging-service-account.json     ← from mygameslist-staging project
  production-service-account.json  ← from mygameslist-production project
```

The API supports environment switching via Makefile targets (mirrors the Flutter app):

```bash
make dev-staging     # or: make dev  — uses api/.env (staging Firebase)
make dev-production                  # uses api/.env.production (production Firebase)
```

Both `.env` and `.env.production` are gitignored. `.env` already has staging Firebase vars configured. `.env.production` has production Firebase vars configured — update `JWT_SECRET` and database credentials as needed for your production setup.

For deployed environments (CI/CD, Docker, cloud), set env vars directly — no `.env` file needed:

```
FIREBASE_PROJECT_ID=mygameslist-production
FIREBASE_SERVICE_ACCOUNT_PATH=/secrets/production-service-account.json
```

> **Note:** If `FIREBASE_PROJECT_ID` is left empty, the API starts normally but social sign-in (`POST /auth/social`) will return an error. This is useful for running locally without Firebase.
