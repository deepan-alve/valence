// client/lib/widgets/shop/theme_preview.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/models/shop_item.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/core/valence_button.dart';

/// Full-screen mock preview of a theme.
class ThemePreview extends StatelessWidget {
  final ShopItem item;
  final ItemState state;
  final VoidCallback onAction;
  final VoidCallback onClose;

  const ThemePreview({
    super.key,
    required this.item,
    required this.state,
    required this.onAction,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return Scaffold(
      backgroundColor: colors.surfaceBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(ValenceSpacing.md),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onClose,
                    child: Icon(PhosphorIcons.x(), color: colors.textPrimary),
                  ),
                  const Spacer(),
                  Text(item.name, style: tokens.typography.h3),
                  const Spacer(),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(ValenceSpacing.md),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surfacePrimary,
                    borderRadius: ValenceRadii.largeAll,
                    border: Border.all(color: colors.borderDefault),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: ValenceSpacing.lg),
                      Text('Good morning, Diana', style: tokens.typography.h2),
                      const SizedBox(height: ValenceSpacing.sm),
                      Text('4/6 habits done. Two more for a perfect day.',
                          style: tokens.typography.body.copyWith(
                              color: colors.textSecondary)),
                      const SizedBox(height: ValenceSpacing.lg),
                      for (var i = 0; i < 3; i++) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: ValenceSpacing.md,
                              vertical: ValenceSpacing.xs),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: colors.surfaceElevated,
                              borderRadius: ValenceRadii.mediumAll,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: ValenceSpacing.md),
                        child: Text(item.description,
                            style: tokens.typography.caption.copyWith(
                                color: colors.textSecondary),
                            textAlign: TextAlign.center),
                      ),
                      const SizedBox(height: ValenceSpacing.md),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(ValenceSpacing.md),
              child: ValenceButton(
                label: state == ItemState.equipped
                    ? 'Equipped'
                    : state == ItemState.owned
                        ? 'Equip'
                        : 'Buy & Apply',
                onPressed: state == ItemState.equipped ? null : onAction,
                fullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
