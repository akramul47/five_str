import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';

/// Main shell with bottom navigation bar wrapping tab screens.
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  static const _tabs = [
    (icon: Ionicons.home_outline, activeIcon: Ionicons.home, label: 'Home', path: '/'),
    (icon: Ionicons.search_outline, activeIcon: Ionicons.search, label: 'Discover', path: '/discover'),
    (icon: Ionicons.heart_outline, activeIcon: Ionicons.heart, label: 'Favourites', path: '/favourites'),
    (icon: Ionicons.albums_outline, activeIcon: Ionicons.albums, label: 'Collections', path: '/collections'),
    (icon: Ionicons.person_outline, activeIcon: Ionicons.person, label: 'Profile', path: '/profile'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (int i = _tabs.length - 1; i >= 0; i--) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          context.go(_tabs[index].path);
        },
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.12),
        destinations: _tabs
            .map(
              (tab) => NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.activeIcon),
                label: tab.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
