import 'package:equatable/equatable.dart';

/// A game linked to a featured banner (compact card).
class FeaturedBannerGame extends Equatable {
  const FeaturedBannerGame({
    required this.igdbId,
    required this.name,
    this.coverUrl,
  });

  factory FeaturedBannerGame.fromJson(Map<String, dynamic> json) {
    return FeaturedBannerGame(
      igdbId: json['igdb_id'] as int,
      name: json['name'] as String,
      coverUrl: json['cover_url'] as String?,
    );
  }

  final int igdbId;
  final String name;
  final String? coverUrl;

  @override
  List<Object?> get props => [igdbId, name, coverUrl];
}

/// An editorial hero/banner entry, optionally linked to a game.
class FeaturedBanner extends Equatable {
  const FeaturedBanner({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.position,
    this.subtitle,
    this.game,
  });

  factory FeaturedBanner.fromJson(Map<String, dynamic> json) {
    final game = json['game'];
    return FeaturedBanner(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      imageUrl: json['image_url'] as String,
      position: json['position'] as int? ?? 0,
      game: game == null
          ? null
          : FeaturedBannerGame.fromJson(game as Map<String, dynamic>),
    );
  }

  final String id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final int position;
  final FeaturedBannerGame? game;

  @override
  List<Object?> get props => [id, title, subtitle, imageUrl, position, game];
}

/// Response for GET /home/featured.
class FeaturedBannersResponse extends Equatable {
  const FeaturedBannersResponse({required this.banners});

  factory FeaturedBannersResponse.fromJson(Map<String, dynamic> json) {
    final banners = (json['banners'] as List<dynamic>? ?? [])
        .map((b) => FeaturedBanner.fromJson(b as Map<String, dynamic>))
        .toList();
    return FeaturedBannersResponse(banners: banners);
  }

  final List<FeaturedBanner> banners;

  @override
  List<Object?> get props => [banners];
}
