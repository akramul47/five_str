import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';

import '../../../core/constants/colors.dart';
import '../../providers/search_provider.dart';
import '../../providers/location_provider.dart';
import '../../widgets/common/smart_image.dart';
import '../../widgets/common/skeleton_loader.dart';
import '../../../data/models/business_model.dart';
import '../../../data/models/attraction_model.dart';
import '../../../data/models/offering_model.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchProvider.notifier).clearSearch();
    _searchFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final searchState = ref.watch(searchProvider);
    final locationState = ref.watch(locationProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8F9FA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header & Search Bar ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryYellow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Ionicons.chevron_back, color: Colors.black, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBackground : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : Colors.transparent,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(Ionicons.search_outline, color: Colors.grey.shade500, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              autofocus: true,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: isDark ? Colors.white : AppColors.deepNavy,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search businesses, attractions...',
                                hintStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (val) => ref.read(searchProvider.notifier).setQuery(val),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: _clearSearch,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Ionicons.close, size: 14, color: isDark ? Colors.white : AppColors.deepNavy),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Location Scope Toggle ──
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
                border: Border.all(color: isDark ? AppColors.darkBorder : Colors.transparent),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: searchState.searchWholeBangladesh
                              ? AppColors.success.withValues(alpha: 0.15)
                              : AppColors.primaryYellow.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          searchState.searchWholeBangladesh ? Ionicons.globe_outline : Ionicons.location_outline,
                          color: searchState.searchWholeBangladesh ? AppColors.success : AppColors.primaryYellow,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Search Location',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              searchState.searchWholeBangladesh
                                  ? 'All of Bangladesh'
                                  : locationState.locationName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: searchState.searchWholeBangladesh,
                        activeColor: AppColors.success,
                        onChanged: (_) => ref.read(searchProvider.notifier).toggleSearchScope(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: searchState.searchWholeBangladesh
                          ? AppColors.success.withValues(alpha: 0.05)
                          : AppColors.primaryYellow.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          searchState.searchWholeBangladesh ? Ionicons.earth : Ionicons.navigate_circle,
                          size: 14,
                          color: searchState.searchWholeBangladesh ? AppColors.success : AppColors.primaryYellow,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          searchState.searchWholeBangladesh ? 'National search active' : 'Local search active',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: searchState.searchWholeBangladesh ? AppColors.success : AppColors.primaryYellow,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Main Content Area ──
            Expanded(
              child: _buildContent(searchState, theme, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(SearchState state, ThemeData theme, bool isDark) {
    if (state.isLoading) {
      return _buildShimmerLoading(theme, isDark);
    }

    if (state.showMinCharsMessage) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Ionicons.text_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Keep typing',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Type at least 2 characters to search',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (state.results != null) {
      if (state.hasNoResults) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Ionicons.search_outline, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'No results found',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.deepNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching with different keywords',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
              ),
            ],
          ),
        );
      }

      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          if (state.results!.businesses.isNotEmpty) ...[
            _buildSectionTitle('Businesses', theme),
            ...state.results!.businesses.map((b) => _buildBusinessItem(b, theme, isDark)),
            const SizedBox(height: 24),
          ],
          if (state.results!.attractions.isNotEmpty) ...[
            _buildSectionTitle('Attractions', theme),
            ...state.results!.attractions.map((a) => _buildAttractionItem(a, theme, isDark)),
            const SizedBox(height: 24),
          ],
          if (state.results!.offerings.isNotEmpty) ...[
            _buildSectionTitle('Products & Services', theme),
            ...state.results!.offerings.map((o) => _buildOfferingItem(o, theme, isDark)),
            const SizedBox(height: 40),
          ],
        ],
      );
    }

    // Initial state
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(Ionicons.search_outline, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Text(
            'Search for businesses',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.deepNavy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find restaurants, shops, services and more near you',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Popular searches:',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: ['Restaurant', 'Coffee', 'Shopping', 'Beauty'].map((tag) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = tag;
                  ref.read(searchProvider.notifier).setQuery(tag);
                  _searchFocusNode.unfocus();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    border: Border.all(color: isDark ? AppColors.darkBorder : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primaryYellow,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildResultCard({
    required Widget child,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9)),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Expanded(child: child),
            Icon(Ionicons.chevron_forward, size: 20, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessItem(BusinessModel business, ThemeData theme, bool isDark) {
    return _buildResultCard(
      isDark: isDark,
      onTap: () => context.push('/business/${business.id}', extra: business),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'business-image-${business.id}',
            child: SmartImage(
              imageUrl: business.logoUrl ?? business.coverUrl,
              width: 70,
              height: 70,
              borderRadius: 12,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        business.businessName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (business.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Ionicons.checkmark_circle, color: AppColors.success, size: 16),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${business.categoryName ?? 'Category'} • ${business.subcategoryName ?? 'Subcategory'}',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (business.description != null && business.description!.isNotEmpty) ...[
                  Text(
                    business.description!,
                    style: theme.textTheme.bodySmall?.copyWith(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Ionicons.star, color: AppColors.primaryYellow, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            business.ratingValue.toStringAsFixed(1),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.secondaryOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (business.totalReviews != null && business.totalReviews! > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        '(${business.totalReviews})',
                        style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey.shade500),
                      ),
                    ],
                    const Spacer(),
                    if (business.formattedDistance != null)
                      Text(
                        business.formattedDistance!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.primaryYellow,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttractionItem(AttractionModel attraction, ThemeData theme, bool isDark) {
    return _buildResultCard(
      isDark: isDark,
      onTap: () => context.push('/attraction/${attraction.id}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SmartImage(
            imageUrl: attraction.coverImageUrl,
            width: 70,
            height: 70,
            borderRadius: 12,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        attraction.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (attraction.isFeatured) ...[
                      const SizedBox(width: 4),
                      const Icon(Ionicons.star, color: AppColors.primaryYellow, size: 16),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${attraction.category} • ${attraction.city}',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Ionicons.star, color: AppColors.primaryYellow, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            attraction.ratingValue.toStringAsFixed(1),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.secondaryOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (attraction.formattedDistance != null)
                      Text(
                        attraction.formattedDistance!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.primaryYellow,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (attraction.isFree)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Free Entry',
                          style: theme.textTheme.labelSmall?.copyWith(color: AppColors.success, fontSize: 10),
                        ),
                      )
                    else if (attraction.entryFeeValue > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${attraction.currency} ${attraction.entryFee}',
                          style: theme.textTheme.labelSmall?.copyWith(color: AppColors.primaryYellow, fontSize: 10),
                        ),
                      ),
                    const SizedBox(width: 6),
                    if (attraction.difficultyLevel.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          attraction.difficultyLevel,
                          style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey.shade600, fontSize: 10),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferingItem(OfferingModel offering, ThemeData theme, bool isDark) {
    return _buildResultCard(
      isDark: isDark,
      onTap: () {
        if (offering.business != null) {
          context.push('/offering/${offering.business!.id}/${offering.id}');
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SmartImage(
            imageUrl: offering.imageUrl,
            width: 70,
            height: 70,
            borderRadius: 12,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        offering.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (offering.isFeatured) ...[
                      const SizedBox(width: 4),
                      const Icon(Ionicons.star, color: AppColors.primaryYellow, size: 16),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  offering.business != null
                      ? '${offering.business!.businessName} • ${offering.business!.area ?? 'Unknown area'}'
                      : 'Unknown Business',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${offering.currency} ${offering.price}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (offering.business?.distanceKm != null)
                      Text(
                        '${offering.business!.distanceKm!.toStringAsFixed(2)} km',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.primaryYellow,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(ThemeData theme, bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Category Title Shimmer
        const Padding(
          padding: EdgeInsets.only(bottom: 16, left: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SkeletonLoader(
              width: 150,
              height: 24,
              borderRadius: 4,
            ),
          ),
        ),
        // Result Card Shimmers
        for (int i = 0; i < 5; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9)),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(
                  width: 70,
                  height: 70,
                  borderRadius: 12,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonLoader(width: double.infinity, height: 16, borderRadius: 4),
                      SizedBox(height: 8),
                      SkeletonLoader(width: 120, height: 12, borderRadius: 4),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          SkeletonLoader(width: 60, height: 16, borderRadius: 4),
                          Spacer(),
                          SkeletonLoader(width: 50, height: 16, borderRadius: 4),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
