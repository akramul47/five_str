import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/business_detail_provider.dart';
import '../../../data/models/business_model.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/common/smart_image.dart';
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
    final notifier =
        ref.read(businessDetailProvider(widget.businessId).notifier);
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
          body: Center(child: Text('Error: ${state.error}')));
    }

    String? firstValid(List<String?> items) {
      for (final v in items) {
        if (v != null && v.trim().isNotEmpty) return v;
      }
      return null;
    }

    final coverImage = firstValid([
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
    final description =
        detail?.description ?? widget.initialBusiness?.description;
    final formattedDistance =
        detail?.formattedDistance ?? widget.initialBusiness?.formattedDistance;
    final phoneNumber = detail?.businessPhone;
    final catName = displayData?.category?.name ?? displayData?.categoryName;
    final priceRange = displayData?.priceRange ?? 0;
    final totalReviews = displayData?.totalReviews;

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
                  child: const Icon(Ionicons.chevron_back, color: Colors.black, size: 18),
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
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30)),
                ),
              ),
            ),
            flexibleSpace: LayoutBuilder(builder: (ctx, constraints) {
              final isCollapsed = constraints.biggest.height <=
                  MediaQuery.paddingOf(ctx).top + kToolbarHeight + 40;
              return Stack(fit: StackFit.expand, children: [
                FlexibleSpaceBar(
                  background: Stack(fit: StackFit.expand, children: [
                    Hero(
                      tag: 'business-image-${widget.businessId}',
                      child:
                          SmartImage(imageUrl: coverImage, fit: BoxFit.cover),
                    ),
                    if (isDark)
                      Container(color: Colors.black.withValues(alpha: 0.3)),
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
                            style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1),
                          ),
                          const SizedBox(height: 10),
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(Ionicons.star,
                                    color: AppColors.primaryYellow, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '$ratingValue${totalReviews != null ? ' ($totalReviews)' : ''}',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ]),
                            ),
                            if (priceRange > 0) ...[
                              const SizedBox(width: 8),
                              Text(List.filled(priceRange, '\$').join(''),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ],
                            if (formattedDistance != null) ...[
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(children: [
                                  const Icon(Ionicons.location,
                                      color: Colors.white, size: 12),
                                  const SizedBox(width: 4),
                                  Text(formattedDistance,
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(color: Colors.white)),
                                ]),
                              ),
                            ],
                          ]),
                        ],
                      ),
                    ),
                  ]),
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
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.deepNavy,
                        ),
                      ),
                    ),
                  ),
              ]);
            }),
          ),

          // ── Category + Action Buttons ────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: bgColor,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (catName != null && catName.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            AppColors.primaryYellow.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(catName,
                          style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.primaryYellow,
                              fontWeight: FontWeight.bold)),
                    )
                  else
                    const SizedBox.shrink(),
                  Row(children: [
                    _ActionBtn(
                      icon: Ionicons.call_sharp,
                      color: Colors.blue,
                      opacity: (phoneNumber != null && phoneNumber.isNotEmpty)
                          ? 1.0
                          : 0.45,
                      onTap: (phoneNumber != null && phoneNumber.isNotEmpty)
                          ? () async {
                              final uri = Uri.parse('tel:$phoneNumber');
                              if (await canLaunchUrl(uri)) launchUrl(uri);
                            }
                          : null,
                    ),
                    const SizedBox(width: 12),
                    _ActionBtn(
                      icon: Ionicons.location_sharp,
                      color: Colors.green,
                      onTap: () async {
                        if (detail?.latitude != null &&
                            detail?.longitude != null) {
                          final uri = Uri.parse(
                              'google.navigation:q=${detail!.latitude},${detail!.longitude}');
                          if (await canLaunchUrl(uri)) launchUrl(uri);
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    _ActionBtn(
                        icon: Ionicons.heart,
                        color: AppColors.secondaryOrange),
                  ]),
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
              // Show count only after the menu tab has been visited and loaded
              menuItemCount: (_visitedTabs.contains(1) &&
                      !state.isLoadingOfferings &&
                      state.offerings.isNotEmpty)
                  ? state.offerings.length
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
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final double opacity;

  const _ActionBtn({
    required this.icon,
    required this.color,
    this.onTap,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: opacity,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
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

  const _TabBarDelegate({
    required this.tabController,
    required this.isDark,
    required this.theme,
    this.menuItemCount,
  });

  static const double _h = 64.0;

  @override
  double get minExtent => _h;
  @override
  double get maxExtent => _h;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
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
            borderSide:
                const BorderSide(color: AppColors.primaryYellow, width: 3),
            insets: const EdgeInsets.symmetric(horizontal: 22),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: AppColors.primaryYellow,
          unselectedLabelColor: Colors.grey,
          labelStyle: theme.textTheme.labelMedium
              ?.copyWith(fontWeight: FontWeight.bold),
          unselectedLabelStyle: theme.textTheme.labelMedium,
          tabs: [
            const Tab(
              icon: Icon(Ionicons.information_circle_outline, size: 18),
              text: 'Overview',
            ),
            // Menu tab with optional count badge
            Tab(
              icon: const Icon(Ionicons.restaurant_outline, size: 18),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Menu'),
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
            const Tab(
              icon: Icon(Ionicons.star_outline, size: 18),
              text: 'Ratings',
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
      old.menuItemCount != menuItemCount;
}
