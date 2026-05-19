import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/assets.dart';
import '../../../core/constants/colors.dart';
import '../../providers/home_provider.dart';
import '../../providers/location_provider.dart';
import '../../widgets/common/radius_selector.dart';
import '../../widgets/common/skeleton_loader.dart';
import 'widgets/home_header_delegate.dart';
import 'widgets/home_empty_state.dart';
import 'widgets/home_shimmer.dart';
import 'widgets/service_chip.dart';
import 'widgets/nearby_card.dart';

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
        ref.read(homeProvider.notifier).loadData(isRefresh: true);
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
              delegate: HomeHeaderDelegate(
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
                child: HomeEmptyState(
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
                    DynamicShimmerRow(isDark: isDark)
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
      ref.read(homeProvider.notifier).loadData(isRefresh: true);
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
                child: const SizedBox(width: 64, child: ServiceShimmer()),
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
                return ServiceChip(category: cat, isDark: isDark);
              },
            ),
          ),
      ],
    );
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
            height: 192,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(right: 12),
                child: SkeletonLoader(
                  width: 150,
                  height: 192,
                  borderRadius: 16,
                ),
              ),
            ),
          )
        else if (state.data != null)
          SizedBox(
            height: 192,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.data!.popularNearby.length,
              itemBuilder: (_, index) {
                final biz = state.data!.popularNearby[index];
                return NearbyCard(business: biz, isDark: isDark, index: index);
              },
            ),
          ),
      ],
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
            height: 192,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: businesses.length,
              itemBuilder: (_, index) {
                final biz = businesses[index];
                return NearbyCard(business: biz, isDark: isDark, index: index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

