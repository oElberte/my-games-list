# Branding assets

**The artwork here is a PLACEHOLDER, not final brand art.** It's a simple
game-controller monogram on the brand gradient so the app no longer ships the
stock Flutter icon. Replace it with the real logo before release.

## Files

| File | Used for | Notes |
|------|----------|-------|
| `logo_source.svg` | Source of `icon.png` | Full badge, brand gradient |
| `icon_foreground_source.svg` | Source of `icon_foreground.png` | Android adaptive foreground (transparent, padded) |
| `splash_logo_source.svg` | Source of `splash_logo.png` | White glyph for the native splash |
| `icon.png` (1024²) | Launcher icon (Android/iOS/web) | |
| `icon_foreground.png` (1024²) | Android adaptive foreground | |
| `splash_logo.png` (1024²) | Native splash logo | |

## Replace the placeholder

1. Drop the final art over the three `*.png` files (keep the names and sizes:
   1024×1024, foreground with safe-zone padding, splash glyph centered).
   If you have SVGs, update the `*_source.svg` files and re-rasterize, e.g.
   `rsvg-convert -w 1024 -h 1024 logo_source.svg -o icon.png`.
2. Regenerate the platform assets:

   ```bash
   fvm dart run flutter_launcher_icons
   fvm dart run flutter_native_splash:create
   ```

3. Commit the regenerated files under `android/`, `ios/`, and `web/`.

Config for both tools lives in `pubspec.yaml`. Brand colors are defined in
`lib/core/theme/app_colors.dart`; the splash/manifest background is `#12141C`.
