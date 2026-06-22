plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

android {
    namespace = "com.elberte.mygameslist"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.elberte.mygameslist"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Fallback name for flavorless builds (e.g. `flutter run` without
        // `--flavor`); each flavor overrides this below.
        resValue("string", "app_name", "My Games List")
    }

    flavorDimensions += "env"
    productFlavors {
        // Staging gets a distinct application id so it can be installed
        // side-by-side with production and mapped to the staging Firebase
        // project. The Dart environment is still selected via
        // `--dart-define=ENVIRONMENT=staging`; flavors only shape the Android
        // artifact (app id + name), they don't replace the dart-define flow.
        create("staging") {
            dimension = "env"
            applicationIdSuffix = ".staging"
            resValue("string", "app_name", "My Games List (Staging)")
        }
        create("prod") {
            dimension = "env"
            // No suffix: production keeps the base application id that the
            // production Firebase project / google-services.json is keyed to.
            resValue("string", "app_name", "My Games List")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build (#14).
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            // R8 is enabled by default for Flutter release builds; declaring it
            // explicitly documents intent and wires the custom keep rules that
            // stop the shrinker from stripping Firebase/Flutter symbols.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
