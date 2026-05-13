import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';

import '../../../core/constants/assets.dart';
import '../../../core/constants/colors.dart';
import '../../providers/location_provider.dart';

/// Tappable location widget for the Home screen header.
/// Shows current location name + division, chevron, and GPS/manual icon.
/// Tapping opens the location selection screen.
class LocationHeader extends ConsumerWidget {
  const LocationHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/location-selection'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Icon pill ──
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: locationState.isUpdating
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryYellow,
                      ),
                    )
                  : Image.asset(
                      AppAssets.locationIcon,
                      width: 22,
                      height: 22,
                    ),
            ),
          ),
          const SizedBox(width: 10),

          // ── Text column ──
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Location name + chevron
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        locationState.isLoading
                            ? 'Locating…'
                            : locationState.locationName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Ionicons.chevron_down,
                      size: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ],
                ),

                // Division sub-label (optional)
                if (locationState.divisionName != null)
                  Text(
                    '${locationState.divisionName} Division',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.secondaryOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
