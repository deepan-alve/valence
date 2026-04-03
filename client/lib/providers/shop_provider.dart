// client/lib/providers/shop_provider.dart
import 'package:flutter/foundation.dart';
import 'package:valence/models/shop_item.dart';

/// Manages shop screen state: items, categories, purchase/equip actions.
class ShopProvider extends ChangeNotifier {
  ShopCategory _selectedCategory = ShopCategory.themes;
  List<ShopItem> _items = _mockItems();
  int _sparks = 340;
  int _xp = 1240;
  bool _hasMomentumHabit = true;

  ShopCategory get selectedCategory => _selectedCategory;
  List<ShopItem> get currentItems =>
      _items.where((i) => i.category == _selectedCategory).toList();
  int get sparks => _sparks;
  int get xp => _xp;
  Rank get userRank => Rank.rankFor(_xp);
  double get rankProgress => userRank.progressFor(_xp);
  int get xpRemaining => Rank.xpToNextRank(_xp);
  bool get hasMomentumHabit => _hasMomentumHabit;

  void selectCategory(ShopCategory category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  void purchaseItem(String itemId) {
    final idx = _items.indexWhere((i) => i.id == itemId);
    if (idx == -1) return;
    final item = _items[idx];
    if (_sparks < item.sparkCost) return;
    _sparks -= item.sparkCost;
    _items[idx] = item.copyWith(isOwned: true);
    notifyListeners();
  }

  void equipItem(String itemId) {
    final idx = _items.indexWhere((i) => i.id == itemId);
    if (idx == -1) return;
    final category = _items[idx].category;
    // Unequip others in same category
    _items = _items.map((i) {
      if (i.category == category && i.isEquipped) {
        return i.copyWith(isEquipped: false);
      }
      return i;
    }).toList();
    _items[idx] = _items[idx].copyWith(isEquipped: true);
    notifyListeners();
  }

  static List<ShopItem> _mockItems() {
    return [
      // Themes
      const ShopItem(
        id: 'theme_nocturnal',
        category: ShopCategory.themes,
        name: 'Nocturnal Sanctuary',
        sparkCost: 0,
        minRank: Rank.bronze,
        assetKey: 'nocturnal_sanctuary',
        description: 'Deep dark blues and purples. The default.',
        isOwned: true,
        isEquipped: true,
      ),
      const ShopItem(
        id: 'theme_ember',
        category: ShopCategory.themes,
        name: 'Ember Core',
        sparkCost: 150,
        minRank: Rank.silver,
        assetKey: 'ember_core',
        description: 'Warm reds and ambers for the grinders.',
      ),
      const ShopItem(
        id: 'theme_arctic',
        category: ShopCategory.themes,
        name: 'Arctic Focus',
        sparkCost: 200,
        minRank: Rank.silver,
        assetKey: 'arctic_focus',
        description: 'Ice blues and white. Clinical and clean.',
      ),
      const ShopItem(
        id: 'theme_forest',
        category: ShopCategory.themes,
        name: 'Forest Protocol',
        sparkCost: 300,
        minRank: Rank.gold,
        assetKey: 'forest_protocol',
        description: 'Deep greens. Nature meets productivity.',
      ),
      // Flames
      const ShopItem(
        id: 'flame_default',
        category: ShopCategory.flames,
        name: 'Basic Flame',
        sparkCost: 0,
        minRank: Rank.bronze,
        assetKey: 'flame_default',
        description: 'The classic orange flame.',
        isOwned: true,
        isEquipped: true,
      ),
      const ShopItem(
        id: 'flame_blue',
        category: ShopCategory.flames,
        name: 'Blue Flame',
        sparkCost: 100,
        minRank: Rank.bronze,
        assetKey: 'flame_blue',
        description: 'Burns hotter. Or so they say.',
        requiresMomentum: true,
      ),
      const ShopItem(
        id: 'flame_rainbow',
        category: ShopCategory.flames,
        name: 'Rainbow Flame',
        sparkCost: 250,
        minRank: Rank.gold,
        assetKey: 'flame_rainbow',
        description: 'For the truly unhinged.',
        requiresMomentum: true,
      ),
      // Fonts
      const ShopItem(
        id: 'font_default',
        category: ShopCategory.fonts,
        name: 'System Default',
        sparkCost: 0,
        minRank: Rank.bronze,
        assetKey: 'font_default',
        description: 'Clean and readable.',
        isOwned: true,
        isEquipped: true,
      ),
      const ShopItem(
        id: 'font_mono',
        category: ShopCategory.fonts,
        name: 'Mono Grind',
        sparkCost: 75,
        minRank: Rank.bronze,
        assetKey: 'font_mono',
        description: 'Monospace. For the engineers.',
      ),
      const ShopItem(
        id: 'font_rounded',
        category: ShopCategory.fonts,
        name: 'Soft Focus',
        sparkCost: 75,
        minRank: Rank.silver,
        assetKey: 'font_rounded',
        description: 'Rounded. Friendlier vibes.',
      ),
      // Card Styles
      const ShopItem(
        id: 'card_default',
        category: ShopCategory.cardStyles,
        name: 'Default Card',
        sparkCost: 0,
        minRank: Rank.bronze,
        assetKey: 'card_default',
        description: 'The standard look.',
        isOwned: true,
        isEquipped: true,
      ),
      const ShopItem(
        id: 'card_glass',
        category: ShopCategory.cardStyles,
        name: 'Glass Morphism',
        sparkCost: 120,
        minRank: Rank.silver,
        assetKey: 'card_glass',
        description: 'Frosted glass effect.',
      ),
    ];
  }
}
