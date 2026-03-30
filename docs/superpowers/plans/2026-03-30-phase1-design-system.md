# Phase 1: Design System Foundation — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the theme token system, typography, color architecture, and base UI components that every screen in Valence depends on.

**Architecture:** Flutter ThemeExtension pattern — a `ValenceTokens` extension that holds semantic color tokens, typography, spacing, radii, and elevation. Two theme definitions (Nocturnal Sanctuary dark, Daybreak light) resolve all tokens. A `ThemeProvider` manages which theme is active. Base components (ValenceButton, ValenceCard) consume tokens exclusively — zero hardcoded colors.

**Tech Stack:** Flutter, Provider, Phosphor Icons (`phosphor_flutter`), Google Fonts (`google_fonts`), Obviously font (bundled asset)

**Design Spec:** `docs/superpowers/specs/2026-03-30-ui-redesign-design.md` — Sections 1.1 through 1.7, Section 3.1 (core components), Section 3.2 (theme architecture)

---

## File Map

```
client/lib/
├── theme/
│   ├── valence_tokens.dart           # ThemeExtension combining all tokens
│   ├── valence_colors.dart           # Semantic color tokens data class
│   ├── valence_typography.dart       # Text style definitions
│   ├── valence_spacing.dart          # Spacing scale constants
│   ├── valence_radii.dart            # Border radius scale constants
│   ├── valence_elevation.dart        # Elevation/shadow definitions
│   ├── themes/
│   │   ├── nocturnal_sanctuary.dart  # Dark theme token values
│   │   └── daybreak.dart             # Light theme token values
│   └── theme_provider.dart           # ThemeViewModel (ChangeNotifier)
├── widgets/
│   └── core/
│       ├── valence_button.dart       # Primary/Secondary/Ghost/Danger buttons
│       ├── valence_card.dart         # Flat/Elevated/Habit card variants
│       ├── empty_state.dart          # Illustration + message + CTA
│       └── valence_toast.dart        # Success/Info/Warning/Error toasts
├── utils/
│   └── constants.dart                # Habit colors, animation durations
└── app.dart                          # MaterialApp with theme + provider setup

client/test/
├── theme/
│   ├── valence_colors_test.dart
│   ├── valence_tokens_test.dart
│   └── theme_provider_test.dart
└── widgets/
    └── core/
        ├── valence_button_test.dart
        └── valence_card_test.dart
```

---

### Task 1: Add dependencies to pubspec.yaml

**Files:**
- Modify: `client/pubspec.yaml`

- [ ] **Step 1: Add new dependencies**

Add these to the `dependencies:` section of `client/pubspec.yaml`:

```yaml
  phosphor_flutter: ^2.1.0
  google_fonts: ^6.2.1
```

- [ ] **Step 2: Add Obviously font asset declaration**

Add to the `flutter:` → `fonts:` section of `client/pubspec.yaml`:

```yaml
  fonts:
    - family: Obviously
      fonts:
        - asset: assets/fonts/Obviously-Bold.otf
          weight: 700
        - asset: assets/fonts/Obviously-SemiBold.otf
          weight: 600
```

- [ ] **Step 3: Create fonts directory and add placeholder**

```bash
mkdir -p client/assets/fonts
```

Note: The Obviously font files (`Obviously-Bold.otf`, `Obviously-SemiBold.otf`) need to be obtained and placed here. For now, create empty placeholder files so the project compiles. The font will fall back to the system font until real files are added.

```bash
touch client/assets/fonts/Obviously-Bold.otf
touch client/assets/fonts/Obviously-SemiBold.otf
```

- [ ] **Step 4: Run flutter pub get**

```bash
cd client && flutter pub get
```

Expected: Resolves dependencies with no errors.

- [ ] **Step 5: Commit**

```bash
git add client/pubspec.yaml client/pubspec.lock client/assets/fonts/
git commit -m "chore: add phosphor icons, google fonts deps + Obviously font placeholders"
```

---

### Task 2: Create ValenceColors — semantic color tokens

**Files:**
- Create: `client/lib/theme/valence_colors.dart`
- Test: `client/test/theme/valence_colors_test.dart`

- [ ] **Step 1: Write the test**

```dart
// client/test/theme/valence_colors_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/theme/valence_colors.dart';

void main() {
  group('ValenceColors', () {
    test('constructs with all required fields', () {
      final colors = ValenceColors(
        surfaceBackground: const Color(0xFF121220),
        surfacePrimary: const Color(0xFF1E1E35),
        surfaceElevated: const Color(0xFF2A2A48),
        surfaceSunken: const Color(0xFF0D0D1A),
        accentPrimary: const Color(0xFFF4A261),
        accentSecondary: const Color(0xFFE07A5F),
        accentSuccess: const Color(0xFFB8EB6C),
        accentWarning: const Color(0xFFF7CD63),
        accentError: const Color(0xFFFF6B6B),
        accentSocial: const Color(0xFFFC8FC6),
        textPrimary: const Color(0xFFF0E6D3),
        textSecondary: const Color(0xFF8A8A9A),
        textInverse: const Color(0xFF121220),
        textLink: const Color(0xFFF4A261),
        borderDefault: const Color(0xFF2D2D4A),
        borderFocus: const Color(0xFFF4A261),
        chainGold: const Color(0xFFFFD700),
        chainSilver: const Color(0xFFC0C0C0),
        chainBroken: const Color(0xFFFF6B6B),
        rankBronze: const Color(0xFFCD7F32),
        rankSilver: const Color(0xFFC0C0C0),
        rankGold: const Color(0xFFFFD700),
        rankPlatinum: const Color(0xFFE5E4E2),
        rankDiamond: const Color(0xFFB9F2FF),
      );

      expect(colors.surfaceBackground, const Color(0xFF121220));
      expect(colors.accentPrimary, const Color(0xFFF4A261));
      expect(colors.chainGold, const Color(0xFFFFD700));
    });

    test('lerp interpolates between two color sets', () {
      final dark = ValenceColors(
        surfaceBackground: const Color(0xFF121220),
        surfacePrimary: const Color(0xFF1E1E35),
        surfaceElevated: const Color(0xFF2A2A48),
        surfaceSunken: const Color(0xFF0D0D1A),
        accentPrimary: const Color(0xFFF4A261),
        accentSecondary: const Color(0xFFE07A5F),
        accentSuccess: const Color(0xFFB8EB6C),
        accentWarning: const Color(0xFFF7CD63),
        accentError: const Color(0xFFFF6B6B),
        accentSocial: const Color(0xFFFC8FC6),
        textPrimary: const Color(0xFFF0E6D3),
        textSecondary: const Color(0xFF8A8A9A),
        textInverse: const Color(0xFF121220),
        textLink: const Color(0xFFF4A261),
        borderDefault: const Color(0xFF2D2D4A),
        borderFocus: const Color(0xFFF4A261),
        chainGold: const Color(0xFFFFD700),
        chainSilver: const Color(0xFFC0C0C0),
        chainBroken: const Color(0xFFFF6B6B),
        rankBronze: const Color(0xFFCD7F32),
        rankSilver: const Color(0xFFC0C0C0),
        rankGold: const Color(0xFFFFD700),
        rankPlatinum: const Color(0xFFE5E4E2),
        rankDiamond: const Color(0xFFB9F2FF),
      );

      final light = ValenceColors(
        surfaceBackground: const Color(0xFFFFF8F0),
        surfacePrimary: const Color(0xFFFFFFFF),
        surfaceElevated: const Color(0xFFFFFFFF),
        surfaceSunken: const Color(0xFFF5EDE3),
        accentPrimary: const Color(0xFF4E55E0),
        accentSecondary: const Color(0xFF7C5CFC),
        accentSuccess: const Color(0xFF4CAF50),
        accentWarning: const Color(0xFFF7CD63),
        accentError: const Color(0xFFFF6B6B),
        accentSocial: const Color(0xFFFC8FC6),
        textPrimary: const Color(0xFF1A1A2E),
        textSecondary: const Color(0xFF6B6B7B),
        textInverse: const Color(0xFFFFFFFF),
        textLink: const Color(0xFF4E55E0),
        borderDefault: const Color(0xFFE8E0D8),
        borderFocus: const Color(0xFF4E55E0),
        chainGold: const Color(0xFFFFD700),
        chainSilver: const Color(0xFFA0A0A0),
        chainBroken: const Color(0xFFFF6B6B),
        rankBronze: const Color(0xFFCD7F32),
        rankSilver: const Color(0xFFA0A0A0),
        rankGold: const Color(0xFFFFD700),
        rankPlatinum: const Color(0xFF8A8A9A),
        rankDiamond: const Color(0xFF4FC3F7),
      );

      final lerped = dark.lerp(light, 0.5);
      // At t=0.5, the interpolated color should be between dark and light
      expect(lerped.surfaceBackground, isNot(dark.surfaceBackground));
      expect(lerped.surfaceBackground, isNot(light.surfaceBackground));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd client && flutter test test/theme/valence_colors_test.dart
```

Expected: FAIL — `package:mhabit/theme/valence_colors.dart` not found.

- [ ] **Step 3: Write ValenceColors implementation**

```dart
// client/lib/theme/valence_colors.dart
import 'package:flutter/material.dart';

/// Semantic color tokens for the Valence design system.
/// Every color in the UI is referenced through these tokens.
/// Themes (Nocturnal Sanctuary, Daybreak, etc.) provide different values.
class ValenceColors {
  // Surfaces
  final Color surfaceBackground;
  final Color surfacePrimary;
  final Color surfaceElevated;
  final Color surfaceSunken;

  // Accents
  final Color accentPrimary;
  final Color accentSecondary;
  final Color accentSuccess;
  final Color accentWarning;
  final Color accentError;
  final Color accentSocial;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textInverse;
  final Color textLink;

  // Borders
  final Color borderDefault;
  final Color borderFocus;

  // Chain links
  final Color chainGold;
  final Color chainSilver;
  final Color chainBroken;

  // Ranks
  final Color rankBronze;
  final Color rankSilver;
  final Color rankGold;
  final Color rankPlatinum;
  final Color rankDiamond;

  const ValenceColors({
    required this.surfaceBackground,
    required this.surfacePrimary,
    required this.surfaceElevated,
    required this.surfaceSunken,
    required this.accentPrimary,
    required this.accentSecondary,
    required this.accentSuccess,
    required this.accentWarning,
    required this.accentError,
    required this.accentSocial,
    required this.textPrimary,
    required this.textSecondary,
    required this.textInverse,
    required this.textLink,
    required this.borderDefault,
    required this.borderFocus,
    required this.chainGold,
    required this.chainSilver,
    required this.chainBroken,
    required this.rankBronze,
    required this.rankSilver,
    required this.rankGold,
    required this.rankPlatinum,
    required this.rankDiamond,
  });

  ValenceColors lerp(ValenceColors other, double t) {
    return ValenceColors(
      surfaceBackground: Color.lerp(surfaceBackground, other.surfaceBackground, t)!,
      surfacePrimary: Color.lerp(surfacePrimary, other.surfacePrimary, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      accentPrimary: Color.lerp(accentPrimary, other.accentPrimary, t)!,
      accentSecondary: Color.lerp(accentSecondary, other.accentSecondary, t)!,
      accentSuccess: Color.lerp(accentSuccess, other.accentSuccess, t)!,
      accentWarning: Color.lerp(accentWarning, other.accentWarning, t)!,
      accentError: Color.lerp(accentError, other.accentError, t)!,
      accentSocial: Color.lerp(accentSocial, other.accentSocial, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      textLink: Color.lerp(textLink, other.textLink, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderFocus: Color.lerp(borderFocus, other.borderFocus, t)!,
      chainGold: Color.lerp(chainGold, other.chainGold, t)!,
      chainSilver: Color.lerp(chainSilver, other.chainSilver, t)!,
      chainBroken: Color.lerp(chainBroken, other.chainBroken, t)!,
      rankBronze: Color.lerp(rankBronze, other.rankBronze, t)!,
      rankSilver: Color.lerp(rankSilver, other.rankSilver, t)!,
      rankGold: Color.lerp(rankGold, other.rankGold, t)!,
      rankPlatinum: Color.lerp(rankPlatinum, other.rankPlatinum, t)!,
      rankDiamond: Color.lerp(rankDiamond, other.rankDiamond, t)!,
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd client && flutter test test/theme/valence_colors_test.dart
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add client/lib/theme/valence_colors.dart client/test/theme/valence_colors_test.dart
git commit -m "feat: add ValenceColors semantic color token class"
```

---

### Task 3: Create ValenceTypography — text style definitions

**Files:**
- Create: `client/lib/theme/valence_typography.dart`

- [ ] **Step 1: Write ValenceTypography**

```dart
// client/lib/theme/valence_typography.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography definitions for the Valence design system.
/// Uses Obviously for display/headings/numbers, Plus Jakarta Sans for body.
class ValenceTypography {
  final TextStyle display;
  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle bodyLarge;
  final TextStyle body;
  final TextStyle caption;
  final TextStyle overline;
  final TextStyle numbersDisplay;
  final TextStyle numbersBody;

  const ValenceTypography({
    required this.display,
    required this.h1,
    required this.h2,
    required this.h3,
    required this.bodyLarge,
    required this.body,
    required this.caption,
    required this.overline,
    required this.numbersDisplay,
    required this.numbersBody,
  });

  /// Creates the default Valence typography with the given text color.
  /// [primaryColor] is applied to all styles. Individual styles can be
  /// overridden with copyWith() when used.
  factory ValenceTypography.fromColor(Color primaryColor) {
    final obviously = const TextStyle(fontFamily: 'Obviously');
    final plusJakarta = GoogleFonts.plusJakartaSans();

    return ValenceTypography(
      display: obviously.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: primaryColor,
      ),
      h1: obviously.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primaryColor,
      ),
      h2: obviously.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      h3: obviously.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      bodyLarge: plusJakarta.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      body: plusJakarta.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primaryColor,
      ),
      caption: plusJakarta.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      overline: plusJakarta.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: 1.2,
      ),
      numbersDisplay: obviously.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: primaryColor,
      ),
      numbersBody: obviously.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
    );
  }

  ValenceTypography lerp(ValenceTypography other, double t) {
    return ValenceTypography(
      display: TextStyle.lerp(display, other.display, t)!,
      h1: TextStyle.lerp(h1, other.h1, t)!,
      h2: TextStyle.lerp(h2, other.h2, t)!,
      h3: TextStyle.lerp(h3, other.h3, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      overline: TextStyle.lerp(overline, other.overline, t)!,
      numbersDisplay: TextStyle.lerp(numbersDisplay, other.numbersDisplay, t)!,
      numbersBody: TextStyle.lerp(numbersBody, other.numbersBody, t)!,
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add client/lib/theme/valence_typography.dart
git commit -m "feat: add ValenceTypography text style definitions"
```

---

### Task 4: Create ValenceSpacing, ValenceRadii, ValenceElevation

**Files:**
- Create: `client/lib/theme/valence_spacing.dart`
- Create: `client/lib/theme/valence_radii.dart`
- Create: `client/lib/theme/valence_elevation.dart`

- [ ] **Step 1: Write ValenceSpacing**

```dart
// client/lib/theme/valence_spacing.dart

/// Spacing scale for the Valence design system.
/// Use these instead of raw numbers for consistent spacing.
class ValenceSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double smMd = 12;
  static const double md = 16;
  static const double mdLg = 20;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
  static const double xxxl = 48;
  static const double huge = 64;

  /// Grid margin (horizontal padding for screen content)
  static const double gridMargin = 16;

  /// Grid gutter (spacing between grid columns)
  static const double gridGutter = 16;
}
```

- [ ] **Step 2: Write ValenceRadii**

```dart
// client/lib/theme/valence_radii.dart
import 'package:flutter/material.dart';

/// Border radius scale for the Valence design system.
class ValenceRadii {
  static const double small = 8;    // chips, badges
  static const double medium = 12;  // buttons, inputs
  static const double large = 16;   // cards
  static const double xl = 20;      // habit cards, modals
  static const double round = 999;  // avatars, FAB, pills

  static BorderRadius get smallRadius => BorderRadius.circular(small);
  static BorderRadius get mediumRadius => BorderRadius.circular(medium);
  static BorderRadius get largeRadius => BorderRadius.circular(large);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
  static BorderRadius get roundRadius => BorderRadius.circular(round);
}
```

- [ ] **Step 3: Write ValenceElevation**

```dart
// client/lib/theme/valence_elevation.dart
import 'package:flutter/material.dart';
import 'package:mhabit/theme/valence_colors.dart';

/// Elevation definitions that adapt per theme.
/// Light theme uses shadows; dark theme uses borders + glow.
class ValenceElevation {
  /// Returns a BoxDecoration for the given elevation level and theme.
  /// [level] 0-4: flat, card, elevated, modal, overlay.
  /// [isDark] determines shadow vs border treatment.
  static BoxDecoration decoration({
    required int level,
    required bool isDark,
    required ValenceColors colors,
    BorderRadius? borderRadius,
  }) {
    final radius = borderRadius ?? BorderRadius.circular(16);

    if (isDark) {
      return _darkDecoration(level, colors, radius);
    }
    return _lightDecoration(level, colors, radius);
  }

  static BoxDecoration _lightDecoration(
    int level,
    ValenceColors colors,
    BorderRadius radius,
  ) {
    switch (level) {
      case 0:
        return BoxDecoration(
          color: colors.surfacePrimary,
          borderRadius: radius,
        );
      case 1:
        return BoxDecoration(
          color: colors.surfacePrimary,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case 2:
        return BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case 3:
        return BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        );
      default: // 4+
        return BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.24),
              blurRadius: 48,
              offset: const Offset(0, 16),
            ),
          ],
        );
    }
  }

  static BoxDecoration _darkDecoration(
    int level,
    ValenceColors colors,
    BorderRadius radius,
  ) {
    switch (level) {
      case 0:
        return BoxDecoration(
          color: colors.surfacePrimary,
          borderRadius: radius,
        );
      case 1:
        return BoxDecoration(
          color: colors.surfacePrimary,
          borderRadius: radius,
          border: Border.all(color: colors.borderDefault, width: 1),
        );
      case 2:
        return BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: radius,
          border: Border.all(color: colors.borderDefault, width: 1),
          boxShadow: [
            BoxShadow(
              color: colors.accentPrimary.withValues(alpha: 0.05),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        );
      case 3:
        return BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: radius,
          border: Border.all(color: colors.borderDefault, width: 2),
          boxShadow: [
            BoxShadow(
              color: colors.accentPrimary.withValues(alpha: 0.08),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        );
      default: // 4+
        return BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: radius,
          border: Border.all(color: colors.borderDefault, width: 2),
          boxShadow: [
            BoxShadow(
              color: colors.accentPrimary.withValues(alpha: 0.12),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        );
    }
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add client/lib/theme/valence_spacing.dart client/lib/theme/valence_radii.dart client/lib/theme/valence_elevation.dart
git commit -m "feat: add spacing, radii, and elevation definitions"
```

---

### Task 5: Create theme definitions — Nocturnal Sanctuary & Daybreak

**Files:**
- Create: `client/lib/theme/themes/nocturnal_sanctuary.dart`
- Create: `client/lib/theme/themes/daybreak.dart`

- [ ] **Step 1: Write Nocturnal Sanctuary (dark theme)**

```dart
// client/lib/theme/themes/nocturnal_sanctuary.dart
import 'package:flutter/material.dart';
import 'package:mhabit/theme/valence_colors.dart';

/// Nocturnal Sanctuary — warm amber on deep dark.
/// "Cozy lamp-in-a-dark-room" aesthetic.
const nocturnalSanctuaryColors = ValenceColors(
  surfaceBackground: Color(0xFF121220),
  surfacePrimary: Color(0xFF1E1E35),
  surfaceElevated: Color(0xFF2A2A48),
  surfaceSunken: Color(0xFF0D0D1A),
  accentPrimary: Color(0xFFF4A261),
  accentSecondary: Color(0xFFE07A5F),
  accentSuccess: Color(0xFFB8EB6C),
  accentWarning: Color(0xFFF7CD63),
  accentError: Color(0xFFFF6B6B),
  accentSocial: Color(0xFFFC8FC6),
  textPrimary: Color(0xFFF0E6D3),
  textSecondary: Color(0xFF8A8A9A),
  textInverse: Color(0xFF121220),
  textLink: Color(0xFFF4A261),
  borderDefault: Color(0xFF2D2D4A),
  borderFocus: Color(0xFFF4A261),
  chainGold: Color(0xFFFFD700),
  chainSilver: Color(0xFFC0C0C0),
  chainBroken: Color(0xFFFF6B6B),
  rankBronze: Color(0xFFCD7F32),
  rankSilver: Color(0xFFC0C0C0),
  rankGold: Color(0xFFFFD700),
  rankPlatinum: Color(0xFFE5E4E2),
  rankDiamond: Color(0xFFB9F2FF),
);
```

- [ ] **Step 2: Write Daybreak (light theme)**

```dart
// client/lib/theme/themes/daybreak.dart
import 'package:flutter/material.dart';
import 'package:mhabit/theme/valence_colors.dart';

/// Daybreak — warm whites, soft peach, golden hour.
/// Clean and vibrant light theme.
const daybreakColors = ValenceColors(
  surfaceBackground: Color(0xFFFFF8F0),
  surfacePrimary: Color(0xFFFFFFFF),
  surfaceElevated: Color(0xFFFFFFFF),
  surfaceSunken: Color(0xFFF5EDE3),
  accentPrimary: Color(0xFF4E55E0),
  accentSecondary: Color(0xFF7C5CFC),
  accentSuccess: Color(0xFF4CAF50),
  accentWarning: Color(0xFFF7CD63),
  accentError: Color(0xFFFF6B6B),
  accentSocial: Color(0xFFFC8FC6),
  textPrimary: Color(0xFF1A1A2E),
  textSecondary: Color(0xFF6B6B7B),
  textInverse: Color(0xFFFFFFFF),
  textLink: Color(0xFF4E55E0),
  borderDefault: Color(0xFFE8E0D8),
  borderFocus: Color(0xFF4E55E0),
  chainGold: Color(0xFFFFD700),
  chainSilver: Color(0xFFA0A0A0),
  chainBroken: Color(0xFFFF6B6B),
  rankBronze: Color(0xFFCD7F32),
  rankSilver: Color(0xFFA0A0A0),
  rankGold: Color(0xFFFFD700),
  rankPlatinum: Color(0xFF8A8A9A),
  rankDiamond: Color(0xFF4FC3F7),
);
```

- [ ] **Step 3: Commit**

```bash
mkdir -p client/lib/theme/themes
git add client/lib/theme/themes/
git commit -m "feat: add Nocturnal Sanctuary and Daybreak theme color definitions"
```

---

### Task 6: Create ValenceTokens ThemeExtension

**Files:**
- Create: `client/lib/theme/valence_tokens.dart`
- Test: `client/test/theme/valence_tokens_test.dart`

- [ ] **Step 1: Write the test**

```dart
// client/test/theme/valence_tokens_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/theme/valence_tokens.dart';
import 'package:mhabit/theme/themes/nocturnal_sanctuary.dart';
import 'package:mhabit/theme/themes/daybreak.dart';

void main() {
  group('ValenceTokens', () {
    test('creates dark theme tokens', () {
      final tokens = ValenceTokens.fromColors(
        colors: nocturnalSanctuaryColors,
        isDark: true,
      );

      expect(tokens.colors.surfaceBackground, const Color(0xFF121220));
      expect(tokens.isDark, isTrue);
      expect(tokens.typography.h1.fontFamily, 'Obviously');
    });

    test('creates light theme tokens', () {
      final tokens = ValenceTokens.fromColors(
        colors: daybreakColors,
        isDark: false,
      );

      expect(tokens.colors.surfaceBackground, const Color(0xFFFFF8F0));
      expect(tokens.isDark, isFalse);
    });

    test('lerp interpolates between themes', () {
      final dark = ValenceTokens.fromColors(
        colors: nocturnalSanctuaryColors,
        isDark: true,
      );
      final light = ValenceTokens.fromColors(
        colors: daybreakColors,
        isDark: false,
      );

      final lerped = dark.lerp(light, 0.5);
      expect(lerped, isA<ValenceTokens>());
    });

    test('can be retrieved from ThemeData via extension', () {
      final tokens = ValenceTokens.fromColors(
        colors: daybreakColors,
        isDark: false,
      );

      final themeData = ThemeData.light().copyWith(
        extensions: [tokens],
      );

      final retrieved = themeData.extension<ValenceTokens>();
      expect(retrieved, isNotNull);
      expect(retrieved!.colors.accentPrimary, const Color(0xFF4E55E0));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd client && flutter test test/theme/valence_tokens_test.dart
```

Expected: FAIL — `package:mhabit/theme/valence_tokens.dart` not found.

- [ ] **Step 3: Write ValenceTokens implementation**

```dart
// client/lib/theme/valence_tokens.dart
import 'package:flutter/material.dart';
import 'package:mhabit/theme/valence_colors.dart';
import 'package:mhabit/theme/valence_typography.dart';

/// The master ThemeExtension that combines all Valence design tokens.
/// Access in widgets via: Theme.of(context).extension<ValenceTokens>()!
class ValenceTokens extends ThemeExtension<ValenceTokens> {
  final ValenceColors colors;
  final ValenceTypography typography;
  final bool isDark;

  const ValenceTokens({
    required this.colors,
    required this.typography,
    required this.isDark,
  });

  /// Convenience factory that builds typography from the color set.
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

/// Extension for easy access to ValenceTokens from BuildContext.
extension ValenceTokensExtension on BuildContext {
  ValenceTokens get tokens => Theme.of(this).extension<ValenceTokens>()!;
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd client && flutter test test/theme/valence_tokens_test.dart
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add client/lib/theme/valence_tokens.dart client/test/theme/valence_tokens_test.dart
git commit -m "feat: add ValenceTokens ThemeExtension combining colors + typography"
```

---

### Task 7: Create ThemeProvider — active theme management

**Files:**
- Create: `client/lib/theme/theme_provider.dart`
- Test: `client/test/theme/theme_provider_test.dart`

- [ ] **Step 1: Write the test**

```dart
// client/test/theme/theme_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/theme/theme_provider.dart';

void main() {
  group('ThemeProvider', () {
    test('defaults to Daybreak (light) theme', () {
      final provider = ThemeProvider();
      expect(provider.activeThemeId, 'daybreak');
      expect(provider.isDark, isFalse);
    });

    test('can switch to Nocturnal Sanctuary', () {
      final provider = ThemeProvider();
      provider.setTheme('nocturnal_sanctuary');
      expect(provider.activeThemeId, 'nocturnal_sanctuary');
      expect(provider.isDark, isTrue);
    });

    test('can switch back to Daybreak', () {
      final provider = ThemeProvider();
      provider.setTheme('nocturnal_sanctuary');
      provider.setTheme('daybreak');
      expect(provider.activeThemeId, 'daybreak');
      expect(provider.isDark, isFalse);
    });

    test('generates ThemeData with ValenceTokens extension', () {
      final provider = ThemeProvider();
      final themeData = provider.themeData;
      expect(themeData, isNotNull);

      final tokens = provider.tokens;
      expect(tokens, isNotNull);
      expect(tokens.colors.accentPrimary.value, isNonZero);
    });

    test('ignores unknown theme ids', () {
      final provider = ThemeProvider();
      provider.setTheme('nonexistent');
      expect(provider.activeThemeId, 'daybreak'); // stays at default
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd client && flutter test test/theme/theme_provider_test.dart
```

Expected: FAIL — `package:mhabit/theme/theme_provider.dart` not found.

- [ ] **Step 3: Write ThemeProvider implementation**

```dart
// client/lib/theme/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:mhabit/theme/valence_colors.dart';
import 'package:mhabit/theme/valence_tokens.dart';
import 'package:mhabit/theme/themes/nocturnal_sanctuary.dart';
import 'package:mhabit/theme/themes/daybreak.dart';

/// Manages the active theme for the Valence app.
/// Wraps theme selection and generates ThemeData + ValenceTokens.
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
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd client && flutter test test/theme/theme_provider_test.dart
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add client/lib/theme/theme_provider.dart client/test/theme/theme_provider_test.dart
git commit -m "feat: add ThemeProvider for active theme management"
```

---

### Task 8: Create habit color constants

**Files:**
- Create: `client/lib/utils/constants.dart`

- [ ] **Step 1: Write constants**

```dart
// client/lib/utils/constants.dart
import 'package:flutter/material.dart';

/// Habit card colors — consistent across both themes.
/// Each habit gets assigned one of these colors.
class HabitColors {
  static const Color blue = Color(0xFF4E55E0);
  static const Color lime = Color(0xFFB8EB6C);
  static const Color amber = Color(0xFFF7CD63);
  static const Color pink = Color(0xFFFC8FC6);
  static const Color orange = Color(0xFFFD6E20);
  static const Color teal = Color(0xFF2EC4B6);
  static const Color purple = Color(0xFFC9BEFA);
  static const Color coral = Color(0xFFFF6B6B);
  static const Color mint = Color(0xFF6FEDD6);
  static const Color slate = Color(0xFF64748B);

  static const List<Color> all = [
    blue, lime, amber, pink, orange, teal, purple, coral, mint, slate,
  ];

  static const List<String> names = [
    'Blue', 'Lime', 'Amber', 'Pink', 'Orange', 'Teal', 'Purple', 'Coral', 'Mint', 'Slate',
  ];
}

/// Animation durations used across the app.
class ValenceDurations {
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration cardAppear = Duration(milliseconds: 200);
  static const Duration habitCompletion = Duration(milliseconds: 400);
  static const Duration chainForge = Duration(milliseconds: 500);
  static const Duration nudgeSent = Duration(milliseconds: 350);
  static const Duration kudos = Duration(milliseconds: 300);
  static const Duration tabSwitch = Duration(milliseconds: 200);
  static const Duration xpGain = Duration(milliseconds: 500);
  static const Duration themeSwitch = Duration(milliseconds: 400);
}
```

- [ ] **Step 2: Commit**

```bash
git add client/lib/utils/constants.dart
git commit -m "feat: add habit color constants and animation durations"
```

---

### Task 9: Create ValenceButton component

**Files:**
- Create: `client/lib/widgets/core/valence_button.dart`
- Test: `client/test/widgets/core/valence_button_test.dart`

- [ ] **Step 1: Write the test**

```dart
// client/test/widgets/core/valence_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/theme/valence_tokens.dart';
import 'package:mhabit/theme/themes/daybreak.dart';
import 'package:mhabit/widgets/core/valence_button.dart';

Widget _wrap(Widget child) {
  final tokens = ValenceTokens.fromColors(colors: daybreakColors, isDark: false);
  return MaterialApp(
    theme: ThemeData.light().copyWith(extensions: [tokens]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('ValenceButton', () {
    testWidgets('renders primary variant with label', (tester) async {
      await tester.pumpWidget(_wrap(
        ValenceButton(
          label: 'Get Started',
          onPressed: () {},
        ),
      ));

      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        ValenceButton(
          label: 'Tap Me',
          onPressed: () => tapped = true,
        ),
      ));

      await tester.tap(find.text('Tap Me'));
      expect(tapped, isTrue);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(_wrap(
        const ValenceButton(
          label: 'Disabled',
          onPressed: null,
        ),
      ));

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('renders ghost variant', (tester) async {
      await tester.pumpWidget(_wrap(
        ValenceButton(
          label: 'Ghost',
          variant: ValenceButtonVariant.ghost,
          onPressed: () {},
        ),
      ));

      expect(find.text('Ghost'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd client && flutter test test/widgets/core/valence_button_test.dart
```

Expected: FAIL — `package:mhabit/widgets/core/valence_button.dart` not found.

- [ ] **Step 3: Write ValenceButton implementation**

```dart
// client/lib/widgets/core/valence_button.dart
import 'package:flutter/material.dart';
import 'package:mhabit/theme/valence_tokens.dart';
import 'package:mhabit/theme/valence_radii.dart';
import 'package:mhabit/theme/valence_spacing.dart';

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
    required this.onPressed,
    this.variant = ValenceButtonVariant.primary,
    this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    final Color backgroundColor;
    final Color foregroundColor;
    final Color? borderColor;

    switch (variant) {
      case ValenceButtonVariant.primary:
        backgroundColor = colors.accentPrimary;
        foregroundColor = colors.textInverse;
        borderColor = null;
      case ValenceButtonVariant.secondary:
        backgroundColor = Colors.transparent;
        foregroundColor = colors.accentPrimary;
        borderColor = colors.accentPrimary;
      case ValenceButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = colors.textSecondary;
        borderColor = null;
      case ValenceButtonVariant.danger:
        backgroundColor = colors.accentError;
        foregroundColor = colors.textInverse;
        borderColor = null;
    }

    final style = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: colors.surfaceSunken,
      disabledForegroundColor: colors.textSecondary,
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: ValenceSpacing.lg,
        vertical: ValenceSpacing.smMd,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: ValenceRadii.mediumRadius,
        side: borderColor != null
            ? BorderSide(color: borderColor)
            : BorderSide.none,
      ),
      textStyle: tokens.typography.bodyLarge.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );

    final child = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: ValenceSpacing.sm),
              Text(label),
            ],
          )
        : Text(label);

    final button = ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd client && flutter test test/widgets/core/valence_button_test.dart
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add client/lib/widgets/core/valence_button.dart client/test/widgets/core/valence_button_test.dart
git commit -m "feat: add ValenceButton component with primary/secondary/ghost/danger variants"
```

---

### Task 10: Create ValenceCard component

**Files:**
- Create: `client/lib/widgets/core/valence_card.dart`
- Test: `client/test/widgets/core/valence_card_test.dart`

- [ ] **Step 1: Write the test**

```dart
// client/test/widgets/core/valence_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/theme/valence_tokens.dart';
import 'package:mhabit/theme/themes/daybreak.dart';
import 'package:mhabit/widgets/core/valence_card.dart';

Widget _wrap(Widget child) {
  final tokens = ValenceTokens.fromColors(colors: daybreakColors, isDark: false);
  return MaterialApp(
    theme: ThemeData.light().copyWith(extensions: [tokens]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('ValenceCard', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(_wrap(
        const ValenceCard(
          child: Text('Card Content'),
        ),
      ));

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('applies elevation level', (tester) async {
      await tester.pumpWidget(_wrap(
        const ValenceCard(
          elevation: 2,
          child: Text('Elevated'),
        ),
      ));

      expect(find.text('Elevated'), findsOneWidget);
    });

    testWidgets('renders habit variant with accent color', (tester) async {
      await tester.pumpWidget(_wrap(
        const ValenceCard(
          accentColor: Color(0xFF4E55E0),
          child: Text('Habit Card'),
        ),
      ));

      expect(find.text('Habit Card'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        ValenceCard(
          onTap: () => tapped = true,
          child: const Text('Tappable'),
        ),
      ));

      await tester.tap(find.text('Tappable'));
      expect(tapped, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd client && flutter test test/widgets/core/valence_card_test.dart
```

Expected: FAIL.

- [ ] **Step 3: Write ValenceCard implementation**

```dart
// client/lib/widgets/core/valence_card.dart
import 'package:flutter/material.dart';
import 'package:mhabit/theme/valence_tokens.dart';
import 'package:mhabit/theme/valence_elevation.dart';
import 'package:mhabit/theme/valence_radii.dart';
import 'package:mhabit/theme/valence_spacing.dart';

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
    final radius = borderRadius ?? ValenceRadii.largeRadius;

    var decoration = ValenceElevation.decoration(
      level: elevation,
      isDark: tokens.isDark,
      colors: tokens.colors,
      borderRadius: radius,
    );

    // If accent color is provided, add a left border (dark) or tinted background (light)
    if (accentColor != null) {
      if (tokens.isDark) {
        decoration = decoration.copyWith(
          border: Border(
            left: BorderSide(color: accentColor!, width: 4),
            top: BorderSide(color: tokens.colors.borderDefault, width: 1),
            right: BorderSide(color: tokens.colors.borderDefault, width: 1),
            bottom: BorderSide(color: tokens.colors.borderDefault, width: 1),
          ),
        );
      } else {
        decoration = decoration.copyWith(
          color: Color.lerp(Colors.white, accentColor!, 0.08),
        );
      }
    }

    Widget card = Container(
      decoration: decoration,
      padding: padding ??
          const EdgeInsets.all(ValenceSpacing.md),
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      card = GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: card,
      );
    }

    return card;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd client && flutter test test/widgets/core/valence_card_test.dart
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add client/lib/widgets/core/valence_card.dart client/test/widgets/core/valence_card_test.dart
git commit -m "feat: add ValenceCard component with elevation and accent color support"
```

---

### Task 11: Create EmptyState and Toast components

**Files:**
- Create: `client/lib/widgets/shared/empty_state.dart`
- Create: `client/lib/widgets/shared/valence_toast.dart`

- [ ] **Step 1: Write EmptyState**

```dart
// client/lib/widgets/shared/empty_state.dart
import 'package:flutter/material.dart';
import 'package:mhabit/theme/valence_tokens.dart';
import 'package:mhabit/theme/valence_spacing.dart';
import 'package:mhabit/widgets/core/valence_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ValenceSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: tokens.colors.textSecondary),
            const SizedBox(height: ValenceSpacing.lg),
            Text(
              title,
              style: tokens.typography.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ValenceSpacing.sm),
            Text(
              message,
              style: tokens.typography.body.copyWith(
                color: tokens.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: ValenceSpacing.lg),
              ValenceButton(
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Write ValenceToast**

```dart
// client/lib/widgets/shared/valence_toast.dart
import 'package:flutter/material.dart';
import 'package:mhabit/theme/valence_tokens.dart';
import 'package:mhabit/theme/valence_radii.dart';
import 'package:mhabit/theme/valence_spacing.dart';

enum ToastType { success, info, warning, error }

class ValenceToast {
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final tokens = context.tokens;

    final Color backgroundColor;
    final IconData icon;

    switch (type) {
      case ToastType.success:
        backgroundColor = tokens.colors.accentSuccess;
        icon = Icons.check_circle_outline;
      case ToastType.info:
        backgroundColor = tokens.colors.accentPrimary;
        icon = Icons.info_outline;
      case ToastType.warning:
        backgroundColor = tokens.colors.accentWarning;
        icon = Icons.warning_amber;
      case ToastType.error:
        backgroundColor = tokens.colors.accentError;
        icon = Icons.error_outline;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: ValenceSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: tokens.typography.body.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: ValenceRadii.mediumRadius,
        ),
        duration: duration,
        margin: const EdgeInsets.all(ValenceSpacing.md),
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
mkdir -p client/lib/widgets/shared
git add client/lib/widgets/shared/
git commit -m "feat: add EmptyState and ValenceToast shared components"
```

---

### Task 12: Create app.dart — MaterialApp with theme wiring

**Files:**
- Create: `client/lib/app.dart`

- [ ] **Step 1: Write app.dart**

```dart
// client/lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mhabit/theme/theme_provider.dart';

/// Root MaterialApp for Valence.
/// Consumes ThemeProvider and wires up theme + routing.
class ValenceApp extends StatelessWidget {
  const ValenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Valence',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            home: const _DesignSystemPreview(), // Temporary — replaced in Phase 2
          );
        },
      ),
    );
  }
}

/// Temporary preview screen showing the design system components.
/// Replaced with real navigation shell in Phase 2.
class _DesignSystemPreview extends StatelessWidget {
  const _DesignSystemPreview();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.colors.surfaceBackground,
      appBar: AppBar(
        title: Text('Valence Design System', style: tokens.typography.h2),
        backgroundColor: tokens.colors.surfacePrimary,
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDark ? Icons.light_mode : Icons.dark_mode,
              color: tokens.colors.textPrimary,
            ),
            onPressed: () {
              themeProvider.setTheme(
                themeProvider.isDark ? 'daybreak' : 'nocturnal_sanctuary',
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Design System Ready — Phase 2 builds the real UI'),
      ),
    );
  }
}
```

Note: This uses `context.tokens` from the extension defined in `valence_tokens.dart`. The import is `package:mhabit/theme/valence_tokens.dart`.

- [ ] **Step 2: Commit**

```bash
git add client/lib/app.dart
git commit -m "feat: add ValenceApp root widget with ThemeProvider wiring"
```

---

### Task 13: Run all tests and verify everything compiles

- [ ] **Step 1: Run all tests**

```bash
cd client && flutter test test/theme/ test/widgets/
```

Expected: All tests PASS (at least 8 tests from tasks 2, 6, 7, 9, 10).

- [ ] **Step 2: Verify app compiles**

```bash
cd client && flutter build apk --debug 2>&1 | tail -5
```

Expected: BUILD SUCCESSFUL (with warnings about the placeholder font files being empty, which is OK).

- [ ] **Step 3: Commit any remaining changes**

```bash
git status
```

If clean: no commit needed. If there are fixes: commit them.

- [ ] **Step 4: Final commit for Phase 1 completion**

```bash
git add -A && git commit -m "feat: complete Phase 1 — design system foundation

Includes:
- ValenceColors semantic token class (24 tokens)
- ValenceTypography (10 text styles: Obviously + Plus Jakarta Sans)
- ValenceSpacing, ValenceRadii, ValenceElevation
- Nocturnal Sanctuary (dark) and Daybreak (light) theme definitions
- ValenceTokens ThemeExtension combining all tokens
- ThemeProvider (ChangeNotifier) for active theme management
- ValenceButton (primary/secondary/ghost/danger)
- ValenceCard (flat/elevated/habit with accent color)
- EmptyState and ValenceToast shared components
- Habit color constants (10 colors) and animation durations
- ValenceApp root widget with theme toggle preview
- 8+ unit and widget tests"
```

---

## Phase 1 Complete

After this phase, you have:
- A working theme token system with two themes
- A theme toggle that switches between dark and light
- Base components that consume tokens (zero hardcoded colors)
- A preview app that compiles and runs

**Next:** Phase 2 — Navigation Shell & Auth (5-tab bottom nav, onboarding flow, Firebase Auth)
