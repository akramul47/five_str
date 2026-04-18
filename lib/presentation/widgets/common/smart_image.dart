import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'skeleton_loader.dart';

/// A robust image widget that handles network images with caching,
/// loading states (shimmer), and fallback/error images.
class SmartImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final bool isRound;

  const SmartImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.isRound = false,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder(context);
    }

    // In a real app, you might want to prepend your base URL here
    // if the backend returns relative paths.
    
    return ClipRRect(
      borderRadius: isRound
          ? BorderRadius.circular((width ?? height ?? 100) / 2)
          : BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => SkeletonLoader(
          width: width,
          height: height,
          borderRadius: borderRadius,
          isRound: isRound,
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(context),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: isRound
            ? BorderRadius.circular((width ?? height ?? 100) / 2)
            : BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        size: (width != null && height != null)
            ? (width! < height! ? width! : height!) * 0.4
            : 24,
      ),
    );
  }
}
