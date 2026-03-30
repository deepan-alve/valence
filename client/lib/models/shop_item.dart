/// Categories of purchasable items in the Shop.
/// Matches PRD Section 6 tables: Themes, Flames, Animations, Card Styles,
/// Fonts, Patterns, App Icons.
enum ShopCategory {
  themes('Themes'),
  flames('Flames'),
  animations('Animations'),
  cardStyles('Card Styles'),
  fonts('Fonts'),
  patterns('Patterns'),
  appIcons('App Icons');

  final String displayName;
  const ShopCategory(this.displayName);
}

/// User rank tiers. Never decrease once earned.
/// XP thresholds from PRD 5.7.3.
enum Rank {
  bronze(0, 'Bronze'),
  silver(500, 'Silver'),
  gold(2000, 'Gold'),
  platinum(5000, 'Platinum'),
  diamond(15000, 'Diamond');

  final int xpRequired;
  final String displayName;
  const Rank(this.xpRequired, this.displayName);

  /// Returns the rank for the given total XP.
  static Rank rankFor(int xp) {
    if (xp >= diamond.xpRequired) return diamond;
    if (xp >= platinum.xpRequired) return platinum;
    if (xp >= gold.xpRequired) return gold;
    if (xp >= silver.xpRequired) return silver;
    return bronze;
  }

  /// XP remaining until the next rank. Returns 0 if Diamond.
  static int xpToNextRank(int xp) {
    final current = rankFor(xp);
    final nextIndex = current.index + 1;
    if (nextIndex >= Rank.values.length) return 0;
    return Rank.values[nextIndex].xpRequired - xp;
  }

  /// The next rank after this one, or null if Diamond.
  Rank? get nextRank {
    final nextIndex = index + 1;
    if (nextIndex >= Rank.values.length) return null;
    return Rank.values[nextIndex];
  }

  /// XP required for the next rank (total, not remaining). Null if Diamond.
  int? get xpForNextRank => nextRank?.xpRequired;

  /// Progress fraction (0.0–1.0) toward the next rank.
  double progressFor(int xp) {
    final next = nextRank;
    if (next == null) return 1.0;
    final rangeStart = xpRequired;
    final rangeEnd = next.xpRequired;
    return ((xp - rangeStart) / (rangeEnd - rangeStart)).clamp(0.0, 1.0);
  }
}

/// Visual state of a shop item relative to the current user.
enum ItemState {
  /// User meets rank req and has enough sparks — "Buy" button.
  available,

  /// User doesn't meet rank req — grayed out, "Requires [Rank]".
  lockedByRank,

  /// User meets rank but doesn't have enough sparks — cost in red.
  tooExpensive,

  /// User owns but hasn't equipped — "Equip" toggle.
  owned,

  /// User owns and is currently equipped — highlighted.
  equipped,

  /// Flames only: user hasn't reached Momentum (21d) on any habit.
  lockedByMomentum,
}

/// A single purchasable item in the Shop.
class ShopItem {
  final String id;
  final ShopCategory category;
  final String name;
  final int sparkCost;
  final Rank minRank;
  final String assetKey;
  final String description;
  final bool isOwned;
  final bool isEquipped;

  /// Only true for flame items — requires a habit at Momentum (21 days).
  final bool requiresMomentum;

  const ShopItem({
    required this.id,
    required this.category,
    required this.name,
    required this.sparkCost,
    required this.minRank,
    required this.assetKey,
    required this.description,
    this.isOwned = false,
    this.isEquipped = false,
    this.requiresMomentum = false,
  });

  /// Determines the visual state of this item for the current user.
  /// For flame items, pass [hasMomentumHabit] to also check the Momentum gate.
  ItemState itemState({
    required Rank currentRank,
    required int sparks,
    bool hasMomentumHabit = true,
  }) {
    if (isEquipped) return ItemState.equipped;
    if (isOwned) return ItemState.owned;
    if (requiresMomentum && !hasMomentumHabit) return ItemState.lockedByMomentum;
    if (currentRank.index < minRank.index) return ItemState.lockedByRank;
    if (sparks < sparkCost) return ItemState.tooExpensive;
    return ItemState.available;
  }

  ShopItem copyWith({
    String? id,
    ShopCategory? category,
    String? name,
    int? sparkCost,
    Rank? minRank,
    String? assetKey,
    String? description,
    bool? isOwned,
    bool? isEquipped,
    bool? requiresMomentum,
  }) {
    return ShopItem(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      sparkCost: sparkCost ?? this.sparkCost,
      minRank: minRank ?? this.minRank,
      assetKey: assetKey ?? this.assetKey,
      description: description ?? this.description,
      isOwned: isOwned ?? this.isOwned,
      isEquipped: isEquipped ?? this.isEquipped,
      requiresMomentum: requiresMomentum ?? this.requiresMomentum,
    );
  }
}
