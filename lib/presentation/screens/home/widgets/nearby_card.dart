import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../widgets/common/smart_image.dart';
import '../../../widgets/common/star_rating.dart';

class NearbyCard extends StatelessWidget {
  final dynamic business;
  final bool isDark;
  final int index;

  const NearbyCard({
    super.key,
    required this.business,
    required this.isDark,
    required this.index,
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
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          // boxShadow: [
          //   if (!isDark)
          //     BoxShadow(
          //       color: Colors.black.withValues(alpha: 0.06),
          //       blurRadius: 10,
          //       offset: const Offset(0, 7),
          //     ),
          // ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                      child: Column(
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
                    ),
                  ),
                  CustomPaint(
                    painter: _WaveBackgroundPainter(index: index, isDark: isDark),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
                      child: Row(
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
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaveBackgroundPainter extends CustomPainter {
  final int index;
  final bool isDark;

  _WaveBackgroundPainter({required this.index, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    if (isDark) {
      paint.color = AppColors.primaryYellow.withValues(alpha: 0.15);
    } else {
      paint.color = const Color(0xFFEFEAE2); // Slightly muted darker shade
    }

    final path = Path();
    
    final double cardTotalWidth = 162.0; // 150 width + 12 margin
    final double startXOffset = index * cardTotalWidth;
    
    final waveAmplitude = 3.5;
    final waveFrequency = (2 * math.pi) / 220; 
    
    path.moveTo(0, size.height);
    
    double initialY = 4 + (math.sin(startXOffset * waveFrequency) * waveAmplitude) +
                     (math.sin(startXOffset * waveFrequency * 0.4) * waveAmplitude * 0.6);
    path.lineTo(0, initialY);
    
    for (double x = 0; x <= size.width; x += 2) {
      double globalX = startXOffset + x;
      // Combine two sine waves for a "not too perfect" natural look
      double y = 4 + (math.sin(globalX * waveFrequency) * waveAmplitude) +
                     (math.sin(globalX * waveFrequency * 0.4) * waveAmplitude * 0.6);
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaveBackgroundPainter oldDelegate) {
    return oldDelegate.index != index || oldDelegate.isDark != isDark;
  }
}
