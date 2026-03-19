import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Wraps a [Hero] with visibility awareness so that only heroes actually
/// visible in the viewport participate in flight animations.
///
/// Uses [HeroMode] (not conditional Hero removal) so the Hero widget always
/// stays in the tree — only its `enabled` flag changes. This avoids the
/// widget-identity problems that occur when Hero is added/removed dynamically.
///
/// Subscribes to the [ScrollPosition] of **every ancestor scrollable** so
/// visibility is re-evaluated on every scroll event at any nesting level.
/// Uses [RenderBox.localToGlobal] for the check — synchronous, correct for
/// any combination of vertical/horizontal/carousel scrollables.
///
/// Intended for **source** heroes in scrollable lists. Do NOT use on the
/// destination hero (e.g. the cover on a details screen): the destination
/// widget is off-screen while sliding in, which would disable it before the
/// flight can land.
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
  final List<ScrollPosition> _subscriptions = [];

  // Start enabled — hero is active before the first frame is measured.
  bool _isVisible = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _unsubscribe();
    _subscribe();
    // Schedule the first visibility check after layout is complete so that
    // findRenderObject() returns a properly sized RenderBox.
    SchedulerBinding.instance.addPostFrameCallback((_) => _updateVisibility());
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  /// Walks up the widget tree subscribing to every ancestor [ScrollPosition].
  ///
  /// [Scrollable.maybeOf(scrollable.context)] jumps from the inner scrollable
  /// to the next ancestor scrollable, covering all nesting levels (e.g. a
  /// horizontal ListView inside a vertical SingleChildScrollView).
  void _subscribe() {
    BuildContext? ctx = context;
    while (ctx != null) {
      final scrollable = Scrollable.maybeOf(ctx);
      if (scrollable == null) break;
      scrollable.position.addListener(_updateVisibility);
      _subscriptions.add(scrollable.position);
      // Move up to the Scrollable widget's own context so the next iteration
      // finds the parent scrollable, not this one again.
      ctx = scrollable.context;
    }
  }

  void _unsubscribe() {
    for (final pos in _subscriptions) {
      pos.removeListener(_updateVisibility);
    }
    _subscriptions.clear();
  }

  void _updateVisibility() {
    if (!mounted) return;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !box.attached) return;

    late final Offset offset;
    try {
      offset = box.localToGlobal(Offset.zero);
    } catch (_) {
      // Widget is not yet part of the composited layer tree.
      return;
    }

    final itemRect = offset & box.size;

    final view = WidgetsBinding.instance.platformDispatcher.implicitView;
    if (view == null) return;
    final screenSize = view.physicalSize / view.devicePixelRatio;
    final screenRect = Offset.zero & screenSize;

    final visible = screenRect.overlaps(itemRect);
    if (visible != _isVisible) {
      setState(() => _isVisible = visible);
    }
  }

  @override
  Widget build(BuildContext context) {
    return HeroMode(
      enabled: _isVisible,
      child: Hero(tag: widget.tag, child: widget.child),
    );
  }
}
