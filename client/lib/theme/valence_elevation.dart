import 'package:flutter/material.dart';
import 'valence_colors.dart';

/// Returns a [BoxDecoration] for the given elevation [level] (0–4).
///
/// Light theme uses drop shadows.
/// Dark theme uses border outlines + a subtle inner glow on higher levels.
BoxDecoration valenceElevation({
  required int level,
  required bool isDark,
  required ValenceColors colors,
  BorderRadius? borderRadius,
  Color? color,
}) {
  assert(level >= 0 && level <= 4, 'Elevation level must be between 0 and 4.');

  final radius = borderRadius ?? BorderRadius.circular(12);
  final bgColor = color ?? (isDark ? colors.surfacePrimary : colors.surfacePrimary);

  if (!isDark) {
    return BoxDecoration(
      color: bgColor,
      borderRadius: radius,
      boxShadow: _lightShadows(level),
    );
  } else {
    return BoxDecoration(
      color: bgColor,
      borderRadius: radius,
      border: _darkBorder(level, colors),
      boxShadow: _darkGlow(level, colors),
    );
  }
}

List<BoxShadow> _lightShadows(int level) {
  switch (level) {
    case 0:
      return [];
    case 1:
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];
    case 2:
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];
    case 3:
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];
    case 4:
    default:
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.16),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];
  }
}

Border? _darkBorder(int level, ValenceColors colors) {
  if (level == 0) return null;
  final opacity = switch (level) {
    1 => 0.3,
    2 => 0.45,
    3 => 0.6,
    _ => 0.75,
  };
  return Border.all(
    color: colors.borderDefault.withValues(alpha: opacity),
    width: 1.0,
  );
}

List<BoxShadow>? _darkGlow(int level, ValenceColors colors) {
  if (level < 2) return null;
  final glowOpacity = switch (level) {
    2 => 0.04,
    3 => 0.08,
    _ => 0.12,
  };
  return [
    BoxShadow(
      color: colors.accentPrimary.withValues(alpha: glowOpacity),
      blurRadius: level * 8.0,
      spreadRadius: 0,
    ),
  ];
}
