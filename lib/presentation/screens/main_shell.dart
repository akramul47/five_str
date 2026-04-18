import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';

import '../../core/constants/colors.dart';

/// Main shell with custom floating bottom navigation pill.
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
      if (location.startsWith(_tabs[i].path) && _tabs[i].path != '/' || (location == '/' && _tabs[i].path == '/')) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: child,
      // SafeArea wrapper for the floating pill
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A24) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_tabs.length, (index) {
                final tab = _tabs[index];
                final isSelected = index == currentIndex;

                return GestureDetector(
                  onTap: () => context.go(tab.path),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: isSelected
                        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                        : const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryYellow.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? tab.activeIcon : tab.icon,
                          color: isSelected
                              ? AppColors.primaryYellow
                              : (isDark ? Colors.white54 : Colors.black54),
                          size: 24,
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Text(
                            tab.label,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.primaryYellow,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
