// client/lib/widgets/gamification/spark_balance.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

/// Displays the user's Sparks balance with a spark icon.
class SparkBalance extends StatelessWidget {
  final int sparks;
  final bool large;

  const SparkBalance({
    super.key,
    required this.sparks,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final textStyle = large
        ? tokens.typography.numbersDisplay
        : tokens.typography.numbersBody;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          PhosphorIcons.lightning(PhosphorIconsStyle.fill),
          size: large ? 32 : 20,
          color: colors.accentWarning,
        ),
        const SizedBox(width: ValenceSpacing.sm),
        Text(
          _formatNumber(sparks),
          style: textStyle.copyWith(color: colors.accentWarning),
        ),
      ],
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}k';
    }
    return n.toString();
  }
}
