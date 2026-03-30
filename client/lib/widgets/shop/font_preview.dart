// client/lib/widgets/shop/font_preview.dart
import 'package:flutter/material.dart';
import 'package:valence/models/shop_item.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

/// Shows sample text in a font style for the Fonts category in the Shop.
class FontPreview extends StatelessWidget {
  final ShopItem item;
  final bool isEquipped;

  const FontPreview({
    super.key,
    required this.item,
    required this.isEquipped,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final sampleStyle = _sampleStyleForAsset(item.assetKey, tokens);

    return Container(
      padding: const EdgeInsets.all(ValenceSpacing.smMd),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        borderRadius: ValenceRadii.mediumAll,
        border: Border.all(
          color: isEquipped ? colors.accentPrimary : colors.borderDefault,
          width: isEquipped ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.name,
              style: tokens.typography.caption.copyWith(
                  color: colors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: ValenceSpacing.sm),
          Text('The quick brown fox jumps over the lazy dog',
              style: sampleStyle.copyWith(color: colors.textPrimary)),
          const SizedBox(height: ValenceSpacing.xs),
          Text('1,234 XP  ·  Day 42  ·  87%',
              style: sampleStyle.copyWith(
                  color: colors.accentPrimary, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  TextStyle _sampleStyleForAsset(String assetKey, ValenceTokens tokens) {
    return switch (assetKey) {
      'monospace' => tokens.typography.body
          .copyWith(fontFamily: 'monospace', letterSpacing: 0.5),
      'handwritten' =>
        tokens.typography.body.copyWith(fontStyle: FontStyle.italic),
      'serif' => tokens.typography.body.copyWith(fontFamily: 'serif'),
      _ => tokens.typography.body,
    };
  }
}
