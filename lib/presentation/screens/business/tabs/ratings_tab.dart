import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../data/models/review_model.dart';
import '../../../widgets/common/smart_image.dart';

class RatingsTab extends StatefulWidget {
  final List<ReviewModel> reviews;
  final bool isLoading;
  final bool hasVisited;
  final bool isDark;
  final ThemeData theme;

  const RatingsTab({
    super.key,
    required this.reviews,
    required this.isLoading,
    required this.hasVisited,
    required this.isDark,
    required this.theme,
  });

  @override
  State<RatingsTab> createState() => _RatingsTabState();
}

class _RatingsTabState extends State<RatingsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!widget.hasVisited || widget.isLoading) {
      return _shimmer(widget.isDark);
    }

    if (widget.reviews.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Ionicons.star_outline,
              size: 48,
              color: widget.isDark ? Colors.white24 : Colors.black26),
          const SizedBox(height: 12),
          Text('No reviews yet',
              style: widget.theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.grey)),
        ]),
      );
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.builder(
        key: const PageStorageKey<String>('ratings_scroll'),
        primary: true,
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
      itemCount: widget.reviews.length,
      itemBuilder: (context, index) => _ReviewCard(
        review: widget.reviews[index],
        isDark: widget.isDark,
        theme: widget.theme,
      ),
    ),
    );
  }

  static Widget _shimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
        children: List.generate(
          4,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 100,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }
}

// ── Review Card ──────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final bool isDark;
  final ThemeData theme;

  const _ReviewCard(
      {required this.review, required this.isDark, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4)),
        ],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (review.user?.profileImage != null)
          SmartImage(
              imageUrl: review.user!.profileImage,
              width: 40,
              height: 40,
              isRound: true)
        else
          const CircleAvatar(radius: 20, child: Icon(Icons.person, size: 20)),
        const SizedBox(width: 14),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.user?.name ?? 'Anonymous',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text(review.createdAt ?? '',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey)),
                    ]),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Ionicons.star, color: Colors.green, size: 12),
                  const SizedBox(width: 4),
                  Text('${review.overallRating}',
                      style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                ]),
              ),
            ]),
            const SizedBox(height: 10),
            Text(
              review.reviewText,
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.4),
            ),
          ]),
        ),
      ]),
    );
  }
}
