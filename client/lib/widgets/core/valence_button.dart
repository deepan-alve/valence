import 'package:flutter/material.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

enum ValenceButtonVariant { primary, secondary, ghost, danger }

class ValenceButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ValenceButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;

  const ValenceButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ValenceButtonVariant.primary,
    this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final isDisabled = onPressed == null;

    // Resolve colors based on variant and disabled state
    final Color bgColor;
    final Color fgColor;
    Border? border;

    if (isDisabled) {
      bgColor = colors.surfaceSunken;
      fgColor = colors.textSecondary;
    } else {
      switch (variant) {
        case ValenceButtonVariant.primary:
          bgColor = colors.accentPrimary;
          fgColor = colors.textInverse;
        case ValenceButtonVariant.secondary:
          bgColor = Colors.transparent;
          fgColor = colors.accentPrimary;
          border = Border.all(color: colors.accentPrimary, width: 1.5);
        case ValenceButtonVariant.ghost:
          bgColor = Colors.transparent;
          fgColor = colors.textSecondary;
        case ValenceButtonVariant.danger:
          bgColor = colors.accentError;
          fgColor = colors.textInverse;
      }
    }

    final shape = RoundedRectangleBorder(
      borderRadius: ValenceRadii.mediumAll,
      side: border != null
          ? BorderSide(color: colors.accentPrimary, width: 1.5)
          : BorderSide.none,
    );

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, color: fgColor, size: 18),
          const SizedBox(width: ValenceSpacing.sm),
        ],
        Text(
          label,
          style: tokens.typography.body.copyWith(
            color: fgColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        disabledBackgroundColor: colors.surfaceSunken,
        disabledForegroundColor: colors.textSecondary,
        shape: shape,
        padding: const EdgeInsets.symmetric(
          horizontal: ValenceSpacing.md,
          vertical: ValenceSpacing.smMd,
        ),
        minimumSize: fullWidth ? const Size(double.infinity, 48) : const Size(0, 48),
      ),
      child: buttonChild,
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
