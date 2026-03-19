import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Wraps a [Hero] with visibility awareness so that only heroes actually
/// visible in the viewport can participate in flight animations.
///
/// Uses [HeroMode] (not conditional Hero removal) so the Hero widget always
/// stays in the tree — only its `enabled` flag changes. This avoids the
/// widget-identity problems that occur when Hero is added/removed dynamically.
///
/// Intended for **source** heroes in scrollable lists. Do NOT use this on
/// destination heroes (e.g. the cover on a details screen) because the
/// destination widget is off-screen while it slides in, which would cause the
/// first [VisibilityDetector] callback to fire with fraction = 0 and
/// prematurely disable the hero before the flight completes.
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
  // UniqueKey stored in State — stable across rebuilds, prevents key conflicts
  // when the same tag appears in multiple places on the same screen.
  final Key _detectorKey = UniqueKey();

  // Start enabled so the first navigation works before visibility is measured.
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
      // HeroMode.enabled=false tells Flutter's hero controller to skip this
      // hero entirely — no flight is started and no duplicate-tag error occurs.
      // The Hero widget itself stays in the tree, keeping widget identity stable.
      child: HeroMode(
        enabled: _isVisible,
        child: Hero(tag: widget.tag, child: widget.child),
      ),
    );
  }
}
