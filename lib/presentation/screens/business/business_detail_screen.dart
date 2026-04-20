import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/business_detail_provider.dart';
import '../../../data/models/business_model.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/common/smart_image.dart';

class BusinessDetailScreen extends ConsumerWidget {
  final int businessId;
  final BusinessModel? initialBusiness;

  const BusinessDetailScreen({
    super.key,
    required this.businessId,
    this.initialBusiness,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(businessDetailProvider(businessId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final detail = state.detail;
    final displayData = detail ?? initialBusiness;

    if (state.isLoading && displayData == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryYellow),
        ),
      );
    }

    if (state.error != null && displayData == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: ${state.error}')),
      );
    }

    String? getFirstValid(List<String?> items) {
      for (final item in items) {
        if (item != null && item.trim().isNotEmpty) return item;
      }
      return null;
    }

    final coverImage = getFirstValid([
      detail?.coverUrl,
      detail?.logoUrl,
      initialBusiness?.coverUrl,
      initialBusiness?.logoUrl,
    ]) ?? '';
    
    debugPrint('DETAIL COVER IMAGE RESOLVED: $coverImage');
    if (initialBusiness != null) {
      debugPrint('INITIAL BUSINESS PASS DETECTED: ${initialBusiness!.businessName}');
    }
    final businessName = detail?.businessName ?? initialBusiness?.businessName ?? 'Loading...';
    final ratingValue = detail?.ratingValue ?? initialBusiness?.ratingValue ?? 0.0;
    final description = detail?.description ?? initialBusiness?.description;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            iconTheme: IconThemeData(
              color: isDark ? AppColors.primaryYellow : AppColors.deepNavy,
            ),
            backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'business-image-$businessId',
                    child: SmartImage(
                      imageUrl: coverImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Dark overlay if dark mode for better contrast
                  if (isDark)
                    Container(
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  // The rounded overlapping trick
                  Positioned(
                    bottom: -1,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Pills Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Popular',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.primaryYellow,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              // Get Directions Logic
                              if (detail?.latitude != null &&
                                  detail?.longitude != null) {
                                final uri = Uri.parse(
                                    'google.navigation:q=${detail!.latitude},${detail!.longitude}');
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Ionicons.location_sharp,
                                color: Colors.green,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryOrange.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Ionicons.heart,
                              color: AppColors.secondaryOrange,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    businessName,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Subtitles
                  Row(
                    children: [
                      const Icon(Ionicons.star,
                          size: 16, color: AppColors.primaryYellow),
                      const SizedBox(width: 4),
                      Text(
                        '$ratingValue Rating',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Ionicons.location_outline,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        displayData?.formattedDistance ?? '--',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  if (description != null && description.isNotEmpty)
                    Text(
                      description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.5,
                      ),
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Popular Menu
          if (state.offerings.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Popular Menu',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'View All',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.offerings.length,
                  itemBuilder: (context, index) {
                    final item = state.offerings[index];
                    return Container(
                      width: 140,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBackground : Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                          SmartImage(
                            imageUrl: item.imageUrl ?? displayData!.logoUrl ?? '',
                            width: 60,
                            height: 60,
                            isRound: true,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.price} \$',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],

          // Testimonials
          if (state.reviews.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Testimonials',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final review = state.reviews[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBackground : Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (review.user?.profileImage != null)
                            SmartImage(
                              imageUrl: review.user!.profileImage,
                              width: 40,
                              height: 40,
                              isRound: true,
                            )
                          else
                            const CircleAvatar(
                              radius: 20,
                              child: Icon(Icons.person),
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          review.user?.name ?? 'Anonymous',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          review.createdAt ?? '',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Ionicons.star, color: Colors.green, size: 12),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${review.overallRating}',
                                            style: theme.textTheme.labelMedium?.copyWith(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  review.reviewText,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDark ? Colors.white70 : Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: state.reviews.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ],
      ),
    );
  }
}
