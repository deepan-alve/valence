import 'package:valence/models/shop_item.dart';

/// Persona type affects home screen greeting and motivational stats.
/// Matches PRD 5.5.1.
enum PersonaType {
  socialiser('Socialiser'),
  achiever('Achiever'),
  general('General');

  final String displayName;
  const PersonaType(this.displayName);
}

/// The user's currently equipped cosmetic items, one per category.
class EquippedCustomizations {
  final String themeId;
  final String flameId;
  final String animationId;
  final String cardStyleId;
  final String fontId;
  final String patternId;
  final String? appIconId;

  const EquippedCustomizations({
    this.themeId = 'nocturnal_sanctuary',
    this.flameId = 'flame_default',
    this.animationId = 'anim_default',
    this.cardStyleId = 'card_default',
    this.fontId = 'font_default',
    this.patternId = 'pattern_none',
    this.appIconId,
  });

  EquippedCustomizations copyWith({
    String? themeId,
    String? flameId,
    String? animationId,
    String? cardStyleId,
    String? fontId,
    String? patternId,
    String? appIconId,
  }) {
    return EquippedCustomizations(
      themeId: themeId ?? this.themeId,
      flameId: flameId ?? this.flameId,
      animationId: animationId ?? this.animationId,
      cardStyleId: cardStyleId ?? this.cardStyleId,
      fontId: fontId ?? this.fontId,
      patternId: patternId ?? this.patternId,
      appIconId: appIconId ?? this.appIconId,
    );
  }
}

/// A connected or available plugin integration.
class PluginConnection {
  final String id;
  final String name;
  final String iconName;
  final bool isConnected;
  final bool isExpired;

  const PluginConnection({
    required this.id,
    required this.name,
    required this.iconName,
    required this.isConnected,
    this.isExpired = false,
  });
}

/// Notification preference toggles.
class NotificationPreferences {
  final bool morning;
  final bool nudges;
  final bool memes;
  final bool reflection;

  const NotificationPreferences({
    this.morning = true,
    this.nudges = true,
    this.memes = true,
    this.reflection = true,
  });

  NotificationPreferences copyWith({
    bool? morning,
    bool? nudges,
    bool? memes,
    bool? reflection,
  }) {
    return NotificationPreferences(
      morning: morning ?? this.morning,
      nudges: nudges ?? this.nudges,
      memes: memes ?? this.memes,
      reflection: reflection ?? this.reflection,
    );
  }
}

/// The full user profile displayed on the Profile screen.
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final int xp;
  final int sparks;
  final PersonaType personaType;
  final EquippedCustomizations equipped;
  final DateTime memberSince;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.xp,
    required this.sparks,
    required this.personaType,
    required this.equipped,
    required this.memberSince,
  });

  /// Derived rank based on lifetime XP.
  Rank get rank => Rank.rankFor(xp);

  /// Progress fraction (0.0–1.0) toward the next rank.
  double get rankProgress => rank.progressFor(xp);

  /// XP remaining until next rank. 0 if Diamond.
  int get xpRemaining => Rank.xpToNextRank(xp);

  /// XP required for next rank (absolute). Null if Diamond.
  int? get xpForNextRank => rank.xpForNextRank;

  /// First 2 characters of the name, uppercased.
  String get initials {
    if (name.isEmpty) return '?';
    final cleaned = name.trim();
    if (cleaned.length <= 2) return cleaned.toUpperCase();
    return cleaned.substring(0, 2).toUpperCase();
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    int? xp,
    int? sparks,
    PersonaType? personaType,
    EquippedCustomizations? equipped,
    DateTime? memberSince,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      xp: xp ?? this.xp,
      sparks: sparks ?? this.sparks,
      personaType: personaType ?? this.personaType,
      equipped: equipped ?? this.equipped,
      memberSince: memberSince ?? this.memberSince,
    );
  }
}
