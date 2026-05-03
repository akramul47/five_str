import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/colors.dart';
import '../../../data/models/category_model.dart';
import '../../providers/top_services_provider.dart';
import '../../widgets/common/smart_image.dart';

class TopServicesScreen extends ConsumerStatefulWidget {
  const TopServicesScreen({super.key});

  @override
  ConsumerState<TopServicesScreen> createState() => _TopServicesScreenState();
}

class _TopServicesScreenState extends ConsumerState<TopServicesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(topServicesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: bgColor,
      body: RefreshIndicator(
        color: AppColors.primaryYellow,
        onRefresh: () =>
            ref.read(topServicesProvider.notifier).load(isRefresh: true),
        child: CustomScrollView(
          slivers: [
            // ── Expanding App Bar with search inside ─────────────────────
            _TopServicesAppBar(
              isDark: isDark,
              theme: theme,
              totalCount: state.isLoading ? null : state.categories.length,
              searchController: _searchController,
              onSearchChanged: (q) =>
                  ref.read(topServicesProvider.notifier).updateSearch(q),
            ),

            // ── Content ──────────────────────────────────────────────────
            if (state.isLoading)
              _CategoryListShimmer(isDark: isDark)
            else if (state.error != null && state.categories.isEmpty)
              SliverFillRemaining(
                child: _ErrorState(
                  error: state.error!,
                  theme: theme,
                  onRetry: () => ref
                      .read(topServicesProvider.notifier)
                      .load(isRefresh: true),
                ),
              )
            else if (state.filteredCategories.isEmpty)
              SliverFillRemaining(
                child: _EmptyState(theme: theme, isDark: isDark),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == state.filteredCategories.length) {
                      return const SizedBox(height: 100);
                    }
                    return _CategoryListTile(
                      category: state.filteredCategories[index],
                      theme: theme,
                      isDark: isDark,
                    );
                  },
                  childCount: state.filteredCategories.length + 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────

class _TopServicesAppBar extends StatelessWidget {
  final bool isDark;
  final ThemeData theme;
  final int? totalCount;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const _TopServicesAppBar({
    required this.isDark,
    required this.theme,
    required this.totalCount,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final statusBarHeight = MediaQuery.paddingOf(context).top;

    // Height = status bar + toolbar (back button) + content + bottom strip
    // Content: title(~26) + subtitle(~18) + gap(14) + searchbar(48) + padding(16) ≈ 122px
    // Bottom strip: 28px
    final expandedHeight = statusBarHeight + kToolbarHeight + 150.0;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: bgColor,
      // Back button — always correctly placed by Flutter in both states
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
      // NO title prop — prevents duplicate. Collapsed title handled via Positioned below.
      flexibleSpace: LayoutBuilder(builder: (ctx, constraints) {
        final isCollapsed = constraints.biggest.height <=
            statusBarHeight + kToolbarHeight + 36;

        return Stack(
          fit: StackFit.expand,
          children: [
            // ── Gradient background ──────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryYellow
                        .withValues(alpha: isDark ? 0.28 : 0.18),
                    AppColors.secondaryOrange
                        .withValues(alpha: isDark ? 0.10 : 0.06),
                  ],
                ),
              ),
            ),

            // ── Expanded: title + subtitle + search bar ──────────────────
            if (!isCollapsed)
              Positioned(
                top: statusBarHeight + kToolbarHeight + 8,
                left: 20,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Top Services',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : AppColors.deepNavy,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (totalCount != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        '$totalCount categories available',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Colors.white60
                              : AppColors.deepNavy.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    _SearchBar(
                      controller: searchController,
                      isDark: isDark,
                      theme: theme,
                      onChanged: onSearchChanged,
                    ),
                  ],
                ),
              ),

            // ── Collapsed: title text only, past the back button (left:76)
            if (isCollapsed)
              Positioned(
                top: statusBarHeight,
                left: 76,
                right: 16,
                height: kToolbarHeight,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Top Services',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.deepNavy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        );
      }),
      // Rounded white bottom strip
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(28),
        child: Container(
          height: 29,
          transform: Matrix4.translationValues(0, 1, 0),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
      ),
    );
  }
}

// ── Search Bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final ThemeData theme;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.isDark,
    required this.theme,
    required this.onChanged,
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
              onChanged: onChanged,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white : AppColors.deepNavy,
              ),
              decoration: InputDecoration(
                hintText: 'Search categories...',
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
                onTap: () {
                  controller.clear();
                  onChanged('');
                },
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

// ── Category List Tile ────────────────────────────────────────────────────────

class _CategoryListTile extends StatelessWidget {
  final CategoryModel category;
  final ThemeData theme;
  final bool isDark;

  const _CategoryListTile({
    required this.category,
    required this.theme,
    required this.isDark,
  });

  Color _accentColor() {
    try {
      final hex = category.colorCode.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.primaryYellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor();
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;

    return GestureDetector(
      onTap: () => context.push('/category/${category.id}', extra: category),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            // ── Icon Container ──────────────────────────────────────────
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
              ),
              child: Center(child: _buildIcon(accent)),
            ),

            // ── Text Info ───────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${category.totalBusinesses} businesses',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    if (category.isFeatured || category.isPopular) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (category.isFeatured)
                            _TagChip(
                              label: 'Featured',
                              color: AppColors.error,
                            ),
                          if (category.isFeatured && category.isPopular)
                            const SizedBox(width: 6),
                          if (category.isPopular)
                            _TagChip(
                              label: 'Popular',
                              color: AppColors.success,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Business Count Badge + Arrow ─────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color:
                          accent.withValues(alpha: isDark ? 0.22 : 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _formatCount(category.totalBusinesses),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Ionicons.chevron_forward,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(Color accent) {
    if (category.iconImage != null &&
        !category.iconImage!.endsWith('.svg')) {
      return SmartImage(
        imageUrl: category.iconImage!,
        width: 40,
        height: 40,
        fit: BoxFit.contain,
      );
    }
    return Icon(Ionicons.grid_outline, color: accent, size: 28);
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '$count';
  }
}

// ── Tag Chip ──────────────────────────────────────────────────────────────────

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TagChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ── Shimmer ───────────────────────────────────────────────────────────────────

class _CategoryListShimmer extends StatelessWidget {
  final bool isDark;
  const _CategoryListShimmer({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(16)),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              height: 14,
                              width: double.infinity,
                              color: Colors.white),
                          Container(
                              height: 10, width: 100, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        childCount: 10,
      ),
    );
  }
}

// ── Empty & Error States ──────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final ThemeData theme;
  final bool isDark;
  const _EmptyState({required this.theme, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Ionicons.grid_outline,
            size: 64,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            'No categories found',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final ThemeData theme;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.error,
    required this.theme,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Ionicons.cloud_offline_outline,
                size: 56, color: AppColors.secondaryOrange),
            const SizedBox(height: 16),
            Text(
              'Could not load categories',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style:
                  theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Ionicons.refresh_outline, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
