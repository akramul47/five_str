import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../data/models/offering_model.dart';
import '../../../widgets/common/smart_image.dart';

class MenuTab extends StatelessWidget {
  final List<OfferingModel> offerings;
  final bool isLoading;
  final bool hasVisited;
  final bool isDark;
  final ThemeData theme;
  final String? fallbackLogoUrl;

  const MenuTab({
    super.key,
    required this.offerings,
    required this.isLoading,
    required this.hasVisited,
    required this.isDark,
    required this.theme,
    this.fallbackLogoUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Not yet visited → blank (will start loading shortly)
    if (!hasVisited || isLoading) return _shimmer(isDark);

    if (offerings.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Ionicons.restaurant_outline,
              size: 48, color: isDark ? Colors.white24 : Colors.black26),
          const SizedBox(height: 12),
          Text('No menu items available',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
        ]),
      );
    }
    return CustomScrollView(slivers: [
      const SliverToBoxAdapter(child: SizedBox(height: 28)),

      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) =>
                _MenuCard(item: offerings[index], isDark: isDark, theme: theme, fallbackLogoUrl: fallbackLogoUrl),
            childCount: offerings.length,
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 32)),
    ]);
  }

  static Widget _shimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        children: List.generate(
          6,
          (_) => Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }
}

// ── Menu Card ────────────────────────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  final OfferingModel item;
  final bool isDark;
  final ThemeData theme;
  final String? fallbackLogoUrl;

  const _MenuCard(
      {required this.item,
      required this.isDark,
      required this.theme,
      this.fallbackLogoUrl});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.darkBackground : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                width: double.infinity,
                child: SmartImage(
                  imageUrl: item.imageUrl ?? fallbackLogoUrl ?? '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(children: [
                  Text(
                    '${item.currency} ${item.price}',
                    style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.primaryYellow,
                        fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Icon(Ionicons.star,
                      size: 12, color: AppColors.primaryYellow),
                  const SizedBox(width: 2),
                  Text(item.averageRating,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: Colors.grey)),
                ]),
                if (item.isPopular) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('POPULAR',
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 9)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
