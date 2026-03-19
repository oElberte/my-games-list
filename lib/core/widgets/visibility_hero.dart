import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// A drop-in replacement for [Hero] that only activates the hero animation
/// when the widget is visible in the viewport.
///
/// When the widget is fully scrolled off-screen (visibleFraction == 0), it
/// renders the child directly without a Hero, preventing animations from
/// flying in from invisible positions when multiple screens show the same item.
class VisibilityHero extends StatefulWidget {
  const VisibilityHero({
    super.key,
    required this.tag,
    required this.child,
  });

  final Object tag;
  final Widget child;

  @override
  State<VisibilityHero> createState() => _VisibilityHeroState();
}

class _VisibilityHeroState extends State<VisibilityHero> {
  // Stored in State so it remains stable across rebuilds, preventing conflicts
  // when the same tag appears in multiple places on screen.
  final Key _detectorKey = UniqueKey();

  // Start visible so the Hero is active on first render — avoids missing the
  // animation on the initial navigation before visibility has been measured.
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _detectorKey,
      onVisibilityChanged: (info) {
        final visible = info.visibleFraction > 0;
        if (mounted && visible != _isVisible) {
          setState(() => _isVisible = visible);
        }
      },
      child: _isVisible
          ? Hero(tag: widget.tag, child: widget.child)
          : widget.child,
    );
  }
}
