import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/districts.dart';
import '../../../data/services/location_service.dart';
import '../../providers/location_provider.dart';
import 'widgets/location_widgets.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class LocationSelectionScreen extends ConsumerStatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  ConsumerState<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState
    extends ConsumerState<LocationSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<District> _filtered = bangladeshDistricts;
  bool _isGettingLocation = false;
  String? _feedbackMessage;
  bool _feedbackIsError = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? bangladeshDistricts
          : bangladeshDistricts
                .where(
                  (d) =>
                      d.name.toLowerCase().contains(q) ||
                      d.division.toLowerCase().contains(q),
                )
                .toList();
    });
  }

  Future<void> _handleUseCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _feedbackMessage = null;
    });

    final result = await ref
        .read(locationProvider.notifier)
        .requestLocationUpdate();

    if (!mounted) return;

    if (result.success) {
      _showFeedback('Current location updated', isError: false);
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) context.pop();
    } else if (result.permissionStatus ==
        LocationPermissionStatus.outsideBangladesh) {
      _showFeedback(
        'Location outside Bangladesh — defaulted to Chittagong.',
        isError: false,
      );
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) context.pop();
    } else {
      _showFeedback(result.message, isError: true);
    }

    setState(() => _isGettingLocation = false);
  }

  void _handleDistrictSelect(District district) {
    HapticFeedback.selectionClick();
    ref
        .read(locationProvider.notifier)
        .setManualLocation(
          ManualLocation(
            name: district.name,
            latitude: district.latitude,
            longitude: district.longitude,
            division: district.division,
          ),
        );
    context.pop();
  }

  void _showFeedback(String message, {required bool isError}) {
    setState(() {
      _feedbackMessage = message;
      _feedbackIsError = isError;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // ── Redesigned App Bar ───────────────────────────────────────────
          LocationAppBar(
            isDark: isDark,
            theme: theme,
            searchController: _searchController,
          ),

          // ── Body Content ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              children: [
                if (_feedbackMessage != null)
                  LocationFeedbackBanner(
                    message: _feedbackMessage!,
                    isError: _feedbackIsError,
                    onDismiss: () => setState(() => _feedbackMessage = null),
                  ),
                _buildGpsButton(theme, isDark),
                const SizedBox(height: 24),
                _buildSectionHeader(theme, 'Suggested Districts'),
              ],
            ),
          ),

          if (_filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(theme, isDark),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final district = _filtered[index];
                return DistrictTile(
                  district: district,
                  theme: theme,
                  isDark: isDark,
                  onTap: () => _handleDistrictSelect(district),
                );
              }, childCount: _filtered.length),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.primaryYellow,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Ionicons.search_outline,
            size: 64,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(height: 16),
          Text(
            'No districts found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark ? Colors.white70 : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for a different area',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildGpsButton(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
      child: GestureDetector(
        onTap: _isGettingLocation ? null : _handleUseCurrentLocation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: _isGettingLocation
                ? null
                : const LinearGradient(
                    colors: [Color(0xFFFFC554), Color(0xFFFFAD1D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: _isGettingLocation
                ? (isDark ? AppColors.darkSurface : Colors.grey.shade100)
                : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isGettingLocation
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primaryYellow.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _isGettingLocation
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _isGettingLocation
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primaryYellow,
                          ),
                        )
                      : const Icon(
                          Ionicons.locate,
                          color: Colors.white,
                          size: 24,
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isGettingLocation
                          ? 'Getting your location…'
                          : 'Use Current Location',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: _isGettingLocation
                            ? (isDark ? Colors.white54 : Colors.black45)
                            : Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isGettingLocation
                          ? 'Please wait a moment'
                          : 'Find my district using GPS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _isGettingLocation
                            ? (isDark ? Colors.white24 : Colors.black26)
                            : Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (!_isGettingLocation)
                const Icon(
                  Ionicons.chevron_forward,
                  color: Colors.white,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
