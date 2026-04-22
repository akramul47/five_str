import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/colors.dart';

class OverviewTab extends StatefulWidget {
  final String? description;
  final bool isDark;
  final ThemeData theme;
  final bool isLoading;

  const OverviewTab({
    super.key,
    required this.description,
    required this.isDark,
    required this.theme,
    required this.isLoading,
  });

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) return _shimmer(widget.isDark);

    final desc = widget.description;
    if (desc == null || desc.trim().isEmpty) {
      return _empty(widget.isDark, widget.theme);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'About',
          style: widget.theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.3),
        ),
        const SizedBox(height: 12),
        _ExpandableText(
          text: desc,
          style: widget.theme.textTheme.bodyLarge?.copyWith(
            color: widget.isDark ? Colors.white70 : Colors.black87,
            height: 1.55,
          ),
          isDark: widget.isDark,
        ),
      ]),
    );
  }

  static Widget _shimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
                5,
                (i) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      height: 16,
                      width: i == 4 ? 180 : double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)),
                    ))),
      ),
    );
  }

  static Widget _empty(bool isDark, ThemeData theme) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.info_outline,
            size: 48,
            color: isDark ? Colors.white24 : Colors.black26),
        const SizedBox(height: 12),
        Text('No description available',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: Colors.grey)),
      ]),
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
              style: TextStyle(
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
