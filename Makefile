.PHONY: help setup-staging setup-production run-staging run-production \
        build-android-staging build-android-production-apk build-android-production-aab \
        build-ios-staging build-ios-production build-web-staging build-web-production \
        test analyze l10n

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-35s\033[0m %s\n", $$1, $$2}'

# ─── Environment Setup ────────────────────────────────────────────────────────

setup-staging: ## Copy staging Firebase config to native paths
	@if [ ! -f firebase/staging/google-services.json ]; then \
		echo "❌ firebase/staging/google-services.json not found."; \
		echo "   Run flutterfire configure for staging first. See FIREBASE_SETUP.md."; \
		exit 1; \
	fi
	@if [ ! -f firebase/staging/GoogleService-Info.plist ]; then \
		echo "❌ firebase/staging/GoogleService-Info.plist not found."; \
		echo "   Run flutterfire configure for staging first. See FIREBASE_SETUP.md."; \
		exit 1; \
	fi
	cp firebase/staging/google-services.json android/app/google-services.json
	cp firebase/staging/GoogleService-Info.plist ios/Runner/GoogleService-Info.plist
	$(eval REVERSED_ID := $(shell /usr/libexec/PlistBuddy -c "Print :REVERSED_CLIENT_ID" firebase/staging/GoogleService-Info.plist))
	@/usr/libexec/PlistBuddy -c "Set :CFBundleURLTypes:0:CFBundleURLSchemes:0 $(REVERSED_ID)" ios/Runner/Info.plist
	cp firebase/staging/firebase.json firebase.json
	@echo "✅ Staging Firebase config applied."

setup-production: ## Copy production Firebase config to native paths
	@if [ ! -f firebase/production/google-services.json ]; then \
		echo "❌ firebase/production/google-services.json not found."; \
		echo "   Run flutterfire configure for production first. See FIREBASE_SETUP.md."; \
		exit 1; \
	fi
	@if [ ! -f firebase/production/GoogleService-Info.plist ]; then \
		echo "❌ firebase/production/GoogleService-Info.plist not found."; \
		echo "   Run flutterfire configure for production first. See FIREBASE_SETUP.md."; \
		exit 1; \
	fi
	cp firebase/production/google-services.json android/app/google-services.json
	cp firebase/production/GoogleService-Info.plist ios/Runner/GoogleService-Info.plist
	$(eval REVERSED_ID := $(shell /usr/libexec/PlistBuddy -c "Print :REVERSED_CLIENT_ID" firebase/production/GoogleService-Info.plist))
	@/usr/libexec/PlistBuddy -c "Set :CFBundleURLTypes:0:CFBundleURLSchemes:0 $(REVERSED_ID)" ios/Runner/Info.plist
	cp firebase/production/firebase.json firebase.json
	@echo "✅ Production Firebase config applied."

# ─── Run ──────────────────────────────────────────────────────────────────────

run-staging: setup-staging ## Run app with staging config
	fvm flutter run --flavor staging --dart-define-from-file=.env

run-production: setup-production ## Run app with production config
	fvm flutter run --flavor prod --dart-define-from-file=.env.production

# ─── Build: Android ───────────────────────────────────────────────────────────

build-android-staging: setup-staging ## Build Android APK (staging)
	fvm flutter build apk --flavor staging --dart-define-from-file=.env

build-android-production-apk: setup-production ## Build Android APK (production)
	fvm flutter build apk --flavor prod --dart-define-from-file=.env.production

build-android-production-aab: setup-production ## Build Android App Bundle for Play Store (production)
	fvm flutter build appbundle --flavor prod --dart-define-from-file=.env.production

# ─── Build: iOS ───────────────────────────────────────────────────────────────

build-ios-staging: setup-staging ## Build iOS (staging)
	fvm flutter build ios --dart-define-from-file=.env

build-ios-production: setup-production ## Build iOS (production)
	fvm flutter build ios --dart-define-from-file=.env.production

# ─── Build: Web ───────────────────────────────────────────────────────────────

build-web-staging: ## Build web (staging)
	fvm flutter build web --no-web-resources-cdn --dart-define-from-file=.env

build-web-production: ## Build web (production)
	fvm flutter build web --no-web-resources-cdn --dart-define-from-file=.env.production

# ─── Development ──────────────────────────────────────────────────────────────

test: ## Run all tests
	fvm flutter test

analyze: ## Run Flutter analyzer
	fvm flutter analyze

l10n: ## Generate localization files
	fvm flutter gen-l10n