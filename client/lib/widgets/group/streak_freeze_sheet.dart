import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/group_provider.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/core/valence_button.dart';
import 'package:valence/widgets/shared/valence_toast.dart';

/// Bottom sheet for streak freeze confirmation.
///
/// Displays the cost, user's current balance, and handles insufficient
/// points / already-active-today states.
///
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   builder: (_) => const StreakFreezeSheet(),
/// );
/// ```
class StreakFreezeSheet extends StatelessWidget {
  const StreakFreezeSheet({super.key});

  /// Convenience: open as a modal bottom sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const StreakFreezeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final typography = tokens.typography;
    final groupProvider = context.watch<GroupProvider>();
    final copy = groupProvider.copy;

    final freezeActive = groupProvider.freezeActiveToday;
    final cost = groupProvider.freezeCost;
    final balance = groupProvider.consistencyPoints;
    final canAfford = groupProvider.canAffordFreeze;
    final shortfall = canAfford ? 0 : cost - balance;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(ValenceSpacing.md),
        padding: const EdgeInsets.fromLTRB(
          ValenceSpacing.lg,
          ValenceSpacing.lg,
          ValenceSpacing.lg,
          ValenceSpacing.md,
        ),
        decoration: BoxDecoration(
          color: colors.surfacePrimary,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: ValenceSpacing.lg),

            // Header row: snowflake icon + title
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.accentSecondary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    PhosphorIconsRegular.snowflake,
                    color: colors.accentSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: ValenceSpacing.sm),
                Expanded(
                  child: Text(
                    copy.freezeSheetTitle,
                    style: typography.h2.copyWith(color: colors.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ValenceSpacing.sm),

            // Body copy
            Text(
              copy.freezeSheetBody(cost),
              style: typography.body.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: ValenceSpacing.md),

            // Cost + balance info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(ValenceSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceSunken,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.borderDefault),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    label: 'Cost',
                    value: '$cost consistency points',
                    valueColor: colors.textPrimary,
                    tokens: tokens,
                  ),
                  const SizedBox(height: ValenceSpacing.xs),
                  _InfoRow(
                    label: 'Your balance',
                    value: '$balance points',
                    valueColor: canAfford ? colors.accentSuccess : colors.accentError,
                    tokens: tokens,
                  ),
                ],
              ),
            ),

            // Insufficient points warning
            if (!canAfford && !freezeActive) ...[
              const SizedBox(height: ValenceSpacing.sm),
              Row(
                children: [
                  Icon(Icons.error_outline, size: 16, color: colors.accentError),
                  const SizedBox(width: ValenceSpacing.xs),
                  Expanded(
                    child: Text(
                      copy.freezeInsufficientPoints(shortfall),
                      style: typography.caption.copyWith(color: colors.accentError),
                    ),
                  ),
                ],
              ),
            ],

            // Freeze already active
            if (freezeActive) ...[
              const SizedBox(height: ValenceSpacing.sm),
              Row(
                children: [
                  Icon(PhosphorIconsRegular.snowflake, size: 16, color: colors.accentSecondary),
                  const SizedBox(width: ValenceSpacing.xs),
                  Text(
                    'Freeze Active Today ❄️',
                    style: typography.caption.copyWith(
                      color: colors.accentSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: ValenceSpacing.lg),

            // Actions
            ValenceButton(
              label: 'Use Freeze',
              fullWidth: true,
              variant: ValenceButtonVariant.primary,
              icon: PhosphorIconsRegular.snowflake,
              onPressed: (freezeActive || !canAfford)
                  ? null
                  : () {
                      groupProvider.useStreakFreeze();
                      Navigator.of(context).pop();
                      ValenceToast.show(
                        context,
                        message: copy.freezeActivatedToast,
                        type: ToastType.success,
                      );
                    },
            ),
            const SizedBox(height: ValenceSpacing.sm),
            ValenceButton(
              label: 'Cancel',
              fullWidth: true,
              variant: ValenceButtonVariant.ghost,
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: ValenceSpacing.sm),
          ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final ValenceTokens tokens;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: tokens.typography.body.copyWith(color: tokens.colors.textSecondary),
        ),
        Text(
          value,
          style: tokens.typography.body.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
