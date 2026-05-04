import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/colors.dart';
import '../../../data/models/business_model.dart';
import '../../../data/models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../widgets/common/smart_image.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  final int id;
  final CategoryModel? initialCategory;

  const CategoryScreen({super.key, required this.id, this.initialCategory});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      ref.read(categoryProvider(widget.id).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryProvider(widget.id));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: bgColor,
      body: RefreshIndicator(
        color: AppColors.primaryYellow,
        onRefresh: () async =>
            ref.read(categoryProvider(widget.id).notifier).refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ── App Bar ──────────────────────────────────────────────
            _CategoryAppBar(
              state: state,
              initialCategory: widget.initialCategory,
              isDark: isDark,
              theme: theme,
            ),

            // ── Subcategory Filter Chips ──────────────────────────────
            if (!state.isLoadingCategory &&
                (state.category?.subcategories?.isNotEmpty ?? false))
              SliverToBoxAdapter(
                child: _SubcategoryChips(
                  subcategories: state.category!.subcategories!,
                  selectedId: state.selectedSubcategoryId,
                  isDark: isDark,
                  theme: theme,
                  onSelected: (id) =>
                      ref.read(categoryProvider(widget.id).notifier).selectSubcategory(id),
                ),
              ),

            // ── Sort Bar ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _SortBar(
                currentSort: state.sort,
                isDark: isDark,
                theme: theme,
                onSort: (sort) =>
                    ref.read(categoryProvider(widget.id).notifier).changeSort(sort),
                resultCount: state.isLoadingBusinesses
                    ? null
                    : state.businesses.length,
              ),
            ),

            // ── Business List ─────────────────────────────────────────
            if (state.isLoadingBusinesses)
              _BusinessListShimmer(isDark: isDark)
            else if (state.businesses.isEmpty && state.error == null)
              SliverFillRemaining(child: _EmptyState(theme: theme, isDark: isDark))
            else if (state.error != null && state.businesses.isEmpty)
              SliverFillRemaining(
                child: _ErrorState(
                  error: state.error!,
                  theme: theme,
                  onRetry: () =>
                      ref.read(categoryProvider(widget.id).notifier).refresh(),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Footer slot: spinner while loading more, nothing at end
                    if (index == state.businesses.length) {
                      if (state.isLoadingMore) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                color: AppColors.primaryYellow,
                                strokeWidth: 1.5,
                              ),
                            ),
                          ),
                        );
                      }
                      // Last page reached — just a small bottom padding
                      return const SizedBox(height: 100);
                    }
                    return _BusinessListTile(
                      business: state.businesses[index],
                      theme: theme,
                      isDark: isDark,
                    );
                  },
                  // Only add the footer slot when loading more OR there is more to load;
                  // always keep it so the spacer at the bottom is present
                  childCount: state.businesses.length + 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────

class _CategoryAppBar extends StatelessWidget {
  final CategoryState state;
  final CategoryModel? initialCategory;
  final bool isDark;
  final ThemeData theme;

  const _CategoryAppBar({
    required this.state,
    required this.initialCategory,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    // Use live category once loaded, fall back to initialCategory immediately
    final category = state.category ?? initialCategory;
    final hasBanner = category?.bannerImage != null;
    final statusBarHeight = MediaQuery.paddingOf(context).top;

    Color accentColor = AppColors.primaryYellow;
    if (category?.colorCode != null) {
      try {
        final hex = category!.colorCode.replaceFirst('#', '');
        accentColor = Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }

    return SliverAppBar(
      expandedHeight: hasBanner ? 240 : 200,
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
      flexibleSpace: LayoutBuilder(builder: (ctx, constraints) {
        // Must include the 30px bottom PreferredSize so the collapsed state
        // triggers correctly. At minimum height: statusBar + toolbar + 30 ≈ 130px.
        final isCollapsed =
            constraints.biggest.height <= statusBarHeight + kToolbarHeight + 36;

        return Stack(
          fit: StackFit.expand,
          children: [
            // ── Background ─────────────────────────────────────────────
            if (hasBanner)
              Stack(fit: StackFit.expand, children: [
                SmartImage(imageUrl: category!.bannerImage!, fit: BoxFit.cover),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.black.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                ),
              ])
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor.withValues(alpha: isDark ? 0.28 : 0.18),
                      accentColor.withValues(alpha: isDark ? 0.10 : 0.06),
                    ],
                  ),
                ),
              ),

            // ── Expanded: icon + title in a single row at the bottom ────
            //    bottom: 44 = 30px (rounded container) + 14px margin
            //    With expandedHeight:200, row top ≈ statusBar+toolbar+8, safe below toolbar
            if (!isCollapsed)
              Positioned(
                bottom: 44,
                left: 20,
                right: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!hasBanner) ...[
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: category?.iconImage != null
                            ? SmartImage(
                                imageUrl: category!.iconImage!,
                                width: 26,
                                height: 26,
                                fit: BoxFit.contain,
                              )
                            : Icon(Ionicons.grid_outline,
                                color: accentColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        category?.name ?? 'Services',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: hasBanner
                              ? Colors.white
                              : (isDark ? Colors.white : AppColors.deepNavy),
                          shadows: hasBanner
                              ? [const Shadow(
                                  color: Colors.black54, blurRadius: 4)]
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            // ── Collapsed toolbar title ─────────────────────────────────
            if (isCollapsed)
              Positioned(
                top: statusBarHeight,
                left: 76,
                right: 16,
                height: kToolbarHeight,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    category?.name ?? 'Services',
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(30),
        child: Container(
          height: 31,
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


// ── Subcategory Filter Chips ──────────────────────────────────────────────────


class _SubcategoryChips extends StatelessWidget {
  final List<CategoryModel> subcategories;
  final int? selectedId;
  final bool isDark;
  final ThemeData theme;
  final ValueChanged<int?> onSelected;

  const _SubcategoryChips({
    required this.subcategories,
    required this.selectedId,
    required this.isDark,
    required this.theme,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('All'),
              selected: selectedId == null,
              onSelected: (_) => onSelected(null),
              selectedColor: AppColors.primaryYellow,
              backgroundColor:
                  isDark ? AppColors.darkSurface : Colors.grey.shade100,
              labelStyle: theme.textTheme.labelMedium?.copyWith(
                color: selectedId == null ? Colors.black : null,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide.none,
            ),
          ),
          ...subcategories.map(
            (sub) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(sub.name),
                selected: selectedId == sub.id,
                onSelected: (_) => onSelected(sub.id),
                selectedColor: AppColors.primaryYellow,
                backgroundColor:
                    isDark ? AppColors.darkSurface : Colors.grey.shade100,
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  color: selectedId == sub.id ? Colors.black : null,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sort Bar ──────────────────────────────────────────────────────────────────

class _SortBar extends StatelessWidget {
  final String currentSort;
  final bool isDark;
  final ThemeData theme;
  final ValueChanged<String> onSort;
  final int? resultCount;

  const _SortBar({
    required this.currentSort,
    required this.isDark,
    required this.theme,
    required this.onSort,
    required this.resultCount,
  });

  static const _sortOptions = [
    ('distance', 'Nearest'),
    ('rating', 'Top Rated'),
    ('popular', 'Popular'),
    ('newest', 'Newest'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          if (resultCount != null)
            Text(
              '$resultCount results',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showSortSheet(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Ionicons.swap_vertical_outline,
                      size: 14, color: AppColors.secondaryOrange),
                  const SizedBox(width: 6),
                  Text(
                    _sortOptions
                        .firstWhere((o) => o.$1 == currentSort,
                            orElse: () => _sortOptions.first)
                        .$2,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.secondaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Sort By',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._sortOptions.map(
              (opt) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(opt.$2),
                trailing: currentSort == opt.$1
                    ? const Icon(Ionicons.checkmark,
                        color: AppColors.primaryYellow)
                    : null,
                onTap: () {
                  onSort(opt.$1);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Business List Tile ────────────────────────────────────────────────────────

class _BusinessListTile extends StatelessWidget {
  final BusinessModel business;
  final ThemeData theme;
  final bool isDark;

  const _BusinessListTile({
    required this.business,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final ratingStr = () {
      final r = double.tryParse(business.overallRating.toString()) ?? 0.0;
      return r == 0.0 ? '—' : r.toStringAsFixed(1);
    }();

    return GestureDetector(
      onTap: () => context.push('/business/${business.id}', extra: business),
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
            // Thumbnail
            Hero(
              tag: 'business-image-${business.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16)),
                child: SmartImage(
                  imageUrl: business.coverUrl ?? business.logoUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.businessName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (business.categoryName != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        business.categoryName!,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Ionicons.star,
                            size: 12, color: AppColors.starYellow),
                        const SizedBox(width: 3),
                        Text(
                          ratingStr,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                        if (business.totalReviews != null &&
                            business.totalReviews! > 0) ...[
                          const SizedBox(width: 3),
                          Text(
                            '(${business.totalReviews})',
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: Colors.grey, fontSize: 10),
                          ),
                        ],
                        if (business.isVerified) ...[
                          const SizedBox(width: 8),
                          const Icon(Ionicons.checkmark_circle,
                              size: 12, color: AppColors.success),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Ionicons.location_outline,
                            size: 11, color: Colors.grey),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            business.area ?? business.city ?? 'Unknown',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (business.formattedDistance != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            business.formattedDistance!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.secondaryOrange,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Ionicons.chevron_forward,
                  size: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shimmer ───────────────────────────────────────────────────────────────────

class _BusinessListShimmer extends StatelessWidget {
  final bool isDark;

  const _BusinessListShimmer({required this.isDark});

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
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(16)),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 16),
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
                          Container(
                              height: 10, width: 140, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        childCount: 8,
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
            Ionicons.storefront_outline,
            size: 64,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            'No businesses found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing the filter or expand your search area',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
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
                size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Something went wrong',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Ionicons.refresh_outline, size: 16),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
