import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';

import '../../../core/constants/assets.dart';
import '../../../core/constants/colors.dart';
import '../../../data/services/location_service.dart';
import '../../providers/location_provider.dart';

// ─── All 64 Bangladesh Districts ─────────────────────────────────────────────

class _District {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String division;

  const _District({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.division,
  });
}

const List<_District> _bangladeshDistricts = [
  _District(
    id: 1,
    name: 'Dhaka',
    latitude: 23.8103,
    longitude: 90.4125,
    division: 'Dhaka',
  ),
  _District(
    id: 2,
    name: 'Chittagong',
    latitude: 22.3569,
    longitude: 91.7832,
    division: 'Chittagong',
  ),
  _District(
    id: 3,
    name: 'Sylhet',
    latitude: 24.8949,
    longitude: 91.8687,
    division: 'Sylhet',
  ),
  _District(
    id: 4,
    name: 'Rajshahi',
    latitude: 24.3745,
    longitude: 88.6042,
    division: 'Rajshahi',
  ),
  _District(
    id: 5,
    name: 'Khulna',
    latitude: 22.8456,
    longitude: 89.5403,
    division: 'Khulna',
  ),
  _District(
    id: 6,
    name: 'Barisal',
    latitude: 22.7010,
    longitude: 90.3535,
    division: 'Barisal',
  ),
  _District(
    id: 7,
    name: 'Rangpur',
    latitude: 25.7439,
    longitude: 89.2752,
    division: 'Rangpur',
  ),
  _District(
    id: 8,
    name: 'Mymensingh',
    latitude: 24.7471,
    longitude: 90.4203,
    division: 'Mymensingh',
  ),
  _District(
    id: 9,
    name: 'Comilla',
    latitude: 23.4682,
    longitude: 91.1788,
    division: 'Chittagong',
  ),
  _District(
    id: 10,
    name: 'Gazipur',
    latitude: 23.9999,
    longitude: 90.4203,
    division: 'Dhaka',
  ),
  _District(
    id: 11,
    name: 'Narayanganj',
    latitude: 23.6238,
    longitude: 90.4990,
    division: 'Dhaka',
  ),
  _District(
    id: 12,
    name: 'Bogra',
    latitude: 24.8465,
    longitude: 89.3775,
    division: 'Rajshahi',
  ),
  _District(
    id: 13,
    name: 'Jessore',
    latitude: 23.1695,
    longitude: 89.2134,
    division: 'Khulna',
  ),
  _District(
    id: 14,
    name: 'Dinajpur',
    latitude: 25.6217,
    longitude: 88.6354,
    division: 'Rangpur',
  ),
  _District(
    id: 15,
    name: 'Kushtia',
    latitude: 23.9013,
    longitude: 89.1206,
    division: 'Khulna',
  ),
  _District(
    id: 16,
    name: 'Pabna',
    latitude: 24.0064,
    longitude: 89.2372,
    division: 'Rajshahi',
  ),
  _District(
    id: 17,
    name: 'Tangail',
    latitude: 24.2513,
    longitude: 89.9167,
    division: 'Dhaka',
  ),
  _District(
    id: 18,
    name: 'Faridpur',
    latitude: 23.6070,
    longitude: 89.8429,
    division: 'Dhaka',
  ),
  _District(
    id: 19,
    name: 'Brahmanbaria',
    latitude: 23.9571,
    longitude: 91.1115,
    division: 'Chittagong',
  ),
  _District(
    id: 20,
    name: 'Noakhali',
    latitude: 22.8696,
    longitude: 91.0995,
    division: 'Chittagong',
  ),
  _District(
    id: 21,
    name: 'Feni',
    latitude: 23.0159,
    longitude: 91.3976,
    division: 'Chittagong',
  ),
  _District(
    id: 22,
    name: 'Lakshmipur',
    latitude: 22.9447,
    longitude: 90.8282,
    division: 'Chittagong',
  ),
  _District(
    id: 23,
    name: "Cox's Bazar",
    latitude: 21.4272,
    longitude: 92.0058,
    division: 'Chittagong',
  ),
  _District(
    id: 24,
    name: 'Rangamati',
    latitude: 22.6533,
    longitude: 92.1734,
    division: 'Chittagong',
  ),
  _District(
    id: 25,
    name: 'Bandarban',
    latitude: 22.1953,
    longitude: 92.2183,
    division: 'Chittagong',
  ),
  _District(
    id: 26,
    name: 'Khagrachhari',
    latitude: 23.1193,
    longitude: 91.9847,
    division: 'Chittagong',
  ),
  _District(
    id: 27,
    name: 'Chandpur',
    latitude: 23.2332,
    longitude: 90.6712,
    division: 'Chittagong',
  ),
  _District(
    id: 28,
    name: 'Moulvibazar',
    latitude: 24.4829,
    longitude: 91.7774,
    division: 'Sylhet',
  ),
  _District(
    id: 29,
    name: 'Habiganj',
    latitude: 24.3745,
    longitude: 91.4156,
    division: 'Sylhet',
  ),
  _District(
    id: 30,
    name: 'Sunamganj',
    latitude: 25.0658,
    longitude: 91.3950,
    division: 'Sylhet',
  ),
  _District(
    id: 31,
    name: 'Narsingdi',
    latitude: 23.9322,
    longitude: 90.7151,
    division: 'Dhaka',
  ),
  _District(
    id: 32,
    name: 'Manikganj',
    latitude: 23.8644,
    longitude: 90.0047,
    division: 'Dhaka',
  ),
  _District(
    id: 33,
    name: 'Munshiganj',
    latitude: 23.5422,
    longitude: 90.5305,
    division: 'Dhaka',
  ),
  _District(
    id: 34,
    name: 'Rajbari',
    latitude: 23.7574,
    longitude: 89.6444,
    division: 'Dhaka',
  ),
  _District(
    id: 35,
    name: 'Madaripur',
    latitude: 23.1641,
    longitude: 90.1896,
    division: 'Dhaka',
  ),
  _District(
    id: 36,
    name: 'Gopalganj',
    latitude: 23.0488,
    longitude: 89.8266,
    division: 'Dhaka',
  ),
  _District(
    id: 37,
    name: 'Shariatpur',
    latitude: 23.2422,
    longitude: 90.4348,
    division: 'Dhaka',
  ),
  _District(
    id: 38,
    name: 'Kishoreganj',
    latitude: 24.4449,
    longitude: 90.7760,
    division: 'Dhaka',
  ),
  _District(
    id: 39,
    name: 'Netrokona',
    latitude: 24.8807,
    longitude: 90.7279,
    division: 'Mymensingh',
  ),
  _District(
    id: 40,
    name: 'Sherpur',
    latitude: 25.0204,
    longitude: 90.0174,
    division: 'Mymensingh',
  ),
  _District(
    id: 41,
    name: 'Jamalpur',
    latitude: 24.9375,
    longitude: 89.9370,
    division: 'Mymensingh',
  ),
  _District(
    id: 42,
    name: 'Sirajganj',
    latitude: 24.4533,
    longitude: 89.7006,
    division: 'Rajshahi',
  ),
  _District(
    id: 43,
    name: 'Natore',
    latitude: 24.4206,
    longitude: 89.0015,
    division: 'Rajshahi',
  ),
  _District(
    id: 44,
    name: 'Joypurhat',
    latitude: 25.0968,
    longitude: 89.0227,
    division: 'Rajshahi',
  ),
  _District(
    id: 45,
    name: 'Chapainawabganj',
    latitude: 24.5965,
    longitude: 88.2775,
    division: 'Rajshahi',
  ),
  _District(
    id: 46,
    name: 'Naogaon',
    latitude: 24.7936,
    longitude: 88.9318,
    division: 'Rajshahi',
  ),
  _District(
    id: 47,
    name: 'Satkhira',
    latitude: 22.7185,
    longitude: 89.0705,
    division: 'Khulna',
  ),
  _District(
    id: 48,
    name: 'Bagerhat',
    latitude: 22.6602,
    longitude: 89.7895,
    division: 'Khulna',
  ),
  _District(
    id: 49,
    name: 'Narail',
    latitude: 23.1728,
    longitude: 89.5126,
    division: 'Khulna',
  ),
  _District(
    id: 50,
    name: 'Chuadanga',
    latitude: 23.6401,
    longitude: 88.8412,
    division: 'Khulna',
  ),
  _District(
    id: 51,
    name: 'Meherpur',
    latitude: 23.7627,
    longitude: 88.6318,
    division: 'Khulna',
  ),
  _District(
    id: 52,
    name: 'Magura',
    latitude: 23.4855,
    longitude: 89.4198,
    division: 'Khulna',
  ),
  _District(
    id: 53,
    name: 'Jhenaidah',
    latitude: 23.5449,
    longitude: 89.1539,
    division: 'Khulna',
  ),
  _District(
    id: 54,
    name: 'Pirojpur',
    latitude: 22.5841,
    longitude: 89.9720,
    division: 'Barisal',
  ),
  _District(
    id: 55,
    name: 'Jhalokati',
    latitude: 22.6406,
    longitude: 90.1987,
    division: 'Barisal',
  ),
  _District(
    id: 56,
    name: 'Patuakhali',
    latitude: 22.3596,
    longitude: 90.3298,
    division: 'Barisal',
  ),
  _District(
    id: 57,
    name: 'Barguna',
    latitude: 22.1596,
    longitude: 90.1115,
    division: 'Barisal',
  ),
  _District(
    id: 58,
    name: 'Bhola',
    latitude: 22.6859,
    longitude: 90.6482,
    division: 'Barisal',
  ),
  _District(
    id: 59,
    name: 'Kurigram',
    latitude: 25.8055,
    longitude: 89.6361,
    division: 'Rangpur',
  ),
  _District(
    id: 60,
    name: 'Lalmonirhat',
    latitude: 25.9923,
    longitude: 89.2847,
    division: 'Rangpur',
  ),
  _District(
    id: 61,
    name: 'Nilphamari',
    latitude: 25.9310,
    longitude: 88.8563,
    division: 'Rangpur',
  ),
  _District(
    id: 62,
    name: 'Gaibandha',
    latitude: 25.3287,
    longitude: 89.5280,
    division: 'Rangpur',
  ),
  _District(
    id: 63,
    name: 'Thakurgaon',
    latitude: 26.0336,
    longitude: 88.4616,
    division: 'Rangpur',
  ),
  _District(
    id: 64,
    name: 'Panchagarh',
    latitude: 26.3411,
    longitude: 88.5541,
    division: 'Rangpur',
  ),
];

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
  List<_District> _filtered = _bangladeshDistricts;
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
          ? _bangladeshDistricts
          : _bangladeshDistricts
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

  void _handleDistrictSelect(_District district) {
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
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          _LocationAppBar(
            isDark: isDark,
            theme: theme,
            searchController: _searchController,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                if (_feedbackMessage != null)
                  _FeedbackBanner(
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
                return _DistrictTile(
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

// ── New App Bar Component ──────────────────────────────────────────────────────

class _LocationAppBar extends StatelessWidget {
  final bool isDark;
  final ThemeData theme;
  final TextEditingController searchController;

  const _LocationAppBar({
    required this.isDark,
    required this.theme,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    final expandedHeight = statusBarHeight + kToolbarHeight + 120.0;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: bgColor,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.primaryYellow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Ionicons.chevron_back,
              color: Colors.black,
              size: 18,
            ),
          ),
        ),
      ),
      flexibleSpace: LayoutBuilder(
        builder: (ctx, constraints) {
          final isCollapsed =
              constraints.biggest.height <=
              statusBarHeight + kToolbarHeight + 36;

          return Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryYellow.withValues(
                        alpha: isDark ? 0.28 : 0.18,
                      ),
                      AppColors.secondaryOrange.withValues(
                        alpha: isDark ? 0.10 : 0.06,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isCollapsed)
                Positioned(
                  top: statusBarHeight + kToolbarHeight + 4,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            AppAssets.locationIcon,
                            width: 33,
                            height: 33,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Select Location',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              color: isDark ? Colors.white : AppColors.deepNavy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SearchBar(
                        controller: searchController,
                        isDark: isDark,
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              if (isCollapsed)
                Positioned(
                  top: statusBarHeight,
                  left: 76,
                  right: 16,
                  height: kToolbarHeight,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select Location',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.deepNavy,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(28),
        child: Container(
          height: 29,
          transform: Matrix4.translationValues(0, 1, 0),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
      ),
    );
  }
}

// ── Search Bar Component ──────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final ThemeData theme;

  const _SearchBar({
    required this.controller,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(
            Ionicons.search,
            color: AppColors.secondaryOrange,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white : AppColors.deepNavy,
              ),
              decoration: InputDecoration(
                hintText: 'Search districts or divisions...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white38 : Colors.grey.shade400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) {
              if (value.text.isEmpty) return const SizedBox(width: 14);
              return GestureDetector(
                onTap: () => controller.clear(),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    Ionicons.close_circle,
                    size: 18,
                    color: Colors.grey.withValues(alpha: 0.7),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── District Tile ────────────────────────────────────────────────────────────

class _DistrictTile extends StatelessWidget {
  final _District district;
  final ThemeData theme;
  final bool isDark;
  final VoidCallback onTap;

  const _DistrictTile({
    required this.district,
    required this.theme,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withValues(
                    alpha: isDark ? 0.15 : 0.1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Image.asset(
                    AppAssets.locationIcon,
                    width: 22,
                    height: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      district.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${district.division} Division',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Ionicons.chevron_forward,
                size: 16,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Feedback Banner ──────────────────────────────────────────────────────────

class _FeedbackBanner extends StatelessWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  const _FeedbackBanner({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isError
        ? AppColors.error.withValues(alpha: 0.1)
        : AppColors.success.withValues(alpha: 0.1);
    final fgColor = isError ? AppColors.error : AppColors.success;
    final icon = isError
        ? Ionicons.warning_outline
        : Ionicons.checkmark_circle_outline;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 5, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fgColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: fgColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: fgColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Ionicons.close, color: fgColor, size: 16),
          ),
        ],
      ),
    );
  }
}
