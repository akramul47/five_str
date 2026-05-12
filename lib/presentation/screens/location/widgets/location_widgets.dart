import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/constants/assets.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/districts.dart';

// ── Location App Bar ─────────────────────────────────────────────────────────

class LocationAppBar extends StatelessWidget {
  final bool isDark;
  final ThemeData theme;
  final TextEditingController searchController;

  const LocationAppBar({
    super.key,
    required this.isDark,
    required this.theme,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    final expandedHeight = statusBarHeight + kToolbarHeight + 120.0;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: bgColor,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.primaryYellow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Ionicons.chevron_back,
              color: Colors.black,
              size: 18,
            ),
          ),
        ),
      ),
      flexibleSpace: LayoutBuilder(
        builder: (ctx, constraints) {
          final isCollapsed =
              constraints.biggest.height <=
              statusBarHeight + kToolbarHeight + 36;

          return Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryYellow.withValues(
                        alpha: isDark ? 0.28 : 0.18,
                      ),
                      AppColors.secondaryOrange.withValues(
                        alpha: isDark ? 0.10 : 0.06,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isCollapsed)
                Positioned(
                  top: statusBarHeight + kToolbarHeight + 4,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            AppAssets.locationIcon,
                            width: 33,
                            height: 33,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Select Location',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              color: isDark ? Colors.white : AppColors.deepNavy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LocationSearchBar(
                        controller: searchController,
                        isDark: isDark,
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              if (isCollapsed)
                Positioned(
                  top: statusBarHeight,
                  left: 76,
                  right: 16,
                  height: kToolbarHeight,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select Location',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.deepNavy,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(28),
        child: Container(
          height: 29,
          transform: Matrix4.translationValues(0, 1, 0),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
      ),
    );
  }
}

// ── Search Bar Component ──────────────────────────────────────────────────────

class LocationSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final ThemeData theme;

  const LocationSearchBar({
    super.key,
    required this.controller,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(
            Ionicons.search,
            color: AppColors.secondaryOrange,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white : AppColors.deepNavy,
              ),
              decoration: InputDecoration(
                hintText: 'Search districts or divisions...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white38 : Colors.grey.shade400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) {
              if (value.text.isEmpty) return const SizedBox(width: 14);
              return GestureDetector(
                onTap: () => controller.clear(),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    Ionicons.close_circle,
                    size: 18,
                    color: Colors.grey.withValues(alpha: 0.7),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── District Tile ────────────────────────────────────────────────────────────

class DistrictTile extends StatelessWidget {
  final District district;
  final ThemeData theme;
  final bool isDark;
  final VoidCallback onTap;

  const DistrictTile({
    super.key,
    required this.district,
    required this.theme,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withValues(
                    alpha: isDark ? 0.15 : 0.1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Image.asset(
                    AppAssets.locationIcon,
                    width: 22,
                    height: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      district.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${district.division} Division',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Ionicons.chevron_forward,
                size: 16,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Feedback Banner ──────────────────────────────────────────────────────────

class LocationFeedbackBanner extends StatelessWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  const LocationFeedbackBanner({
    super.key,
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isError
        ? AppColors.error.withValues(alpha: 0.1)
        : AppColors.success.withValues(alpha: 0.1);
    final fgColor = isError ? AppColors.error : AppColors.success;
    final icon = isError
        ? Ionicons.warning_outline
        : Ionicons.checkmark_circle_outline;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 5, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fgColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: fgColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: fgColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Ionicons.close, color: fgColor, size: 16),
          ),
        ],
      ),
    );
  }
}
