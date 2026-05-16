import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models/category_model.dart';
import '../../../widgets/common/smart_image.dart';

class ServiceChip extends StatelessWidget {
  final CategoryModel category;
  final bool isDark;

  const ServiceChip({
    super.key,
    required this.category,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color bgColor;
    try {
      final hex = category.colorCode.replaceFirst('#', '');
      bgColor = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      bgColor = AppColors.primaryYellow;
    }

    return GestureDetector(
      onTap: () => context.push('/category/${category.id}', extra: category),
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: bgColor.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: category.iconImage != null
                    ? _buildCategoryIcon(category.iconImage!, bgColor)
                    : Icon(Ionicons.grid_outline, color: bgColor, size: 26),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String iconPath, Color color) {
    final isSvg = iconPath.endsWith('.svg');

    if (isSvg) {
      return Icon(Ionicons.grid_outline, color: color, size: 26);
    } else {
      return SmartImage(
        imageUrl: iconPath,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
      );
    }
  }
}
