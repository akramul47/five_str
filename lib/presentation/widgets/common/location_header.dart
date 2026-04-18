import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';

import '../../providers/location_provider.dart';

/// Top bar component showing current location and allowing it to be changed.
class LocationHeader extends ConsumerWidget {
  const LocationHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        // In a real app, this would open the location selection modal
        // context.push('/location-selector');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location picker opened')),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Ionicons.location_outline,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current Location',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      locationState.isLoading
                          ? 'Locating...'
                          : locationState.locationName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Ionicons.chevron_down,
                      size: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
