import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import '../../../core/constants/assets.dart';
import '../../../data/models/category_model.dart';
import '../../providers/home_provider.dart';
import '../../providers/location_provider.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/common/skeleton_loader.dart';
import '../../widgets/common/smart_image.dart';
import '../../widgets/common/star_rating.dart';
import '../../widgets/common/location_header.dart';
import '../../widgets/common/radius_selector.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ── Location Change Listener ──
    // This triggers whenever the location state changes significantly.
    // ref.listen is more reliable than manual listeners for reacting to state.
    ref.listen<LocationState>(locationProvider, (previous, next) {
      if (next.isLoading) return; // Ignore initialisation phase

      final coordinatesChanged =
          previous?.apiCoordinates != next.apiCoordinates;
      final gpsUpdateCompleted =
          previous?.isUpdating == true && !next.isUpdating;
      final initialLoad = previous?.isLoading == true && !next.isLoading;
      final radiusChanged =
          previous?.searchRadiusKm != next.searchRadiusKm;

      if (coordinatesChanged || gpsUpdateCompleted || initialLoad || radiusChanged) {
        // Trigger a full reload (which clears old data and shows shimmer)
        ref.read(homeProvider.notifier).loadData();
      }
    });

    final hasNoData =
        !homeState.isLoading &&
        !homeState.isRefreshing &&
        (homeState.data == null ||
            (homeState.data!.topServices.isEmpty &&
                homeState.data!.popularNearby.isEmpty &&
                homeState.data!.dynamicSections.isEmpty));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(homeProvider.notifier).loadData(isRefresh: true),
        child: CustomScrollView(
          slivers: [
            // ── Collapsible Header ──
            SliverPersistentHeader(
              pinned: true,
              delegate: _HomeHeaderDelegate(
                isDark: isDark,
                theme: theme,
                topPadding: MediaQuery.paddingOf(context).top,
                onNotificationTap: () => context.push('/notifications'),
                onSearchTap: () => context.push('/search'),
                onRadiusTap: () => _openRadiusSelector(context, ref, isDark),
                searchRadius: ref.watch(locationProvider).searchRadiusKm,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            if (hasNoData)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _HomeEmptyState(
                  theme: theme,
                  isDark: isDark,
                  error: homeState.error,
                  onRetry: () =>
                      ref.read(homeProvider.notifier).loadData(isRefresh: true),
                ),
              )
            else
              // ── All Content Below Search Bar in One SliverList ──
              SliverList(
                delegate: SliverChildListDelegate([
                  // Top Services
                  _buildTopServicesSection(homeState, theme, isDark, context),
                  const SizedBox(height: 28),

                  // Popular Nearby
                  _buildPopularNearbySection(homeState, theme, isDark, context),
                  const SizedBox(height: 28),

                  // Dynamic Sections
                  if (homeState.isLoading ||
                      (homeState.isRefreshing &&
                          (homeState.data == null ||
                              homeState.data!.dynamicSections.isEmpty)))
                    _buildDynamicShimmerRow(theme, isDark)
                  else if (homeState.data?.dynamicSections.isNotEmpty ?? false)
                    ...homeState.data!.dynamicSections.map(
                      (section) =>
                          _buildDynamicSection(section, theme, isDark, context),
                    ),

                  const SizedBox(height: 100),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  // ── Radius Selector ────────────────────────────────────────────────────────

  Future<void> _openRadiusSelector(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) async {
    HapticFeedback.selectionClick();
    final currentRadius = ref.read(locationProvider).searchRadiusKm;
    final result = await showRadiusSelectorSheet(context, currentRadius);
    if (result != null && result != currentRadius) {
      ref.read(locationProvider.notifier).setSearchRadius(result);
      ref.read(homeProvider.notifier).loadData();
    }
  }

  // ── Top Services ──────────────────────────────────────────────────────────

  Widget _buildTopServicesSection(
    HomeState state,
    ThemeData theme,
    bool isDark,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Services',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/top-services'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'View All',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryOrange,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (state.isLoading ||
            (state.isRefreshing &&
                (state.data == null || state.data!.topServices.isEmpty)))
          SizedBox(
            height: 86,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 6,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(right: 14),
                child: SizedBox(width: 64, child: _ServiceShimmer()),
              ),
            ),
          )
        else if (state.data?.topServices.isNotEmpty ?? false)
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: state.data!.topServices.length,
              itemBuilder: (_, index) {
                final cat = state.data!.topServices[index];
                return _buildServiceChip(cat, theme, isDark, context);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildServiceChip(
    CategoryModel cat,
    ThemeData theme,
    bool isDark,
    BuildContext context,
  ) {
    Color bgColor;
    try {
      final hex = cat.colorCode.replaceFirst('#', '');
      bgColor = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      bgColor = AppColors.primaryYellow;
    }

    return GestureDetector(
      onTap: () => context.push('/category/${cat.id}', extra: cat),
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: bgColor.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: cat.iconImage != null
                    ? _buildCategoryIcon(cat.iconImage!, bgColor)
                    : Icon(Ionicons.grid_outline, color: bgColor, size: 26),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              cat.name,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String iconPath, Color color) {
    final isSvg = iconPath.endsWith('.svg');

    if (isSvg) {
      // Server .svg icons often return HTML 404 — use a colored icon fallback instead
      return Icon(Ionicons.grid_outline, color: color, size: 26);
    } else {
      return SmartImage(
        imageUrl: iconPath,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
      );
    }
  }

  // ── Popular Nearby ────────────────────────────────────────────────────────

  Widget _buildPopularNearbySection(
    HomeState state,
    ThemeData theme,
    bool isDark,
    BuildContext context,
  ) {
    if (!state.isLoading &&
        !state.isRefreshing &&
        (state.data?.popularNearby.isEmpty ?? true)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(AppAssets.locationIcon, width: 22, height: 22),
                  const SizedBox(width: 6),
                  Text(
                    'Popular Services Nearby',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.push(
                  '/business-list',
                  extra: {
                    'slug': 'popular-nearby',
                    'title': 'Popular Services Nearby',
                    'subtitle': 'Highly rated businesses in your area',
                  },
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'View All',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryOrange,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Highly rated in your area',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 14),
        if (state.isLoading ||
            (state.isRefreshing &&
                (state.data == null || state.data!.popularNearby.isEmpty)))
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(right: 12),
                child: SkeletonLoader(
                  width: 150,
                  height: 190,
                  borderRadius: 16,
                ),
              ),
            ),
          )
        else if (state.data != null)
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.data!.popularNearby.length,
              itemBuilder: (_, index) {
                final biz = state.data!.popularNearby[index];
                return _buildNearbyCard(biz, theme, isDark, context);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildNearbyCard(
    dynamic biz,
    ThemeData theme,
    bool isDark,
    BuildContext context,
  ) {
    // Format rating to 1 decimal
    final ratingStr = () {
      final r = double.tryParse(biz.overallRating.toString()) ?? 0.0;
      return r == 0.0 ? '—' : r.toStringAsFixed(1);
    }();

    // Use model's formatted distance
    final distanceStr = biz.formattedDistance;

    return GestureDetector(
      onTap: () => context.push('/business/${biz.id}', extra: biz),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'business-image-${biz.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: SmartImage(
                  imageUrl: biz.coverUrl ?? biz.logoUrl,
                  width: 150,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          biz.businessName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (biz.categoryName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            biz.categoryName,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        StarRating(
                          rating: ratingStr,
                          iconSize: 11,
                          textStyle: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (distanceStr != null) ...[
                          const Spacer(),
                          Text(
                            distanceStr,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.secondaryOrange,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dynamic Sections ──────────────────────────────────────────────────────

  Widget _buildDynamicSection(
    dynamic section,
    ThemeData theme,
    bool isDark,
    BuildContext context,
  ) {
    final businesses = section.businesses as List;
    if (businesses.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  section.sectionName as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push(
                    '/business-list',
                    extra: {
                      'slug': section.sectionSlug,
                      'title': section.sectionName,
                      'subtitle': '${section.count} businesses',
                    },
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'View All',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryOrange,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: businesses.length,
              itemBuilder: (_, index) {
                final biz = businesses[index];
                return _buildNearbyCard(biz, theme, isDark, context);
              },
            ),
          ),
        ],
      ),
    );
  }
  // ── Shimmer Helpers ───────────────────────────────────────────────────────

  Widget _buildDynamicShimmerRow(ThemeData theme, bool isDark) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    width: 130,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    width: 50,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    width: 150,
                    height: 190,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _HomeHeaderDelegate ───────────────────────────────────────────────────────

/// Custom [SliverPersistentHeaderDelegate] for the collapsible home header.
///
/// Expanded:  backdrop pill (cream / dark-surface) + location row + bell icon
///            + search bar + radius button.
/// Collapsed: same backdrop at min-height + location row + circular search button.
class _HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _HomeHeaderDelegate({
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

  // ── Sizing constants ────────────────────────────────────────────────────────
  static const double _expandedContent = 148.0;
  static const double _collapsedContent = 58.0;

  @override
  double get minExtent => topPadding + _collapsedContent;

  @override
  double get maxExtent => topPadding + _expandedContent;

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // 0.0 = fully expanded, 1.0 = fully collapsed
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final searchOpacity = (1.0 - t * 2.5).clamp(0.0, 1.0);
    final collapsedSearchOpacity = ((t - 0.6) / 0.4).clamp(0.0, 1.0);

    // Backdrop colors
    final backdropColor = isDark
        ? Color.lerp(
            AppColors.darkSurface.withValues(alpha: 0.96),
            AppColors.darkSurface.withValues(alpha: 0.96),
            t,
          )!
        : Color.lerp(
            const Color(0xFFF4EBE1), // slightly darker warm cream
            const Color(0xFFF4EBE1),
            t,
          )!;

    // Bottom border radius interpolates from 28 (expanded) -> 20 (collapsed)
    final bottomRadius = Radius.circular(lerpDouble(28, 20, t)!);

    return SizedBox.expand(
      child: Stack(
        children: [
          // ── Backdrop ──────────────────────────────────────────────────────
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

          // ── Content ───────────────────────────────────────────────────────
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
                  // ── Row 1: Location + Bell (always visible) ──────────────
                  SizedBox(
                    height: _collapsedContent,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Location header (tappable) — takes remaining space
                        const Expanded(child: LocationHeader()),

                        // Collapsed: round search button (fades in)
                        if (collapsedSearchOpacity > 0)
                          Opacity(
                            opacity: collapsedSearchOpacity,
                            child: GestureDetector(
                              onTap: onSearchTap,
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkBackground
                                          .withValues(alpha: 0.7)
                                      : Colors.white.withValues(alpha: 0.85),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    if (!isDark)
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.08),
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

                        // Expanded: notification bell (fades out on collapse)
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
                                      color:
                                          Colors.black.withValues(alpha: 0.05),
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

                  // ── Row 2: Search bar + Radius (fades away on collapse) ──
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
                              // Search bar
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

                              // Radius button
                              GestureDetector(
                                onTap: onRadiusTap,
                                child: Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkBackground
                                            .withValues(alpha: 0.6)
                                        : Colors.white.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark
                                          ? AppColors.darkBorder
                                              .withValues(alpha: 0.4)
                                          : Colors.black
                                              .withValues(alpha: 0.04),
                                      width: 1,
                                    ),
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
  bool shouldRebuild(covariant _HomeHeaderDelegate oldDelegate) =>
      oldDelegate.isDark != isDark ||
      oldDelegate.topPadding != topPadding ||
      oldDelegate.searchRadius != searchRadius;
}

// ── _ServiceShimmer ───────────────────────────────────────────────────────────

class _ServiceShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 44,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 32,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────────────────────────

class _HomeEmptyState extends StatelessWidget {
  final ThemeData theme;
  final bool isDark;
  final String? error;
  final VoidCallback onRetry;

  const _HomeEmptyState({
    required this.theme,
    required this.isDark,
    this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isError = error != null;
    return isError ? _buildErrorState(context) : _buildEmptyState(context);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Glowing Icon Bubble ─────────────────────────────
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryYellow.withValues(
                          alpha: isDark ? 0.20 : 0.14,
                        ),
                        AppColors.primaryYellow.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                // Inner icon container
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryYellow.withValues(alpha: 0.18),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: const Icon(
                    Ionicons.storefront_outline,
                    size: 34,
                    color: AppColors.primaryYellow,
                  ),
                ),
                // Small decorative accent dot
                Positioned(
                  top: 14,
                  right: 18,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryOrange,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.darkBackground : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Headline ─────────────────────────────────────────
            Text(
              'Nothing around here yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : AppColors.deepNavy,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            // ── Subtitle ─────────────────────────────────────────
            Text(
              'We couldn\'t find any businesses or services near your location right now.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white54 : Colors.grey.shade500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // ── Refresh CTA ───────────────────────────────────────
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Ionicons.refresh_outline, size: 17),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                textStyle: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Icon ─────────────────────────────────────────────
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.error.withValues(alpha: isDark ? 0.18 : 0.10),
                        AppColors.error.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withValues(alpha: 0.15),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    Ionicons.wifi_outline,
                    size: 34,
                    color: AppColors.error.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            Text(
              'Can\'t reach the server',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : AppColors.deepNavy,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            Text(
              'Check your internet connection and try again.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white54 : Colors.grey.shade500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 28),

            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Ionicons.refresh_outline, size: 17),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                textStyle: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
