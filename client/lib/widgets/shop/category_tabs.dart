// client/lib/widgets/shop/category_tabs.dart
import 'package:flutter/material.dart';
import 'package:valence/models/shop_item.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

/// Horizontal scrolling category tab bar for the Shop screen.
class CategoryTabs extends StatelessWidget {
  final ShopCategory selected;
  final ValueChanged<ShopCategory> onSelected;

  const CategoryTabs({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: ValenceSpacing.md),
        itemCount: ShopCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: ValenceSpacing.sm),
        itemBuilder: (context, index) {
          final category = ShopCategory.values[index];
          final isActive = category == selected;

          return GestureDetector(
            onTap: () => onSelected(category),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ValenceSpacing.md,
                vertical: ValenceSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isActive ? colors.accentPrimary : colors.surfacePrimary,
                borderRadius: ValenceRadii.roundAll,
                border: isActive ? null : Border.all(color: colors.borderDefault),
              ),
              child: Text(
                category.displayName,
                style: tokens.typography.caption.copyWith(
                  color: isActive ? colors.textInverse : colors.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
