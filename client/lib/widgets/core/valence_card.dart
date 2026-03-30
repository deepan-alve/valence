import 'package:flutter/material.dart';
import 'package:valence/theme/valence_elevation.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

class ValenceCard extends StatelessWidget {
  final Widget child;
  final int elevation;
  final Color? accentColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const ValenceCard({
    super.key,
    required this.child,
    this.elevation = 1,
    this.accentColor,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final isDark = tokens.isDark;
    final radius = borderRadius ?? ValenceRadii.mediumAll;

    // Determine background tint when accentColor is provided in light mode
    Color? bgColor;
    if (accentColor != null && !isDark) {
      bgColor = Color.lerp(colors.surfacePrimary, accentColor!, 0.06);
    }

    BoxDecoration decoration = valenceElevation(
      level: elevation.clamp(0, 4),
      isDark: isDark,
      colors: colors,
      borderRadius: radius,
      color: bgColor,
    );

    // In dark mode with accent, add a left border via a wrapper
    Widget content = Container(
      decoration: decoration,
      padding: padding ?? const EdgeInsets.all(ValenceSpacing.md),
      child: child,
    );

    // Dark mode accent: wrap with a Stack to add left border overlay
    if (accentColor != null && isDark) {
      content = ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            Container(
              decoration: decoration,
              padding: padding ?? const EdgeInsets.all(ValenceSpacing.md),
              child: child,
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                color: accentColor,
              ),
            ),
          ],
        ),
      );
    }

    if (onTap != null || onLongPress != null) {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: content,
      );
    }
    return content;
  }
}
