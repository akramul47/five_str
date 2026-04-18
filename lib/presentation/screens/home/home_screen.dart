import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';

import '../../providers/home_provider.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/cards/business_card.dart';
import '../../widgets/common/skeleton_loader.dart';
import '../../widgets/common/smart_image.dart';

/// Translated Home Screen matching the provided design layout logic.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeProvider.notifier).loadData(isRefresh: true),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Find Your\nFavorite Places',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            if (!isDark)
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Ionicons.notifications_outline,
                            color: isDark ? AppColors.white : AppColors.deepNavy,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Search Bar Row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        height: 56,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : const Color(0xFFFFF9F2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Ionicons.search,
                              color: AppColors.secondaryOrange,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'What are you looking for?',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark ? Colors.white54 : const Color(0xFFD6C0B3),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : const Color(0xFFFFF9F2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Ionicons.options,
                          color: AppColors.secondaryOrange,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Banner Carousel
            SliverToBoxAdapter(
              child: _buildBannerSection(homeState, theme, isDark),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Nearest Places Section
            SliverToBoxAdapter(
              child: _buildNearestPlacesSection(homeState, theme, isDark),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Popular Menu / Featured Places Section
            SliverToBoxAdapter(
              child: _buildPopularFeaturedSection(context, homeState, theme, isDark),
            ),

            // Extra padding for floating bottom nav
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSection(HomeState state, ThemeData theme, bool isDark) {
    if (state.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SkeletonLoader(height: 150, width: double.infinity, borderRadius: 20),
      );
    }

    if (state.data?.banners.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 150,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: state.data!.banners.length,
        itemBuilder: (context, index) {
          final banner = state.data!.banners[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.primaryYellow,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                if (banner.imageUrl.isNotEmpty)
                  Positioned.fill(
                    child: SmartImage(
                      imageUrl: banner.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                // Gradient overlay for text readability
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  top: 0,
                  bottom: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        banner.title,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (banner.subtitle != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          banner.subtitle!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryYellow,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          minimumSize: Size.zero,
                        ),
                        child: const Text('View Deal'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNearestPlacesSection(HomeState state, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Nearby',
                style: theme.textTheme.titleLarge,
              ),
              Text(
                'View More',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryOrange,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (state.isLoading)
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: SkeletonLoader(height: 180, width: 140, borderRadius: 16),
              ),
            ),
          )
        else if (state.data?.popularNearby.isNotEmpty ?? false)
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.data!.popularNearby.length,
              itemBuilder: (context, index) {
                final business = state.data!.popularNearby[index];
                return _buildSquareCard(context, business, theme, isDark);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSquareCard(BuildContext context, business, ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: () => context.push('/business/${business.id}', extra: business),
      child: Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: 'business-image-${business.id}',
            child: SmartImage(
              imageUrl: business.logoUrl ?? business.coverUrl,
              width: 80,
              height: 80,
              isRound: true,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              business.businessName,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${business.distanceKm ?? 0} km',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white54 : Colors.grey,
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildPopularFeaturedSection(BuildContext context, HomeState state, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Places',
                style: theme.textTheme.titleLarge,
              ),
              Text(
                'View More',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryOrange,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (state.isLoading)
          const SkeletonCard()
        else if (state.data?.featuredBusinesses.isNotEmpty ?? false)
          ...state.data!.featuredBusinesses.take(3).map((biz) => BusinessCard(business: biz)),
      ],
    );
  }
}
