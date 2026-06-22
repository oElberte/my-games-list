# Release Signing Guide

How to sign Android release artifacts with a real upload key instead of the
debug key. Secrets stay out of the repo — they're supplied locally via
`android/key.properties` and a keystore, and via CI secrets in pipelines.

> If `android/key.properties` is **absent** (fresh checkout, CI without
> secrets), the release build falls back to debug signing so local
> `flutter build` / `flutter run --release` keep working. A real, Play-ready
> release requires the keystore below.

## 1. Generate the upload keystore

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
        -storetype JKS -keysize 2048 -validity 10000 -alias upload
```

Keep this file private. It is gitignored (`*.jks`, `**/upload-keystore.jks`),
so it must never be committed. Losing it means you can't push updates under the
same upload identity, so back it up securely.

## 2. Create `android/key.properties`

Copy the template and fill in real values:

```bash
cp android/key.properties.example android/key.properties
```

```properties
storePassword=<keystore password>
keyPassword=<key password>
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

`storeFile` may be absolute or relative to the `android/` directory.
`android/key.properties` is gitignored — never commit it.

## 3. How Gradle uses it

`android/app/build.gradle.kts` loads `android/key.properties` (when present),
defines a `release` signingConfig from it, and points `buildTypes.release` at
that config. When the file is missing it keeps debug signing as a documented
fallback — no hard failure.

Build a signed bundle (see the `Makefile`):

```bash
make build-android-production-aab   # flutter build appbundle --flavor prod ...
```

## 4. Play App Signing

The recommended Play Store flow uses **Play App Signing**:

- **Google holds the app signing key** (the final key end users verify).
- **You hold the upload key** (the keystore above) and sign every upload with
  it. Play re-signs with the app signing key before distribution.

So the keystore here is the *upload* key. If it's ever compromised or lost, you
can request a new upload key from the Play Console without disrupting users.

## 5. CI signing (secrets, not committed)

Inject the keystore and credentials as CI secrets — never as files in the repo.
Base64-encode the keystore so it travels as a single secret:

```bash
base64 -w0 ~/upload-keystore.jks   # store as ANDROID_KEYSTORE_BASE64
```

In the pipeline, decode it and write `android/key.properties` from secrets
before building:

```bash
echo "$ANDROID_KEYSTORE_BASE64" | base64 -d > android/app/upload-keystore.jks
cat > android/key.properties <<EOF
storePassword=$ANDROID_KEYSTORE_PASSWORD
keyPassword=$ANDROID_KEY_PASSWORD
keyAlias=$ANDROID_KEY_ALIAS
storeFile=upload-keystore.jks
EOF
```

Required CI secrets: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`,
`ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`.

## iOS distribution signing

Out of scope for this change (Android only). iOS distribution signing
(certificates + provisioning profiles, ideally via Xcode automatic signing or
`fastlane match`) is tracked separately.
