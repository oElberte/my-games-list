# R8 keep rules for release builds.
#
# Flutter and the Firebase SDKs ship consumer ProGuard rules through their
# AARs, so this file only adds what the app-level shrinker still needs to keep
# release builds working and crash reports readable.

# --- Flutter embedding -------------------------------------------------------
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# --- Crashlytics -------------------------------------------------------------
# Keep source file names and line numbers so deobfuscated stack traces stay
# readable; rename the source-file attribute to hide the original names.
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
-keep class com.google.firebase.crashlytics.** { *; }
-dontwarn com.google.firebase.crashlytics.**

# --- flutter_local_notifications --------------------------------------------
# The plugin deserializes notification details via Gson and relies on generic
# signatures that R8 would otherwise strip.
-keep class com.dexterous.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# --- Play Core (deferred components / split installs) ------------------------
# Flutter references these symbols even when split installs are unused.
-dontwarn com.google.android.play.core.**
