import 'package:flutter/material.dart';

/// IGDB website category constants.
///
/// These values are defined by the IGDB API.
/// See: https://api-docs.igdb.com/#website
abstract class WebsiteCategory {
  static const int official = 1;
  static const int wikia = 2;
  static const int wikipedia = 3;
  static const int facebook = 4;
  static const int twitter = 5;
  static const int twitch = 6;
  static const int instagram = 8;
  static const int youtube = 9;
  static const int iphone = 10;
  static const int ipad = 11;
  static const int android = 12;
  static const int steam = 13;
  static const int reddit = 14;
  static const int itch = 15;
  static const int epicGames = 16;
  static const int gog = 17;
  static const int discord = 18;
  static const int playstation = 19;
  static const int bsky = 20;
}

/// Map of website category IDs to their display names.
const Map<int, String> _websiteNames = {
  1: 'Official',
  2: 'Wikia',
  3: 'Wikipedia',
  4: 'Facebook',
  5: 'Twitter (X)',
  6: 'Twitch',
  8: 'Instagram',
  9: 'YouTube',
  10: 'App Store',
  11: 'App Store (iPad)',
  12: 'Google Play',
  13: 'Steam',
  14: 'Reddit',
  15: 'Itch.io',
  16: 'Epic Games',
  17: 'GOG',
  18: 'Discord',
  19: 'PlayStation Store',
  20: 'Bluesky',
};

/// Map of website category IDs to their icons.
const Map<int, IconData> _websiteIcons = {
  1: Icons.language, // Official
  2: Icons.menu_book, // Wikia
  3: Icons.menu_book, // Wikipedia
  4: Icons.facebook, // Facebook
  5: Icons.close, // Twitter (X)
  6: Icons.live_tv, // Twitch
  8: Icons.camera_alt, // Instagram
  9: Icons.play_circle_fill, // YouTube
  10: Icons.apple, // iPhone
  11: Icons.apple, // iPad
  12: Icons.android, // Android
  13: Icons.games, // Steam
  14: Icons.forum, // Reddit
  15: Icons.storefront, // Itch.io
  16: Icons.sports_esports, // Epic Games
  17: Icons.shopping_bag, // GOG
  18: Icons.chat_bubble, // Discord
  19: Icons.games, // PlayStation Store
  20: Icons.alternate_email, // Bluesky
};

/// Returns an appropriate icon for the given website category.
///
/// If category is 0 or unknown, falls back to URL-based detection.
/// Falls back to a generic link icon for unknown categories.
IconData getWebsiteIcon(int category, [String? url]) {
  // Try category-based lookup first
  if (_websiteIcons.containsKey(category)) {
    return _websiteIcons[category]!;
  }

  // Fallback: detect from URL if category is 0 or unknown
  if (url != null) {
    final detectedCategory = _detectCategoryFromUrl(url);
    if (detectedCategory != null) {
      return _websiteIcons[detectedCategory] ?? Icons.link;
    }
  }

  return Icons.link;
}

/// Returns a human-readable name for the given website category.
///
/// If category is 0 or unknown, falls back to URL-based detection.
/// Falls back to "Website" for unknown categories.
String getWebsiteName(int category, [String? url]) {
  // Try category-based lookup first
  if (_websiteNames.containsKey(category)) {
    return _websiteNames[category]!;
  }

  // Fallback: detect from URL if category is 0 or unknown
  if (url != null) {
    final detectedName = _detectNameFromUrl(url);
    if (detectedName != null) {
      return detectedName;
    }
  }

  return 'Website';
}

/// Detects website category from URL string.
int? _detectCategoryFromUrl(String url) {
  final lowerUrl = url.toLowerCase();

  if (lowerUrl.contains('steampowered') || lowerUrl.contains('store.steam')) {
    return WebsiteCategory.steam;
  }
  if (lowerUrl.contains('epicgames')) return WebsiteCategory.epicGames;
  if (lowerUrl.contains('gog.com')) return WebsiteCategory.gog;
  if (lowerUrl.contains('facebook')) return WebsiteCategory.facebook;
  if (lowerUrl.contains('twitter') || lowerUrl.contains('x.com')) {
    return WebsiteCategory.twitter;
  }
  if (lowerUrl.contains('instagram')) return WebsiteCategory.instagram;
  if (lowerUrl.contains('youtube')) return WebsiteCategory.youtube;
  if (lowerUrl.contains('twitch')) return WebsiteCategory.twitch;
  if (lowerUrl.contains('discord')) return WebsiteCategory.discord;
  if (lowerUrl.contains('reddit')) return WebsiteCategory.reddit;
  if (lowerUrl.contains('wikipedia')) return WebsiteCategory.wikipedia;
  if (lowerUrl.contains('fandom') || lowerUrl.contains('wikia')) {
    return WebsiteCategory.wikia;
  }
  if (lowerUrl.contains('itch.io')) return WebsiteCategory.itch;
  if (lowerUrl.contains('play.google')) return WebsiteCategory.android;
  if (lowerUrl.contains('apps.apple')) return WebsiteCategory.iphone;
  if (lowerUrl.contains('store.playstation'))
    return WebsiteCategory.playstation;
  if (lowerUrl.contains('bsky.app')) return WebsiteCategory.bsky;

  return null;
}

/// Detects website name from URL string.
String? _detectNameFromUrl(String url) {
  final lowerUrl = url.toLowerCase();

  if (lowerUrl.contains('steampowered') || lowerUrl.contains('store.steam')) {
    return 'Steam';
  }
  if (lowerUrl.contains('epicgames')) return 'Epic Games';
  if (lowerUrl.contains('gog.com')) return 'GOG';
  if (lowerUrl.contains('facebook')) return 'Facebook';
  if (lowerUrl.contains('twitter') || lowerUrl.contains('x.com')) {
    return 'Twitter (X)';
  }
  if (lowerUrl.contains('instagram')) return 'Instagram';
  if (lowerUrl.contains('youtube')) return 'YouTube';
  if (lowerUrl.contains('twitch')) return 'Twitch';
  if (lowerUrl.contains('discord')) return 'Discord';
  if (lowerUrl.contains('reddit')) return 'Reddit';
  if (lowerUrl.contains('wikipedia')) return 'Wikipedia';
  if (lowerUrl.contains('fandom') || lowerUrl.contains('wikia')) return 'Wiki';
  if (lowerUrl.contains('itch.io')) return 'Itch.io';
  if (lowerUrl.contains('play.google')) return 'Google Play';
  if (lowerUrl.contains('apps.apple')) return 'App Store';

  return null;
}

/// Returns true if this category represents a store/purchase location.
///
/// If category is 0 or unknown, falls back to URL-based detection.
bool isStoreCategory(int category, [String? url]) {
  const storeCategories = [
    WebsiteCategory.steam,
    WebsiteCategory.epicGames,
    WebsiteCategory.gog,
    WebsiteCategory.iphone,
    WebsiteCategory.ipad,
    WebsiteCategory.android,
    WebsiteCategory.itch,
  ];

  if (storeCategories.contains(category)) {
    return true;
  }

  // Fallback: detect from URL if category is 0 or unknown
  if (url != null && !_websiteNames.containsKey(category)) {
    final detectedCategory = _detectCategoryFromUrl(url);
    if (detectedCategory != null) {
      return storeCategories.contains(detectedCategory);
    }
  }

  return false;
}

/// Returns true if this category represents a social media platform.
///
/// If category is 0 or unknown, falls back to URL-based detection.
bool isSocialCategory(int category, [String? url]) {
  const socialCategories = [
    WebsiteCategory.facebook,
    WebsiteCategory.twitter,
    WebsiteCategory.instagram,
    WebsiteCategory.youtube,
    WebsiteCategory.twitch,
    WebsiteCategory.reddit,
    WebsiteCategory.discord,
  ];

  if (socialCategories.contains(category)) {
    return true;
  }

  // Fallback: detect from URL if category is 0 or unknown
  if (url != null && !_websiteNames.containsKey(category)) {
    final detectedCategory = _detectCategoryFromUrl(url);
    if (detectedCategory != null) {
      return socialCategories.contains(detectedCategory);
    }
  }

  return false;
}
