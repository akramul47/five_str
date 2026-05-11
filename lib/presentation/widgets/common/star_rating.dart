import 'package:flutter/material.dart';
import '../../../core/constants/assets.dart';

class StarRating extends StatelessWidget {
  final String rating;
  final TextStyle? textStyle;
  final double iconSize;
  final double spacing;
  final Color? iconColor;
  final double verticalOffset;

  const StarRating({
    super.key,
    required this.rating,
    this.textStyle,
    this.iconSize = 12.0,
    this.spacing = 2.0,
    this.iconColor,
    this.verticalOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: EdgeInsets.only(right: spacing, bottom: verticalOffset),
              child: Image.asset(
                AppAssets.starIcon,
                width: iconSize,
                height: iconSize,
                color: iconColor,
              ),
            ),
          ),
          TextSpan(
            text: rating,
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
