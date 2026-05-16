import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../../../../core/constants/colors.dart';
import '../../../widgets/common/location_header.dart';

class HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  const HomeHeaderDelegate({
    required this.isDark,
    required this.theme,
    required this.topPadding,
    required this.onNotificationTap,
    required this.onSearchTap,
    required this.onRadiusTap,
    required this.searchRadius,
  });

  final bool isDark;
  final ThemeData theme;
  final double topPadding;
  final VoidCallback onNotificationTap;
  final VoidCallback onSearchTap;
  final VoidCallback onRadiusTap;
  final int searchRadius;

  static const double _expandedContent = 148.0;
  static const double _collapsedContent = 58.0;

  @override
  double get minExtent => topPadding + _collapsedContent;

  @override
  double get maxExtent => topPadding + _expandedContent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final searchOpacity = (1.0 - t * 2.5).clamp(0.0, 1.0);
    final collapsedSearchOpacity = ((t - 0.6) / 0.4).clamp(0.0, 1.0);

    final backdropColor = isDark
        ? Color.lerp(
            AppColors.darkSurface.withValues(alpha: 0.96),
            AppColors.darkSurface.withValues(alpha: 0.96),
            t,
          )!
        : Color.lerp(
            const Color(0xFFF4EBE1),
            const Color(0xFFF4EBE1),
            t,
          )!;

    final bottomRadius = Radius.circular(lerpDouble(28, 20, t)!);

    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: bottomRadius,
                bottomRight: bottomRadius,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: backdropColor,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.22 * (1 - t * 0.5))
                          : Colors.black.withValues(alpha: 0.06 * (1 - t * 0.3)),
                      blurRadius: lerpDouble(16, 8, t)!,
                      offset: Offset(0, lerpDouble(4, 2, t)!),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: topPadding,
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: _collapsedContent,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(child: LocationHeader()),
                          if (collapsedSearchOpacity > 0)
                            Opacity(
                              opacity: collapsedSearchOpacity,
                              child: GestureDetector(
                                onTap: onSearchTap,
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryYellow.withValues(
                                        alpha: isDark ? 0.15 : 0.08),
                                    border: Border.all(
                                      color: AppColors.primaryYellow.withValues(
                                          alpha: isDark ? 0.3 : 0.15),
                                      width: 1,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      if (!isDark)
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Ionicons.search,
                                    color: AppColors.secondaryOrange,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          if (searchOpacity > 0)
                            Opacity(
                              opacity: searchOpacity,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkBackground
                                          .withValues(alpha: 0.6)
                                      : Colors.white.withValues(alpha: 0.75),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    if (!isDark)
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                  ],
                                ),
                                child: IconButton(
                                  iconSize: 20,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  icon: Icon(
                                    Ionicons.notifications_outline,
                                    color: isDark
                                        ? AppColors.white
                                        : AppColors.deepNavy,
                                    size: 20,
                                  ),
                                  onPressed: onNotificationTap,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (searchOpacity > 0) ...[
                      const SizedBox(height: 8),
                      Opacity(
                        opacity: searchOpacity,
                        child: Transform.translate(
                          offset: Offset(0, shrinkOffset * 0.3),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: onSearchTap,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.darkBackground
                                                .withValues(alpha: 0.6)
                                            : Colors.white
                                                .withValues(alpha: 0.75),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isDark
                                              ? AppColors.darkBorder
                                                  .withValues(alpha: 0.4)
                                              : Colors.black
                                                  .withValues(alpha: 0.04),
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryYellow
                                                .withValues(
                                                    alpha: isDark ? 0.3 : 0.15),
                                            blurRadius: 8,
                                            blurStyle: BlurStyle.inner,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Ionicons.search,
                                            color: AppColors.secondaryOrange,
                                            size: 19,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Find Your Favorite Places',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: isDark
                                                    ? Colors.white54
                                                    : const Color(0xFFD6C0B3),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: onRadiusTap,
                                  child: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.darkBackground
                                              .withValues(alpha: 0.6)
                                          : Colors.white
                                              .withValues(alpha: 0.75),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isDark
                                            ? AppColors.darkBorder
                                                .withValues(alpha: 0.4)
                                            : Colors.black
                                                .withValues(alpha: 0.04),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryYellow
                                              .withValues(
                                                  alpha: isDark ? 0.3 : 0.15),
                                          blurRadius: 8,
                                          blurStyle: BlurStyle.inner,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        const Icon(
                                          Ionicons.compass_outline,
                                          color: AppColors.secondaryOrange,
                                          size: 21,
                                        ),
                                        Positioned(
                                          bottom: 5,
                                          right: 5,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.secondaryOrange,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              '$searchRadius',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 8,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant HomeHeaderDelegate oldDelegate) =>
      oldDelegate.isDark != isDark ||
      oldDelegate.topPadding != topPadding ||
      oldDelegate.searchRadius != searchRadius;
}
