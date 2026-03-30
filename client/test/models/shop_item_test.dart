import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/shop_item.dart';

void main() {
  group('ShopCategory', () {
    test('has 7 categories matching PRD Section 6', () {
      expect(ShopCategory.values.length, 7);
      expect(ShopCategory.values, contains(ShopCategory.themes));
      expect(ShopCategory.values, contains(ShopCategory.flames));
      expect(ShopCategory.values, contains(ShopCategory.animations));
      expect(ShopCategory.values, contains(ShopCategory.cardStyles));
      expect(ShopCategory.values, contains(ShopCategory.fonts));
      expect(ShopCategory.values, contains(ShopCategory.patterns));
      expect(ShopCategory.values, contains(ShopCategory.appIcons));
    });

    test('displayName returns human-readable labels', () {
      expect(ShopCategory.themes.displayName, 'Themes');
      expect(ShopCategory.cardStyles.displayName, 'Card Styles');
      expect(ShopCategory.appIcons.displayName, 'App Icons');
    });
  });

  group('Rank', () {
    test('has 5 ranks matching PRD 5.7.3', () {
      expect(Rank.values.length, 5);
    });

    test('xpRequired matches PRD thresholds', () {
      expect(Rank.bronze.xpRequired, 0);
      expect(Rank.silver.xpRequired, 500);
      expect(Rank.gold.xpRequired, 2000);
      expect(Rank.platinum.xpRequired, 5000);
      expect(Rank.diamond.xpRequired, 15000);
    });

    test('rankFor returns correct rank for XP', () {
      expect(Rank.rankFor(0), Rank.bronze);
      expect(Rank.rankFor(499), Rank.bronze);
      expect(Rank.rankFor(500), Rank.silver);
      expect(Rank.rankFor(1999), Rank.silver);
      expect(Rank.rankFor(2000), Rank.gold);
      expect(Rank.rankFor(15000), Rank.diamond);
    });

    test('xpToNextRank returns remaining XP', () {
      expect(Rank.xpToNextRank(0), 500);
      expect(Rank.xpToNextRank(250), 250);
      expect(Rank.xpToNextRank(500), 1500);
      expect(Rank.xpToNextRank(15000), 0); // Diamond is max
    });

    test('nextRank returns next tier or null for Diamond', () {
      expect(Rank.bronze.nextRank, Rank.silver);
      expect(Rank.silver.nextRank, Rank.gold);
      expect(Rank.diamond.nextRank, isNull);
    });

    test('xpForNextRank returns threshold or null for Diamond', () {
      expect(Rank.bronze.xpForNextRank, 500);
      expect(Rank.gold.xpForNextRank, 5000);
      expect(Rank.diamond.xpForNextRank, isNull);
    });

    test('progressFor returns 0.0-1.0 fraction', () {
      // Silver: 500-2000. At 1250: (1250-500)/(2000-500) = 750/1500 = 0.5
      expect(Rank.silver.progressFor(1250), closeTo(0.5, 0.01));
      // Bronze at 0: 0/500 = 0.0
      expect(Rank.bronze.progressFor(0), closeTo(0.0, 0.01));
      // Diamond is maxed: returns 1.0
      expect(Rank.diamond.progressFor(20000), closeTo(1.0, 0.01));
    });
  });

  group('ShopItem', () {
    test('constructs with all required fields', () {
      final item = ShopItem(
        id: 'theme_daybreak',
        category: ShopCategory.themes,
        name: 'Daybreak',
        sparkCost: 100,
        minRank: Rank.bronze,
        assetKey: 'daybreak',
        description: 'Warm whites, soft peach, golden hour.',
      );

      expect(item.id, 'theme_daybreak');
      expect(item.category, ShopCategory.themes);
      expect(item.sparkCost, 100);
      expect(item.isOwned, isFalse);
      expect(item.isEquipped, isFalse);
      expect(item.requiresMomentum, isFalse);
    });

    test('default items have zero sparkCost and are owned', () {
      const item = ShopItem(
        id: 'theme_nocturnal',
        category: ShopCategory.themes,
        name: 'Nocturnal Sanctuary',
        sparkCost: 0,
        minRank: Rank.bronze,
        assetKey: 'nocturnal_sanctuary',
        description: 'Default dark theme.',
        isOwned: true,
        isEquipped: true,
      );

      expect(item.isOwned, isTrue);
      expect(item.isEquipped, isTrue);
    });

    test('copyWith overrides specified fields', () {
      const item = ShopItem(
        id: 'flame_blue',
        category: ShopCategory.flames,
        name: 'Blue Flame',
        sparkCost: 50,
        minRank: Rank.bronze,
        assetKey: 'flame_blue',
        description: 'Cool blue fire.',
      );

      final purchased = item.copyWith(isOwned: true);
      expect(purchased.isOwned, isTrue);
      expect(purchased.id, 'flame_blue');
    });

    test('itemState returns correct state', () {
      const locked = ShopItem(
        id: '1',
        category: ShopCategory.themes,
        name: 'Test',
        sparkCost: 300,
        minRank: Rank.gold,
        assetKey: 'test',
        description: 'Test',
      );
      expect(locked.itemState(currentRank: Rank.bronze, sparks: 500),
          ItemState.lockedByRank);

      final tooExpensive = locked.copyWith(minRank: Rank.bronze, sparkCost: 500);
      expect(tooExpensive.itemState(currentRank: Rank.bronze, sparks: 100),
          ItemState.tooExpensive);

      final available = locked.copyWith(minRank: Rank.bronze, sparkCost: 50);
      expect(available.itemState(currentRank: Rank.bronze, sparks: 100),
          ItemState.available);

      final owned = locked.copyWith(isOwned: true);
      expect(owned.itemState(currentRank: Rank.bronze, sparks: 0),
          ItemState.owned);

      final equipped = locked.copyWith(isOwned: true, isEquipped: true);
      expect(equipped.itemState(currentRank: Rank.bronze, sparks: 0),
          ItemState.equipped);
    });

    test('itemState returns lockedByMomentum when requiresMomentum and no momentum', () {
      const flameItem = ShopItem(
        id: 'flame_blue',
        category: ShopCategory.flames,
        name: 'Blue Flame',
        sparkCost: 50,
        minRank: Rank.bronze,
        assetKey: 'flame_blue',
        description: 'Cool blue fire.',
        requiresMomentum: true,
      );

      expect(
        flameItem.itemState(
          currentRank: Rank.bronze,
          sparks: 500,
          hasMomentumHabit: false,
        ),
        ItemState.lockedByMomentum,
      );

      expect(
        flameItem.itemState(
          currentRank: Rank.bronze,
          sparks: 500,
          hasMomentumHabit: true,
        ),
        ItemState.available,
      );
    });
  });
}
