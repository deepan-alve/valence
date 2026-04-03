// client/lib/widgets/shop/shop_item_card.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/models/shop_item.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

class ShopItemCard extends StatelessWidget {
  final ShopItem item;
  final ItemState state;
  final VoidCallback onBuy;
  final VoidCallback onEquip;
  final VoidCallback onTap;

  const ShopItemCard({
    super.key,
    required this.item,
    required this.state,
    required this.onBuy,
    required this.onEquip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final isLocked = state == ItemState.lockedByRank ||
        state == ItemState.lockedByMomentum;
    final isEquipped = state == ItemState.equipped;

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfacePrimary,
          borderRadius: ValenceRadii.mediumAll,
          border: Border.all(
            color: isEquipped ? colors.accentPrimary : colors.borderDefault,
            width: isEquipped ? 2 : 1,
          ),
        ),
        child: Opacity(
          opacity: isLocked ? 0.5 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPreview(tokens),
              Padding(
                padding: const EdgeInsets.all(ValenceSpacing.smMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: tokens.typography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: ValenceSpacing.xs),
                    _buildAction(tokens),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(ValenceTokens tokens) {
    final colors = tokens.colors;
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ValenceRadii.medium),
        ),
      ),
      child: Center(
        child: Icon(
          _iconForCategory(item.category),
          size: 32,
          color: state == ItemState.equipped
              ? colors.accentPrimary
              : colors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildAction(ValenceTokens tokens) {
    final colors = tokens.colors;
    return switch (state) {
      ItemState.equipped => Row(
          children: [
            Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                size: 14, color: colors.accentSuccess),
            const SizedBox(width: ValenceSpacing.xs),
            Text('Equipped',
                style: tokens.typography.caption.copyWith(
                    color: colors.accentSuccess, fontWeight: FontWeight.w600)),
          ],
        ),
      ItemState.owned => GestureDetector(
          onTap: onEquip,
          child: Text('Equip',
              style: tokens.typography.caption.copyWith(
                  color: colors.accentPrimary, fontWeight: FontWeight.w600)),
        ),
      ItemState.available => GestureDetector(
          onTap: onBuy,
          child: Row(
            children: [
              Icon(PhosphorIcons.lightning(PhosphorIconsStyle.fill),
                  size: 12, color: colors.accentWarning),
              const SizedBox(width: 2),
              Text('${item.sparkCost}',
                  style: tokens.typography.caption.copyWith(
                      color: colors.accentWarning, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ItemState.tooExpensive => Row(
          children: [
            Icon(PhosphorIcons.lightning(PhosphorIconsStyle.fill),
                size: 12, color: colors.accentError),
            const SizedBox(width: 2),
            Text('${item.sparkCost}',
                style: tokens.typography.caption.copyWith(
                    color: colors.accentError, fontWeight: FontWeight.w600)),
          ],
        ),
      ItemState.lockedByRank => Text(
          'Requires ${item.minRank.displayName}',
          style: tokens.typography.caption.copyWith(
              color: colors.textSecondary, fontStyle: FontStyle.italic),
        ),
      ItemState.lockedByMomentum => Text(
          'Requires Momentum (21d)',
          style: tokens.typography.caption.copyWith(
              color: colors.textSecondary, fontStyle: FontStyle.italic),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
    };
  }

  IconData _iconForCategory(ShopCategory category) {
    return switch (category) {
      ShopCategory.themes => PhosphorIcons.palette(),
      ShopCategory.flames => PhosphorIcons.fire(),
      ShopCategory.animations => PhosphorIcons.sparkle(),
      ShopCategory.cardStyles => PhosphorIcons.cards(),
      ShopCategory.fonts => PhosphorIcons.textAa(),
      ShopCategory.patterns => PhosphorIcons.circlesThree(),
      ShopCategory.appIcons => PhosphorIcons.appWindow(),
    };
  }
}
