/// Utility functions for handling IGDB image URLs.
///
/// IGDB returns image URLs with low-resolution size identifiers (e.g., `t_thumb`).
/// These utilities help transform them to higher resolution versions.
library;

/// Transforms an IGDB image URL to use a higher resolution size.
///
/// IGDB image size options:
/// - `t_thumb` - 90x128 (default from API)
/// - `t_cover_small` - 90x128
/// - `t_cover_big` - 264x374 (recommended for covers)
/// - `t_screenshot_med` - 569x320 (recommended for screenshots)
/// - `t_720p` - 1280x720
/// - `t_1080p` - 1920x1080
///
/// Example:
/// ```dart
/// final highResUrl = getHighResUrl(
///   '//images.igdb.com/igdb/image/upload/t_thumb/co9rwo.jpg',
///   't_cover_big',
/// );
/// // Returns: 'https://images.igdb.com/igdb/image/upload/t_cover_big/co9rwo.jpg'
/// ```
String getHighResUrl(String url, String size) {
  if (url.isEmpty) return url;

  // 1. Ensure protocol: Add 'https:' if missing
  var result = url;
  if (result.startsWith('//')) {
    result = 'https:$result';
  }

  // 2. Replace resolution identifier
  const sizeIdentifiers = [
    't_thumb',
    't_cover_small',
    't_cover_big',
    't_screenshot_med',
    't_720p',
    't_1080p',
  ];

  for (final identifier in sizeIdentifiers) {
    if (result.contains(identifier)) {
      return result.replaceFirst(identifier, size);
    }
  }

  return result;
}

/// Common image size constants for convenience.
abstract class ImageSize {
  /// 90x128 - Thumbnail size
  static const String thumb = 't_thumb';

  /// 90x128 - Small cover
  static const String coverSmall = 't_cover_small';

  /// 264x374 - Large cover (recommended for cover images)
  static const String coverBig = 't_cover_big';

  /// 569x320 - Medium screenshot (recommended for screenshots)
  static const String screenshotMed = 't_screenshot_med';

  /// 1280x720 - 720p resolution
  static const String hd720 = 't_720p';

  /// 1920x1080 - 1080p resolution
  static const String hd1080 = 't_1080p';
}
