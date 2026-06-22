import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A card displaying a YouTube video thumbnail with a play button overlay.
class VideoThumbnailCard extends StatelessWidget {
  const VideoThumbnailCard({
    super.key,
    required this.videoId,
    this.title,
    this.width = 200,
    this.height = 112,
  });

  final String videoId;
  final String? title;
  final double width;
  final double height;

  /// Returns the YouTube thumbnail URL for this video.
  String get thumbnailUrl =>
      'https://img.youtube.com/vi/$videoId/mqdefault.jpg';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[900],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail image
          CachedNetworkImage(
            imageUrl: thumbnailUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[800],
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[800],
              child: const Icon(
                Icons.video_library,
                size: 48,
                color: Colors.white38,
              ),
            ),
          ),
          // Play button overlay
          Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          // Gradient overlay at bottom for title
          if (title != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Text(
                  title!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

          // Tap target with web hover/focus affordance, overlaid so the
          // ripple covers the whole card without altering the layout.
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () {
                  context.pushNamed(
                    'videoPlayer',
                    pathParameters: {'videoId': videoId},
                    queryParameters: title != null ? {'title': title!} : {},
                  );
                },
                mouseCursor: SystemMouseCursors.click,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
