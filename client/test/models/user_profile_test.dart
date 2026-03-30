import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/shop_item.dart';
import 'package:valence/models/user_profile.dart';

void main() {
  group('EquippedCustomizations', () {
    test('constructs with defaults for all categories', () {
      const equipped = EquippedCustomizations();
      expect(equipped.themeId, 'nocturnal_sanctuary');
      expect(equipped.flameId, 'flame_default');
      expect(equipped.animationId, 'anim_default');
      expect(equipped.cardStyleId, 'card_default');
      expect(equipped.fontId, 'font_default');
      expect(equipped.patternId, 'pattern_none');
      expect(equipped.appIconId, isNull);
    });

    test('copyWith overrides specific fields', () {
      const equipped = EquippedCustomizations();
      final updated = equipped.copyWith(themeId: 'daybreak');
      expect(updated.themeId, 'daybreak');
      expect(updated.flameId, 'flame_default'); // unchanged
    });
  });

  group('PersonaType', () {
    test('has 3 values', () {
      expect(PersonaType.values.length, 3);
      expect(PersonaType.values, contains(PersonaType.socialiser));
      expect(PersonaType.values, contains(PersonaType.achiever));
      expect(PersonaType.values, contains(PersonaType.general));
    });
  });

  group('PluginConnection', () {
    test('constructs with required fields', () {
      const plugin = PluginConnection(
        id: 'leetcode',
        name: 'LeetCode',
        iconName: 'code',
        isConnected: true,
      );
      expect(plugin.isConnected, isTrue);
      expect(plugin.isExpired, isFalse);
    });

    test('expired connection has isExpired true', () {
      const plugin = PluginConnection(
        id: 'github',
        name: 'GitHub',
        iconName: 'git-branch',
        isConnected: true,
        isExpired: true,
      );
      expect(plugin.isExpired, isTrue);
    });
  });

  group('NotificationPreferences', () {
    test('defaults all toggles to true', () {
      const prefs = NotificationPreferences();
      expect(prefs.morning, isTrue);
      expect(prefs.nudges, isTrue);
      expect(prefs.memes, isTrue);
      expect(prefs.reflection, isTrue);
    });

    test('copyWith overrides individual toggles', () {
      const prefs = NotificationPreferences();
      final updated = prefs.copyWith(memes: false);
      expect(updated.memes, isFalse);
      expect(updated.morning, isTrue); // unchanged
    });
  });

  group('UserProfile', () {
    test('constructs with all fields', () {
      final profile = UserProfile(
        id: 'user_1',
        name: 'Diana',
        email: 'diana@example.com',
        avatarUrl: null,
        xp: 1250,
        sparks: 340,
        personaType: PersonaType.general,
        equipped: const EquippedCustomizations(),
        memberSince: DateTime(2026, 1, 15),
      );

      expect(profile.name, 'Diana');
      expect(profile.rank, Rank.silver);
      expect(profile.xp, 1250);
    });

    test('rank is derived from XP', () {
      final bronze = UserProfile(
        id: '1',
        name: 'A',
        email: 'a@b.c',
        xp: 0,
        sparks: 0,
        personaType: PersonaType.general,
        equipped: const EquippedCustomizations(),
        memberSince: DateTime(2026),
      );
      expect(bronze.rank, Rank.bronze);

      final gold = bronze.copyWith(xp: 2500);
      expect(gold.rank, Rank.gold);
    });

    test('rankProgress returns 0-1 fraction', () {
      final profile = UserProfile(
        id: '1',
        name: 'A',
        email: 'a@b.c',
        xp: 1250,
        sparks: 0,
        personaType: PersonaType.general,
        equipped: const EquippedCustomizations(),
        memberSince: DateTime(2026),
      );
      // Silver: 500-2000, 1250 is 750/1500 = 0.5
      expect(profile.rankProgress, closeTo(0.5, 0.01));
    });

    test('xpRemaining returns XP to next rank', () {
      final profile = UserProfile(
        id: '1',
        name: 'A',
        email: 'a@b.c',
        xp: 1250,
        sparks: 0,
        personaType: PersonaType.general,
        equipped: const EquippedCustomizations(),
        memberSince: DateTime(2026),
      );
      // Silver: next is Gold at 2000, so 2000-1250 = 750
      expect(profile.xpRemaining, 750);
    });

    test('xpForNextRank returns next rank threshold', () {
      final profile = UserProfile(
        id: '1',
        name: 'A',
        email: 'a@b.c',
        xp: 1250,
        sparks: 0,
        personaType: PersonaType.general,
        equipped: const EquippedCustomizations(),
        memberSince: DateTime(2026),
      );
      expect(profile.xpForNextRank, 2000); // Gold threshold
    });

    test('xpForNextRank is null for Diamond', () {
      final diamond = UserProfile(
        id: '1',
        name: 'A',
        email: 'a@b.c',
        xp: 15000,
        sparks: 0,
        personaType: PersonaType.general,
        equipped: const EquippedCustomizations(),
        memberSince: DateTime(2026),
      );
      expect(diamond.xpForNextRank, isNull);
    });

    test('initials returns first 2 characters uppercased', () {
      final profile = UserProfile(
        id: '1',
        name: 'diana',
        email: 'a@b.c',
        xp: 0,
        sparks: 0,
        personaType: PersonaType.general,
        equipped: const EquippedCustomizations(),
        memberSince: DateTime(2026),
      );
      expect(profile.initials, 'DI');
    });

    test('copyWith preserves unchanged fields', () {
      final profile = UserProfile(
        id: 'user_deepan',
        name: 'Deepan',
        email: 'deepan@valence.app',
        xp: 1250,
        sparks: 340,
        personaType: PersonaType.general,
        equipped: const EquippedCustomizations(),
        memberSince: DateTime(2026, 1, 15),
      );

      final updated = profile.copyWith(sparks: 500);
      expect(updated.sparks, 500);
      expect(updated.name, 'Deepan'); // unchanged
      expect(updated.xp, 1250); // unchanged
    });
  });
}
