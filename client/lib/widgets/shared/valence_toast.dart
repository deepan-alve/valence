import 'package:flutter/material.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

enum ToastType { success, info, warning, error }

class ValenceToast {
  ValenceToast._();

  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    final Color bgColor;
    final Color fgColor;
    final IconData icon;

    switch (type) {
      case ToastType.success:
        bgColor = colors.accentSuccess;
        fgColor = colors.textInverse;
        icon = Icons.check_circle_outline;
      case ToastType.info:
        bgColor = colors.accentPrimary;
        fgColor = colors.textInverse;
        icon = Icons.info_outline;
      case ToastType.warning:
        bgColor = colors.accentWarning;
        fgColor = colors.textPrimary;
        icon = Icons.warning_amber_outlined;
      case ToastType.error:
        bgColor = colors.accentError;
        fgColor = colors.textInverse;
        icon = Icons.error_outline;
    }

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: bgColor,
      duration: duration,
      shape: RoundedRectangleBorder(
        borderRadius: ValenceRadii.mediumAll,
      ),
      margin: const EdgeInsets.all(ValenceSpacing.md),
      content: Row(
        children: [
          Icon(icon, color: fgColor, size: 20),
          const SizedBox(width: ValenceSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: tokens.typography.body.copyWith(color: fgColor),
            ),
          ),
        ],
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
