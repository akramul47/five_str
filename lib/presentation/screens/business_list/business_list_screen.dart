import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/colors.dart';
import '../../../data/models/business_model.dart';
import '../../providers/business_list_provider.dart';
import '../../widgets/common/smart_image.dart';

/// Generic "View All" screen that lists businesses from any home section.
/// Accepts [type] (which API to call), [title], and optional [subtitle].
class BusinessListScreen extends ConsumerStatefulWidget {
  final BusinessListType type;
  final String title;
  final String? subtitle;

  const BusinessListScreen({
    super.key,
    required this.type,
    required this.title,
    this.subtitle,
  });

  @override
  ConsumerState<BusinessListScreen> createState() => _BusinessListScreenState();
}

class _BusinessListScreenState extends ConsumerState<BusinessListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      ref.read(businessListProvider(widget.type).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(businessListProvider(widget.type));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: bgColor,
      body: RefreshIndicator(
        color: AppColors.primaryYellow,
        onRefresh: () async =>
            ref.read(businessListProvider(widget.type).notifier).refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ── App Bar ──────────────────────────────────────────────────
            _BusinessListAppBar(
              title: widget.title,
              subtitle: widget.subtitle,
              isDark: isDark,
              theme: theme,
              totalCount: state.isLoading 
                  ? null 
                  : (state.totalItems > 0 ? state.totalItems : state.businesses.length),
              searchController: _searchController,
              onSearchChanged: (q) => ref
                  .read(businessListProvider(widget.type).notifier)
                  .updateSearch(q),
            ),

            // ── Content ───────────────────────────────────────────────────
            if (state.isLoading)
              _BusinessListShimmer(isDark: isDark)
            else if (state.error != null && state.businesses.isEmpty)
              SliverFillRemaining(
                child: _ErrorState(
                  error: state.error!,
                  theme: theme,
                  onRetry: () => ref
                      .read(businessListProvider(widget.type).notifier)
                      .refresh(),
                ),
              )
            else if (state.filtered.isEmpty)
              SliverFillRemaining(
                child: _EmptyState(
                  theme: theme,
                  isDark: isDark,
                  isSearching: state.searchQuery.isNotEmpty,
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Footer: loading spinner or end padding
                    if (index == state.filtered.length) {
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
                      return const SizedBox(height: 100);
                    }
                    return _BusinessTile(
                      business: state.filtered[index],
                      theme: theme,
                      isDark: isDark,
                    );
                  },
                  childCount: state.filtered.length + 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────

class _BusinessListAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isDark;
  final ThemeData theme;
  final int? totalCount;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const _BusinessListAppBar({
    required this.title,
    required this.subtitle,
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
    final expandedHeight = statusBarHeight + kToolbarHeight + 150.0;

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
            child: const Icon(Ionicons.chevron_back,
                color: Colors.black, size: 18),
          ),
        ),
      ),
      flexibleSpace: LayoutBuilder(builder: (ctx, constraints) {
        final isCollapsed = constraints.biggest.height <=
            statusBarHeight + kToolbarHeight + 36;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
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

            // Expanded: title + subtitle + search
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
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : AppColors.deepNavy,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null || totalCount != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        (totalCount != null && totalCount! > 0)
                            ? '$totalCount businesses'
                            : (subtitle ?? ''),
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
                    // Search bar
                    _SearchBar(
                      controller: searchController,
                      isDark: isDark,
                      theme: theme,
                      onChanged: onSearchChanged,
                    ),
                  ],
                ),
              ),

            // Collapsed: title past the back button
            if (isCollapsed)
              Positioned(
                top: statusBarHeight,
                left: 76,
                right: 16,
                height: kToolbarHeight,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
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
      height: 46,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search businesses...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.white38 : Colors.grey.shade400,
          ),
          prefixIcon: const Icon(Ionicons.search_outline,
              size: 18, color: AppColors.secondaryOrange),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, val, __) => val.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Ionicons.close_circle,
                        size: 16, color: Colors.grey),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

// ── Business Tile ─────────────────────────────────────────────────────────────

class _BusinessTile extends StatelessWidget {
  final BusinessModel business;
  final ThemeData theme;
  final bool isDark;

  const _BusinessTile({
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
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(16)),
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
              child: Icon(Ionicons.chevron_forward, size: 16, color: Colors.grey),
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
    final base = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final hl   = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Shimmer.fromColors(
            baseColor: base,
            highlightColor: hl,
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
                          Container(height: 10, width: 100, color: Colors.white),
                          Container(height: 10, width: 140, color: Colors.white),
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
  final bool isSearching;

  const _EmptyState({
    required this.theme,
    required this.isDark,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching
                ? Ionicons.search_outline
                : Ionicons.storefront_outline,
            size: 64,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No results found' : 'No businesses here yet',
            style:
                theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Try a different search term'
                : 'Check back later for updates',
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
                size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Something went wrong',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(error,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
                maxLines: 3),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Ionicons.refresh_outline, size: 16),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
