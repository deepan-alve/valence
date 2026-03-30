// client/lib/screens/shop/shop_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valence/models/shop_item.dart';
import 'package:valence/providers/shop_provider.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/gamification/rank_badge.dart';
import 'package:valence/widgets/gamification/spark_balance.dart';
import 'package:valence/widgets/gamification/xp_progress.dart';
import 'package:valence/widgets/shop/category_tabs.dart';
import 'package:valence/widgets/shop/font_preview.dart';
import 'package:valence/widgets/shop/shop_item_card.dart';
import 'package:valence/widgets/shop/theme_preview.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShopProvider(),
      child: const _ShopScreenBody(),
    );
  }
}

class _ShopScreenBody extends StatelessWidget {
  const _ShopScreenBody();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final provider = context.watch<ShopProvider>();

    return Scaffold(
      backgroundColor: colors.surfaceBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ValenceSpacing.md, ValenceSpacing.md,
                ValenceSpacing.md, ValenceSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Shop', style: tokens.typography.h1),
                      const Spacer(),
                      SparkBalance(sparks: provider.sparks),
                    ],
                  ),
                  const SizedBox(height: ValenceSpacing.smMd),
                  Row(
                    children: [
                      RankBadge(rank: provider.userRank, compact: true),
                      const SizedBox(width: ValenceSpacing.md),
                      Expanded(
                        child: XPProgress(
                          currentRank: provider.userRank,
                          progress: provider.rankProgress,
                          xpRemaining: provider.xpRemaining,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            CategoryTabs(
              selected: provider.selectedCategory,
              onSelected: provider.selectCategory,
            ),
            const SizedBox(height: ValenceSpacing.smMd),
            Expanded(
              child: _buildItemGrid(context, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemGrid(BuildContext context, ShopProvider provider) {
    final items = provider.currentItems;
    final tokens = context.tokens;

    if (provider.selectedCategory == ShopCategory.fonts) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: ValenceSpacing.md),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: ValenceSpacing.sm),
        itemBuilder: (context, index) {
          final item = items[index];
          final state = _resolveState(item, provider);
          return GestureDetector(
            onTap: () => _handleItemTap(context, item, state, provider),
            child: FontPreview(
              item: item,
              isEquipped: state == ItemState.equipped,
            ),
          );
        },
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: ValenceSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: ValenceSpacing.sm,
        mainAxisSpacing: ValenceSpacing.sm,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final state = _resolveState(item, provider);

        return ShopItemCard(
          item: item,
          state: state,
          onBuy: () => provider.purchaseItem(item.id),
          onEquip: () => provider.equipItem(item.id),
          onTap: () => _handleItemTap(context, item, state, provider),
        );
      },
    );
  }

  ItemState _resolveState(ShopItem item, ShopProvider provider) {
    return item.itemState(
      currentRank: provider.userRank,
      sparks: provider.sparks,
      hasMomentumHabit: provider.hasMomentumHabit,
    );
  }

  void _handleItemTap(
    BuildContext context,
    ShopItem item,
    ItemState state,
    ShopProvider provider,
  ) {
    if (item.category == ShopCategory.themes) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: provider,
            child: ThemePreview(
              item: item,
              state: state,
              onAction: () {
                if (state == ItemState.available) {
                  provider.purchaseItem(item.id);
                } else if (state == ItemState.owned) {
                  provider.equipItem(item.id);
                }
                Navigator.of(context).pop();
              },
              onClose: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      );
      return;
    }

    if (state == ItemState.owned) {
      provider.equipItem(item.id);
    }
  }
}
