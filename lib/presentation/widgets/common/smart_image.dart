import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

    String formattedUrl = imageUrl!;
    
    // Fix relative image paths returned by Laravel
    if (!formattedUrl.startsWith('http') && !formattedUrl.startsWith('file://')) {
      String baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.5str.xyz';
      if (baseUrl.trim().isEmpty) {
        baseUrl = 'https://api.5str.xyz';
      }
      
      // Ensure baseUrl doesn't end with a slash if we're adding one
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }
      
      // Laravel standardizes public uploads in the /storage/ directory
      if (!formattedUrl.startsWith('storage/')) {
        if (formattedUrl.startsWith('/')) {
          formattedUrl = formattedUrl.substring(1);
        }
        formattedUrl = 'storage/$formattedUrl';
      }
      formattedUrl = '$baseUrl/$formattedUrl';
    }

    return ClipRRect(
      borderRadius: isRound
          ? BorderRadius.circular((width ?? height ?? 100) / 2)
          : BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: formattedUrl,
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
