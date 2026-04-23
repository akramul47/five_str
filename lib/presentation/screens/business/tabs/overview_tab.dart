import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/colors.dart';
import '../../../../data/models/business_model.dart';

class OverviewTab extends StatefulWidget {
  final BusinessDetailModel? detail;
  final bool isDark;
  final ThemeData theme;
  final bool isLoading;

  const OverviewTab({
    super.key,
    required this.detail,
    required this.isDark,
    required this.theme,
    required this.isLoading,
  });

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.isLoading) return _shimmer(widget.isDark);

    final desc = widget.detail?.description;
    
    // Check if empty
    if ((desc == null || desc.trim().isEmpty) && 
        widget.detail?.latitude == null) {
      return _empty(widget.isDark, widget.theme);
    }

    final hasFollowUs = (widget.detail?.businessPhone?.isNotEmpty ?? false) ||
        (widget.detail?.businessEmail?.isNotEmpty ?? false) ||
        (widget.detail?.website?.isNotEmpty ?? false);

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        key: const PageStorageKey<String>('overview_scroll'),
        primary: true,
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // About Description
          if (desc != null && desc.trim().isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _ExpandableText(
                text: desc,
                style: widget.theme.textTheme.bodyLarge?.copyWith(
                  color: widget.isDark ? Colors.white70 : Colors.black87,
                  height: 1.55,
                ),
                isDark: widget.isDark,
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Location And Contact Section
          _LocationCard(
            detail: widget.detail,
            isDark: widget.isDark,
            theme: widget.theme,
          ),
          
          if (hasFollowUs) ...[
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Follow Us Section
                  Text(
                    'Follow Us',
                    style: widget.theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600, letterSpacing: -0.3),
                  ),
                  const SizedBox(height: 16),
                  _ContactLinks(
                    detail: widget.detail,
                    isDark: widget.isDark,
                    theme: widget.theme,
                  ),
                ],
              ),
            ),
          ],
        ]),
      ),
    );
  }

  static Widget _shimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            5,
            (i) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              height: 16,
              width: i == 4 ? 180 : double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _empty(bool isDark, ThemeData theme) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.info_outline,
            size: 48, color: isDark ? Colors.white24 : Colors.black26),
        const SizedBox(height: 12),
        Text('No details available',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
      ]),
    );
  }
}

// ── Location & Map Card ──────────────────────────────────────────────────────

class _LocationCard extends StatelessWidget {
  final BusinessDetailModel? detail;
  final bool isDark;
  final ThemeData theme;

  const _LocationCard({
    required this.detail,
    required this.isDark,
    required this.theme,
  });

  Future<void> _launchDirections() async {
    final lat = detail?.latitude;
    final lng = detail?.longitude;
    if (lat == null || lng == null) return;
    
    final googleUrl = Uri.parse('google.navigation:q=$lat,$lng');
    final geoUrl = Uri.parse('geo:$lat,$lng?q=$lat,$lng');

    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl);
    } else if (await canLaunchUrl(geoUrl)) {
      await launchUrl(geoUrl);
    } else {
      // Fallback to web google maps
      final webUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
      if (await canLaunchUrl(webUrl)) launchUrl(webUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final address = detail?.fullAddress ?? detail?.address ?? 'Location not available';
    final cardBg = isDark ? const Color(0xFF232A3B) : Colors.grey.shade50;
    
    double? lat = double.tryParse(detail?.latitude ?? '');
    double? lng = double.tryParse(detail?.longitude ?? '');

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ADDRESS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Ionicons.location, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        address,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Ionicons.chevron_forward, 
                        color: isDark ? Colors.white54 : Colors.black54, size: 16),
                  ],
                ),
              ],
            ),
          ),
          
          if (lat != null && lng != null) ...[
            Divider(color: isDark ? Colors.white10 : Colors.black12, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 220,
                  child: Stack(
                    children: [
                      // Map Background
                      FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(lat, lng),
                          initialZoom: 15.0,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none, // Static map look
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.fivestr.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(lat, lng),
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Ionicons.location,
                                  color: Colors.blueAccent,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      // Overlay Info Card
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2B3245) : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.blueAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Ionicons.location, color: Colors.white, size: 12),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      detail?.businessName ?? '',
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        color: isDark ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      address,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.grey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Bottom Actions
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _MapActionBtn(
                              icon: Ionicons.navigate,
                              label: 'Directions',
                              isDark: isDark,
                              onTap: _launchDirections,
                            ),
                            const SizedBox(width: 12),
                            _MapActionBtn(
                              icon: Ionicons.expand,
                              label: 'Expand',
                              isDark: isDark,
                              onTap: () {
                                // For now just open directions, later could open full map screen
                                _launchDirections();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MapActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _MapActionBtn({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2B3245) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.blueAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Contact Links ────────────────────────────────────────────────────────────

class _ContactLinks extends StatelessWidget {
  final BusinessDetailModel? detail;
  final bool isDark;
  final ThemeData theme;

  const _ContactLinks({
    required this.detail,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (detail?.businessPhone != null && detail!.businessPhone!.isNotEmpty)
          _ContactBtn(
            icon: Ionicons.call,
            isDark: isDark,
            onTap: () async {
              final uri = Uri.parse('tel:${detail!.businessPhone}');
              if (await canLaunchUrl(uri)) launchUrl(uri);
            },
          ),
        if (detail?.businessEmail != null && detail!.businessEmail!.isNotEmpty) ...[
          const SizedBox(width: 16),
          _ContactBtn(
            icon: Ionicons.mail,
            isDark: isDark,
            onTap: () async {
              final uri = Uri.parse('mailto:${detail!.businessEmail}');
              if (await canLaunchUrl(uri)) launchUrl(uri);
            },
          ),
        ],
        if (detail?.website != null && detail!.website!.isNotEmpty) ...[
          const SizedBox(width: 16),
          _ContactBtn(
            icon: Ionicons.globe,
            isDark: isDark,
            onTap: () async {
              final url = detail!.website!;
              final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
              if (await canLaunchUrl(uri)) launchUrl(uri);
            },
          ),
        ],
      ],
    );
  }
}

class _ContactBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _ContactBtn({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isDark ? Colors.white : Colors.black87, size: 20),
      ),
    );
  }
}

// ── Expandable Text ──────────────────────────────────────────────────────────

class _ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final bool isDark;
  const _ExpandableText(
      {required this.text, required this.style, required this.isDark});

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AnimatedCrossFade(
        firstChild: Text(widget.text,
            style: widget.style, maxLines: 3, overflow: TextOverflow.ellipsis),
        secondChild: Text(widget.text, style: widget.style),
        crossFadeState:
            _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 200),
      ),
      LayoutBuilder(builder: (context, constraints) {
        final tp = TextPainter(
            text: TextSpan(text: widget.text, style: widget.style),
            maxLines: 3,
            textDirection: TextDirection.ltr)
          ..layout(maxWidth: constraints.maxWidth);
        if (!tp.didExceedMaxLines) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _expanded ? 'Show less' : 'Read more',
              style: const TextStyle(
                  color: AppColors.secondaryOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
        );
      }),
    ]);
  }
}
