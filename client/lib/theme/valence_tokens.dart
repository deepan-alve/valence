import 'package:flutter/material.dart';
import 'package:valence/theme/valence_colors.dart';
import 'package:valence/theme/valence_typography.dart';

class ValenceTokens extends ThemeExtension<ValenceTokens> {
  final ValenceColors colors;
  final ValenceTypography typography;
  final bool isDark;

  const ValenceTokens({
    required this.colors,
    required this.typography,
    required this.isDark,
  });

  factory ValenceTokens.fromColors({
    required ValenceColors colors,
    required bool isDark,
  }) {
    return ValenceTokens(
      colors: colors,
      typography: ValenceTypography.fromColor(colors.textPrimary),
      isDark: isDark,
    );
  }

  @override
  ValenceTokens copyWith({
    ValenceColors? colors,
    ValenceTypography? typography,
    bool? isDark,
  }) {
    return ValenceTokens(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  ValenceTokens lerp(covariant ValenceTokens? other, double t) {
    if (other == null) return this;
    return ValenceTokens(
      colors: colors.lerp(other.colors, t),
      typography: typography.lerp(other.typography, t),
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

extension ValenceTokensExtension on BuildContext {
  ValenceTokens get tokens => Theme.of(this).extension<ValenceTokens>()!;
}
