import 'package:flutter/material.dart';

/// Brand palette for MyGamesList.
///
/// The brand leans on an electric indigo/violet accent over deep charcoal
/// surfaces — a confident, modern look for a game-library tracker rather than
/// the default Material blue. The dark surface mirrors the web manifest's
/// `#12141C` so the splash, web shell and in-app dark theme stay consistent.
abstract final class AppColors {
  const AppColors._();

  /// Primary brand seed. Drives the Material 3 [ColorScheme] for both themes.
  static const Color brandSeed = Color(0xFF7C4DFF);

  /// Secondary accent used for highlights (ratings, "anticipated" badges).
  static const Color brandAccent = Color(0xFF00E5C7);

  /// Deep charcoal background for the dark theme and native splash. Matches
  /// `web/manifest.json` background/theme color.
  static const Color darkBackground = Color(0xFF12141C);

  /// Slightly raised surface for cards/sheets in the dark theme.
  static const Color darkSurface = Color(0xFF1B1E2A);

  /// Warm off-white background for the light theme — softer than pure white.
  static const Color lightBackground = Color(0xFFF7F6FB);
}
