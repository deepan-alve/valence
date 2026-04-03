import 'package:flutter/material.dart';
import 'package:valence/theme/valence_colors.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/theme/themes/nocturnal_sanctuary.dart';
import 'package:valence/theme/themes/daybreak.dart';

class ThemeProvider extends ChangeNotifier {
  String _activeThemeId = 'daybreak';

  static const Map<String, ValenceColors> _themes = {
    'nocturnal_sanctuary': nocturnalSanctuaryColors,
    'daybreak': daybreakColors,
  };

  static const Set<String> _darkThemes = {'nocturnal_sanctuary'};

  String get activeThemeId => _activeThemeId;
  bool get isDark => _darkThemes.contains(_activeThemeId);

  ValenceTokens get tokens => ValenceTokens.fromColors(
        colors: _themes[_activeThemeId]!,
        isDark: isDark,
      );

  ThemeData get themeData {
    final t = tokens;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: t.colors.surfaceBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: t.colors.accentPrimary,
        brightness: brightness,
        surface: t.colors.surfacePrimary,
        primary: t.colors.accentPrimary,
        error: t.colors.accentError,
      ),
      extensions: [t],
    );
  }

  void setTheme(String themeId) {
    if (!_themes.containsKey(themeId)) return;
    if (_activeThemeId == themeId) return;
    _activeThemeId = themeId;
    notifyListeners();
  }
}
