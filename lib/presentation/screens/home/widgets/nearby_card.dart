import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../widgets/common/smart_image.dart';
import '../../../widgets/common/star_rating.dart';

class NearbyCard extends StatelessWidget {
  final dynamic business;
  final bool isDark;

  const NearbyCard({
    super.key,
    required this.business,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Format rating to 1 decimal
    final ratingStr = () {
      final r = double.tryParse(business.overallRating.toString()) ?? 0.0;
      return r == 0.0 ? '—' : r.toStringAsFixed(1);
    }();

    // Use model's formatted distance
    final distanceStr = business.formattedDistance;

    return GestureDetector(
      onTap: () => context.push('/business/${business.id}', extra: business),
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
              tag: 'business-image-${business.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: SmartImage(
                  imageUrl: business.coverUrl ?? business.logoUrl,
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
                          business.businessName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (business.categoryName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            business.categoryName,
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
}
