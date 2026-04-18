import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton loader block used as a placeholder while content loads.
class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final bool isRound;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.isRound = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white, // Shimmer color is determined by baseColor
          borderRadius: isRound
              ? BorderRadius.circular((width ?? height ?? 100) / 2)
              : BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Generic skeleton for a card shape.
class SkeletonCard extends StatelessWidget {
  final double height;
  final double width;

  const SkeletonCard({
    super.key,
    this.height = 200,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(
            height: height * 0.6,
            width: width,
            borderRadius: 12,
          ),
          const SizedBox(height: 12),
          SkeletonLoader(height: 16, width: width * 0.7),
          const SizedBox(height: 8),
          SkeletonLoader(height: 14, width: width * 0.4),
        ],
      ),
    );
  }
}
