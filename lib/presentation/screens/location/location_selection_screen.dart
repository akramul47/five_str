import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';

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
  _District(id: 1,  name: 'Dhaka',           latitude: 23.8103, longitude: 90.4125, division: 'Dhaka'),
  _District(id: 2,  name: 'Chittagong',       latitude: 22.3569, longitude: 91.7832, division: 'Chittagong'),
  _District(id: 3,  name: 'Sylhet',           latitude: 24.8949, longitude: 91.8687, division: 'Sylhet'),
  _District(id: 4,  name: 'Rajshahi',         latitude: 24.3745, longitude: 88.6042, division: 'Rajshahi'),
  _District(id: 5,  name: 'Khulna',           latitude: 22.8456, longitude: 89.5403, division: 'Khulna'),
  _District(id: 6,  name: 'Barisal',          latitude: 22.7010, longitude: 90.3535, division: 'Barisal'),
  _District(id: 7,  name: 'Rangpur',          latitude: 25.7439, longitude: 89.2752, division: 'Rangpur'),
  _District(id: 8,  name: 'Mymensingh',       latitude: 24.7471, longitude: 90.4203, division: 'Mymensingh'),
  _District(id: 9,  name: 'Comilla',          latitude: 23.4682, longitude: 91.1788, division: 'Chittagong'),
  _District(id: 10, name: 'Gazipur',          latitude: 23.9999, longitude: 90.4203, division: 'Dhaka'),
  _District(id: 11, name: 'Narayanganj',      latitude: 23.6238, longitude: 90.4990, division: 'Dhaka'),
  _District(id: 12, name: 'Bogra',            latitude: 24.8465, longitude: 89.3775, division: 'Rajshahi'),
  _District(id: 13, name: 'Jessore',          latitude: 23.1695, longitude: 89.2134, division: 'Khulna'),
  _District(id: 14, name: 'Dinajpur',         latitude: 25.6217, longitude: 88.6354, division: 'Rangpur'),
  _District(id: 15, name: 'Kushtia',          latitude: 23.9013, longitude: 89.1206, division: 'Khulna'),
  _District(id: 16, name: 'Pabna',            latitude: 24.0064, longitude: 89.2372, division: 'Rajshahi'),
  _District(id: 17, name: 'Tangail',          latitude: 24.2513, longitude: 89.9167, division: 'Dhaka'),
  _District(id: 18, name: 'Faridpur',         latitude: 23.6070, longitude: 89.8429, division: 'Dhaka'),
  _District(id: 19, name: 'Brahmanbaria',     latitude: 23.9571, longitude: 91.1115, division: 'Chittagong'),
  _District(id: 20, name: 'Noakhali',         latitude: 22.8696, longitude: 91.0995, division: 'Chittagong'),
  _District(id: 21, name: 'Feni',             latitude: 23.0159, longitude: 91.3976, division: 'Chittagong'),
  _District(id: 22, name: 'Lakshmipur',       latitude: 22.9447, longitude: 90.8282, division: 'Chittagong'),
  _District(id: 23, name: "Cox's Bazar",      latitude: 21.4272, longitude: 92.0058, division: 'Chittagong'),
  _District(id: 24, name: 'Rangamati',        latitude: 22.6533, longitude: 92.1734, division: 'Chittagong'),
  _District(id: 25, name: 'Bandarban',        latitude: 22.1953, longitude: 92.2183, division: 'Chittagong'),
  _District(id: 26, name: 'Khagrachhari',     latitude: 23.1193, longitude: 91.9847, division: 'Chittagong'),
  _District(id: 27, name: 'Chandpur',         latitude: 23.2332, longitude: 90.6712, division: 'Chittagong'),
  _District(id: 28, name: 'Moulvibazar',      latitude: 24.4829, longitude: 91.7774, division: 'Sylhet'),
  _District(id: 29, name: 'Habiganj',         latitude: 24.3745, longitude: 91.4156, division: 'Sylhet'),
  _District(id: 30, name: 'Sunamganj',        latitude: 25.0658, longitude: 91.3950, division: 'Sylhet'),
  _District(id: 31, name: 'Narsingdi',        latitude: 23.9322, longitude: 90.7151, division: 'Dhaka'),
  _District(id: 32, name: 'Manikganj',        latitude: 23.8644, longitude: 90.0047, division: 'Dhaka'),
  _District(id: 33, name: 'Munshiganj',       latitude: 23.5422, longitude: 90.5305, division: 'Dhaka'),
  _District(id: 34, name: 'Rajbari',          latitude: 23.7574, longitude: 89.6444, division: 'Dhaka'),
  _District(id: 35, name: 'Madaripur',        latitude: 23.1641, longitude: 90.1896, division: 'Dhaka'),
  _District(id: 36, name: 'Gopalganj',        latitude: 23.0488, longitude: 89.8266, division: 'Dhaka'),
  _District(id: 37, name: 'Shariatpur',       latitude: 23.2422, longitude: 90.4348, division: 'Dhaka'),
  _District(id: 38, name: 'Kishoreganj',      latitude: 24.4449, longitude: 90.7760, division: 'Dhaka'),
  _District(id: 39, name: 'Netrokona',        latitude: 24.8807, longitude: 90.7279, division: 'Mymensingh'),
  _District(id: 40, name: 'Sherpur',          latitude: 25.0204, longitude: 90.0174, division: 'Mymensingh'),
  _District(id: 41, name: 'Jamalpur',         latitude: 24.9375, longitude: 89.9370, division: 'Mymensingh'),
  _District(id: 42, name: 'Sirajganj',        latitude: 24.4533, longitude: 89.7006, division: 'Rajshahi'),
  _District(id: 43, name: 'Natore',           latitude: 24.4206, longitude: 89.0015, division: 'Rajshahi'),
  _District(id: 44, name: 'Joypurhat',        latitude: 25.0968, longitude: 89.0227, division: 'Rajshahi'),
  _District(id: 45, name: 'Chapainawabganj',  latitude: 24.5965, longitude: 88.2775, division: 'Rajshahi'),
  _District(id: 46, name: 'Naogaon',          latitude: 24.7936, longitude: 88.9318, division: 'Rajshahi'),
  _District(id: 47, name: 'Satkhira',         latitude: 22.7185, longitude: 89.0705, division: 'Khulna'),
  _District(id: 48, name: 'Bagerhat',         latitude: 22.6602, longitude: 89.7895, division: 'Khulna'),
  _District(id: 49, name: 'Narail',           latitude: 23.1728, longitude: 89.5126, division: 'Khulna'),
  _District(id: 50, name: 'Chuadanga',        latitude: 23.6401, longitude: 88.8412, division: 'Khulna'),
  _District(id: 51, name: 'Meherpur',         latitude: 23.7627, longitude: 88.6318, division: 'Khulna'),
  _District(id: 52, name: 'Magura',           latitude: 23.4855, longitude: 89.4198, division: 'Khulna'),
  _District(id: 53, name: 'Jhenaidah',        latitude: 23.5449, longitude: 89.1539, division: 'Khulna'),
  _District(id: 54, name: 'Pirojpur',         latitude: 22.5841, longitude: 89.9720, division: 'Barisal'),
  _District(id: 55, name: 'Jhalokati',        latitude: 22.6406, longitude: 90.1987, division: 'Barisal'),
  _District(id: 56, name: 'Patuakhali',       latitude: 22.3596, longitude: 90.3298, division: 'Barisal'),
  _District(id: 57, name: 'Barguna',          latitude: 22.1596, longitude: 90.1115, division: 'Barisal'),
  _District(id: 58, name: 'Bhola',            latitude: 22.6859, longitude: 90.6482, division: 'Barisal'),
  _District(id: 59, name: 'Kurigram',         latitude: 25.8055, longitude: 89.6361, division: 'Rangpur'),
  _District(id: 60, name: 'Lalmonirhat',      latitude: 25.9923, longitude: 89.2847, division: 'Rangpur'),
  _District(id: 61, name: 'Nilphamari',       latitude: 25.9310, longitude: 88.8563, division: 'Rangpur'),
  _District(id: 62, name: 'Gaibandha',        latitude: 25.3287, longitude: 89.5280, division: 'Rangpur'),
  _District(id: 63, name: 'Thakurgaon',       latitude: 26.0336, longitude: 88.4616, division: 'Rangpur'),
  _District(id: 64, name: 'Panchagarh',       latitude: 26.3411, longitude: 88.5541, division: 'Rangpur'),
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
              .where((d) =>
                  d.name.toLowerCase().contains(q) ||
                  d.division.toLowerCase().contains(q))
              .toList();
    });
  }

  Future<void> _handleUseCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _feedbackMessage = null;
    });

    final result =
        await ref.read(locationProvider.notifier).requestLocationUpdate();

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
    ref.read(locationProvider.notifier).setManualLocation(
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Column(
        children: [
          // ── Gradient Header ──
          _buildHeader(theme, isDark),

          // ── Feedback Banner ──
          if (_feedbackMessage != null)
            _FeedbackBanner(
              message: _feedbackMessage!,
              isError: _feedbackIsError,
              onDismiss: () => setState(() => _feedbackMessage = null),
            ),

          // ── Use GPS Button ──
          _buildGpsButton(theme, isDark),

          // ── Section label ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Icon(
                  Ionicons.list_outline,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 6),
                Text(
                  'Or select a district (${_filtered.length})',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          // ── Districts List ──
          Expanded(
            child: _filtered.isEmpty
                ? _buildEmptySearch(theme)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _DistrictTile(
                      district: _filtered[i],
                      theme: theme,
                      isDark: isDark,
                      onTap: () => _handleDistrictSelect(_filtered[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFAD1D), // primaryYellow
            Color(0xFFDA6317), // secondaryOrange
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + title
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Ionicons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Ionicons.location, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Location',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Choose your location or use GPS',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.deepNavy,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search districts or divisions…',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade400,
                    ),
                    prefixIcon: const Icon(
                      Ionicons.search_outline,
                      color: AppColors.secondaryOrange,
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Ionicons.close_circle,
                              color: Colors.grey,
                              size: 18,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              FocusScope.of(context).unfocus();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGpsButton(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        onTap: _isGettingLocation ? null : _handleUseCurrentLocation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: _isGettingLocation
                ? null
                : const LinearGradient(
                    colors: [Color(0xFFFFAD1D), Color(0xFFDA6317)],
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
                            color: isDark
                                ? AppColors.primaryYellow
                                : AppColors.secondaryOrange,
                          ),
                        )
                      : const Icon(Ionicons.locate, color: Colors.white, size: 24),
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
                      'Detect location automatically via GPS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _isGettingLocation
                            ? (isDark ? Colors.white38 : Colors.black26)
                            : Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              if (!_isGettingLocation)
                Icon(
                  Ionicons.chevron_forward,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySearch(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Ionicons.search_outline,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No districts found',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try searching by district or division name',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
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
        margin: const EdgeInsets.only(bottom: 8),
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
                  color: AppColors.primaryYellow.withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    Ionicons.location_outline,
                    color: AppColors.secondaryOrange,
                    size: 18,
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
    final icon = isError ? Ionicons.warning_outline : Ionicons.checkmark_circle_outline;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
