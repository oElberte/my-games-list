import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Adaptive primary navigation for the app shell.
///
/// Features:
/// - Four destinations: Home, Browse, Library, Profile
/// - Compact (< 600px): Material 3 bottom [NavigationBar]
/// - Medium/expanded (>= 600px, e.g. web/desktop/tablet): side [NavigationRail]
/// - Integrates with GoRouter's StatefulShellRoute for state preservation
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  /// Width at/above which the side rail replaces the bottom bar.
  static const double _railBreakpoint = 600;

  // Single source of destinations so the bar and rail stay in sync.
  // Labels are localized separately (see i18n issue #2).
  static const List<_NavDestination> _destinations = [
    _NavDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    _NavDestination(
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore,
      label: 'Browse',
    ),
    _NavDestination(
      icon: Icons.sports_esports_outlined,
      selectedIcon: Icons.sports_esports,
      label: 'Library',
    ),
    _NavDestination(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= _railBreakpoint;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        animationDuration: const Duration(milliseconds: 400),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
