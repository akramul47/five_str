import 'dart:math';

import 'package:five_str/core/constants/assets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/business_detail_provider.dart';
import '../../providers/location_provider.dart';
import '../../../data/models/business_model.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/common/smart_image.dart';
import '../../widgets/common/star_rating.dart';
import 'tabs/overview_tab.dart';
import 'tabs/menu_tab.dart';
import 'tabs/ratings_tab.dart';

class BusinessDetailScreen extends ConsumerStatefulWidget {
  final int businessId;
  final BusinessModel? initialBusiness;

  const BusinessDetailScreen({
    super.key,
    required this.businessId,
    this.initialBusiness,
  });

  @override
  ConsumerState<BusinessDetailScreen> createState() =>
      _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends ConsumerState<BusinessDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _visitedTabs = <int>{0};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final idx = _tabController.index;
    if (_visitedTabs.contains(idx)) return;
    setState(() => _visitedTabs.add(idx));
    final notifier = ref.read(
      businessDetailProvider(widget.businessId).notifier,
    );
    if (idx == 1) notifier.loadOfferings(widget.businessId);
    if (idx == 2) notifier.loadReviews(widget.businessId);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(businessDetailProvider(widget.businessId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final detail = state.detail;
    final displayData = detail ?? widget.initialBusiness;

    if (state.error != null && displayData == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: ${state.error}')),
      );
    }

    String? firstValid(List<String?> items) {
      for (final v in items) {
        if (v != null && v.trim().isNotEmpty) return v;
      }
      return null;
    }

    final coverImage =
        firstValid([
          detail?.coverUrl,
          detail?.logoUrl,
          widget.initialBusiness?.coverUrl,
          widget.initialBusiness?.logoUrl,
        ]) ??
        '';
    final businessName =
        detail?.businessName ?? widget.initialBusiness?.businessName ?? '';
    final ratingValue =
        detail?.ratingValue ?? widget.initialBusiness?.ratingValue ?? 0.0;
    // Try distance from model first (available when navigating from home).
    // If unavailable (category/search entry), compute it client-side using
    // the business lat/lng from the detail API + user's known position.
    String? formattedDistance =
        detail?.formattedDistance ?? widget.initialBusiness?.formattedDistance;

    if (formattedDistance == null &&
        detail?.latitude != null &&
        detail?.longitude != null) {
      final userLoc = ref.watch(locationProvider);
      final userCoords = userLoc.apiCoordinates;
      final bizLat = double.tryParse(detail!.latitude!);
      final bizLng = double.tryParse(detail.longitude!);
      if (bizLat != null && bizLng != null) {
        const r = 6371.0; // Earth radius in km
        final dLat = (bizLat - userCoords.latitude) * pi / 180;
        final dLng = (bizLng - userCoords.longitude) * pi / 180;
        final a =
            sin(dLat / 2) * sin(dLat / 2) +
            cos(userCoords.latitude * pi / 180) *
                cos(bizLat * pi / 180) *
                sin(dLng / 2) *
                sin(dLng / 2);
        final c = 2 * atan2(sqrt(a), sqrt(1 - a));
        final km = r * c;
        formattedDistance = km < 1
            ? '${(km * 1000).toStringAsFixed(0)} m'
            : '${km.toStringAsFixed(2)} km';
      }
    }

    final phoneNumber = detail?.businessPhone;
    final catName = displayData?.category?.name ?? displayData?.categoryName;
    final priceRange = displayData?.priceRange ?? 0;
    final totalReviews = displayData?.totalReviews;

    final lowerCat = catName?.toLowerCase() ?? '';

    String offeringsTabName = 'Offerings';
    IconData offeringsTabIcon = Ionicons.grid_outline;
    IconData offeringsTabIconFilled = Ionicons.grid;

    if (lowerCat.contains('restaurant') ||
        lowerCat.contains('food') ||
        lowerCat.contains('cafe') ||
        lowerCat.contains('coffee') ||
        lowerCat.contains('street food') ||
        lowerCat.contains('bakery')) {
      offeringsTabName = 'Menu';
      offeringsTabIcon = Ionicons.fast_food_outline;
      offeringsTabIconFilled = Ionicons.fast_food;
    } else if (lowerCat.contains('clothing') ||
        lowerCat.contains('fashion') ||
        lowerCat.contains('apparel') ||
        lowerCat.contains('store') ||
        lowerCat.contains('shop')) {
      offeringsTabName = 'Products';
      offeringsTabIcon = Ionicons.cube_outline;
      offeringsTabIconFilled = Ionicons.cube;
    } else if (lowerCat.contains('service') ||
        lowerCat.contains('repair') ||
        lowerCat.contains('salon') ||
        lowerCat.contains('spa')) {
      offeringsTabName = 'Services';
      offeringsTabIcon = Ionicons.briefcase_outline;
      offeringsTabIconFilled = Ionicons.briefcase;
    }

    final bgColor = isDark ? AppColors.darkSurface : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // ── Cover Image SliverAppBar ─────────────────────────────
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            forceElevated: innerBoxIsScrolled,
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
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: bgColor,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(30.0),
              child: Container(
                height: 31.0,
                transform: Matrix4.translationValues(0, 1, 0),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
              ),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (ctx, constraints) {
                final isCollapsed =
                    constraints.biggest.height <=
                    MediaQuery.paddingOf(ctx).top + kToolbarHeight + 40;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Hero(
                            tag: 'business-image-${widget.businessId}',
                            child: SmartImage(
                              imageUrl: coverImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (isDark)
                            Container(
                              color: Colors.black.withValues(alpha: 0.3),
                            ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0.4, 1.0],
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.9),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 24,
                            right: 24,
                            bottom: 46,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  businessName,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.1,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.5,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white24,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          StarRating(
                                            rating:
                                                '$ratingValue${totalReviews != null ? ' ($totalReviews)' : ''}',
                                            iconSize: 14,
                                            spacing: 4,
                                            verticalOffset: 2.0,
                                            textStyle: theme
                                                .textTheme
                                                .labelMedium
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (priceRange > 0) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        List.filled(priceRange, '\$').join(''),
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                    if (formattedDistance != null) ...[
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.6,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              WidgetSpan(
                                                alignment:
                                                    PlaceholderAlignment.middle,
                                                child: Transform.translate(
                                                  offset: const Offset(
                                                    0,
                                                    0.5,
                                                  ), // Fine-tune vertical alignment
                                                  child: const Padding(
                                                    padding: EdgeInsets.only(
                                                      right: 4.0,
                                                    ),
                                                    child: Icon(
                                                      Ionicons.location,
                                                      color: Colors.white,
                                                      size: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TextSpan(
                                                text: formattedDistance,
                                                style: theme
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: Colors.white,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCollapsed)
                      Positioned(
                        top: MediaQuery.paddingOf(ctx).top,
                        left: 72,
                        right: 72,
                        height: kToolbarHeight,
                        child: Center(
                          child: Text(
                            businessName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.deepNavy,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // ── Category + Action Buttons ────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: bgColor,
              padding: const EdgeInsets.fromLTRB(24, 2, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (catName != null && catName.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        catName,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.primaryYellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  Row(
                    children: [
                      _PhoneActionBtn(phoneNumber: phoneNumber),
                      if (phoneNumber != null && phoneNumber.isNotEmpty)
                        const SizedBox(width: 12),
                      _ActionBtn(
                        assetPath: AppAssets.locationIcon,
                        color: Colors.green,
                        onTap: () async {
                          if (detail != null &&
                              detail.latitude != null &&
                              detail.longitude != null) {
                            final uri = Uri.parse(
                              'google.navigation:q=${detail.latitude},${detail.longitude}',
                            );
                            if (await canLaunchUrl(uri)) launchUrl(uri);
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      const _FavoriteActionBtn(),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Sticky Tab Bar ───────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              tabController: _tabController,
              isDark: isDark,
              theme: theme,
              offeringsTabName: offeringsTabName,
              offeringsTabIcon: offeringsTabIcon,
              offeringsTabIconFilled: offeringsTabIconFilled,
              isOverviewLoaded: !state.isLoadingDetail && state.detail != null,
              // Show count only after the menu tab has been visited and loaded
              menuItemCount:
                  (_visitedTabs.contains(1) &&
                      !state.isLoadingOfferings &&
                      state.offerings.isNotEmpty)
                  ? state.offerings.length
                  : null,
              reviewsCount:
                  (_visitedTabs.contains(2) &&
                      !state.isLoadingReviews &&
                      state.reviews.isNotEmpty)
                  ? state.reviews.length
                  : null,
            ),
          ),
        ],

        // ── Tab Body (swipeable) ─────────────────────────────────
        body: TabBarView(
          controller: _tabController,
          dragStartBehavior: DragStartBehavior.down,
          children: [
            OverviewTab(
              key: const PageStorageKey<int>(0),
              detail: detail,
              isDark: isDark,
              theme: theme,
              isLoading: state.isLoadingDetail,
            ),
            MenuTab(
              key: const PageStorageKey<int>(1),
              offerings: state.offerings,
              isLoading: state.isLoadingOfferings,
              hasVisited: _visitedTabs.contains(1),
              isDark: isDark,
              theme: theme,
              fallbackLogoUrl: displayData?.logoUrl,
              tabName: offeringsTabName,
              tabIcon: offeringsTabIcon,
            ),
            RatingsTab(
              key: const PageStorageKey<int>(2),
              reviews: state.reviews,
              isLoading: state.isLoadingReviews,
              hasVisited: _visitedTabs.contains(2),
              isDark: isDark,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData? icon;
  final String? assetPath;
  final Color color;
  final VoidCallback? onTap;
  final double opacity;
  final double size;
  final double padding;
  final bool useColorOverlay;

  const _ActionBtn({
    this.icon,
    this.assetPath,
    required this.color,
    this.onTap,
    this.opacity = 1.0,
    this.size = 22.0,
    this.padding = 10.0,
    this.useColorOverlay = false,
  }) : assert(icon != null || assetPath != null);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: opacity,
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: assetPath != null
              ? Image.asset(
                  assetPath!,
                  width: size,
                  height: size,
                  color: useColorOverlay ? color : null,
                )
              : Icon(icon, color: color, size: size),
        ),
      ),
    );
  }
}

class _FavoriteActionBtn extends StatefulWidget {
  const _FavoriteActionBtn();

  @override
  State<_FavoriteActionBtn> createState() => _FavoriteActionBtnState();
}

class _FavoriteActionBtnState extends State<_FavoriteActionBtn>
    with SingleTickerProviderStateMixin {
  bool _isFavorite = false;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    // Quick compress then spring back past 1.0 then settle
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.72,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.72,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_bounceController);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    _bounceController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFavorite,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isFavorite
              ? const Color(0xFFE53935).withValues(alpha: 0.3)
              : AppColors.secondaryOrange.withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Image.asset(
              _isFavorite ? AppAssets.heartIcon : AppAssets.heartOutlineIcon,
              key: ValueKey(_isFavorite),
              width: 26,
              height: 26,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Phone Action Button ───────────────────────────────────────────────────────

class _PhoneActionBtn extends StatefulWidget {
  final String? phoneNumber;
  const _PhoneActionBtn({required this.phoneNumber});

  @override
  State<_PhoneActionBtn> createState() => _PhoneActionBtnState();
}

class _PhoneActionBtnState extends State<_PhoneActionBtn>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final AnimationController _bounceController;
  late final Animation<double> _scaleAnimation;
  bool _didAnimate = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.72,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.72,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_bounceController);

    if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty) {
      _didAnimate = true;
      _entranceController.forward();
      _bounceController.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(_PhoneActionBtn oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hasPhone =
        widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty;
    if (hasPhone && !_didAnimate) {
      _didAnimate = true;
      _entranceController.forward();
      _bounceController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPhone =
        widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty;
    if (!hasPhone && !_didAnimate) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: hasPhone
            ? () async {
                final uri = Uri.parse('tel:${widget.phoneNumber}');
                if (await canLaunchUrl(uri)) launchUrl(uri);
              }
            : null,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Image.asset(
              AppAssets.phoneIcon,
              width: 22,
              height: 22,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sticky Tab Bar Delegate
// ─────────────────────────────────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final bool isDark;
  final ThemeData theme;
  final int? menuItemCount;
  final int? reviewsCount;
  final String offeringsTabName;
  final IconData offeringsTabIcon;
  final IconData offeringsTabIconFilled;
  final bool isOverviewLoaded;

  const _TabBarDelegate({
    required this.tabController,
    required this.isDark,
    required this.theme,
    required this.offeringsTabName,
    required this.offeringsTabIcon,
    required this.offeringsTabIconFilled,
    required this.isOverviewLoaded,
    this.menuItemCount,
    this.reviewsCount,
  });

  static const double _h = 64.0;

  @override
  double get minExtent => _h;
  @override
  double get maxExtent => _h;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: isDark ? AppColors.darkSurface : Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TabBar(
          controller: tabController,
          indicator: UnderlineTabIndicator(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            borderSide: const BorderSide(
              color: AppColors.primaryYellow,
              width: 3,
            ),
            insets: const EdgeInsets.symmetric(horizontal: 22),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: AppColors.primaryYellow,
          unselectedLabelColor: Colors.grey,
          labelStyle: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: theme.textTheme.labelMedium,
          tabs: [
            Tab(
              icon: Icon(
                isOverviewLoaded ? Ionicons.reader : Ionicons.reader_outline,
                size: 18,
              ),
              text: 'Overview',
            ),
            // Menu / Services tab with optional count badge
            Tab(
              icon: Icon(
                menuItemCount != null
                    ? offeringsTabIconFilled
                    : offeringsTabIcon,
                size: 18,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(offeringsTabName),
                  if (menuItemCount != null) ...[
                    const SizedBox(width: 5),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryYellow,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$menuItemCount',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              icon: Icon(
                reviewsCount != null ? Ionicons.star : Ionicons.star_outline,
                size: 18,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Ratings'),
                  if (reviewsCount != null) ...[
                    const SizedBox(width: 5),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryYellow,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$reviewsCount',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) =>
      old.isDark != isDark ||
      old.tabController != tabController ||
      old.menuItemCount != menuItemCount ||
      old.reviewsCount != reviewsCount ||
      old.isOverviewLoaded != isOverviewLoaded;
}
