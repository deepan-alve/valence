import 'package:flutter/material.dart';

/// Tracking method for a habit.
enum TrackingType {
  /// User taps checkbox to complete.
  manual,

  /// User must attach a photo to complete.
  manualPhoto,

  /// Auto-tracked via external plugin (LeetCode, GitHub, etc.).
  plugin,

  /// Card body opens an external URL; checkbox is still manual.
  redirect,
}

/// Subjective effort level for a habit.
enum HabitIntensity {
  light,
  moderate,
  intense,
}

/// Day completion status for the week day selector.
enum DayStatus {
  /// All habits completed.
  allDone,

  /// Some habits completed.
  partial,

  /// No habits completed (past day).
  missed,

  /// Day hasn't happened yet.
  future,
}

/// Chain link quality for group streak visualization.
enum ChainLinkType {
  /// Everyone completed --- gold link.
  gold,

  /// Most completed --- silver link.
  silver,

  /// Chain broken --- red gap.
  broken,

  /// Day hasn't happened yet.
  future,
}

/// Group tier based on consecutive streak length.
enum GroupTier {
  spark,  // 0-6 days
  ember,  // 7-20 days
  flame,  // 21-65 days
  blaze,  // 66+ days
}

/// A single habit displayed on the Home screen.
class Habit {
  final String id;
  final String name;
  final String subtitle;
  final Color color;
  final String iconName;
  final TrackingType trackingType;
  final HabitIntensity intensity;
  final bool isCompleted;
  final String? pluginName;
  final String? redirectUrl;
  final int streakDays;

  const Habit({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.color,
    required this.iconName,
    required this.trackingType,
    this.intensity = HabitIntensity.moderate,
    this.isCompleted = false,
    this.pluginName,
    this.redirectUrl,
    this.streakDays = 0,
  });

  /// Whether this habit is tracked by an external plugin.
  bool get isPlugin => trackingType == TrackingType.plugin;

  /// Whether this habit opens a redirect URL on card body tap.
  bool get isRedirect => trackingType == TrackingType.redirect;

  /// Whether this habit requires a photo for completion.
  bool get requiresPhoto => trackingType == TrackingType.manualPhoto;

  Habit copyWith({
    String? id,
    String? name,
    String? subtitle,
    Color? color,
    String? iconName,
    TrackingType? trackingType,
    HabitIntensity? intensity,
    bool? isCompleted,
    String? pluginName,
    String? redirectUrl,
    int? streakDays,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      color: color ?? this.color,
      iconName: iconName ?? this.iconName,
      trackingType: trackingType ?? this.trackingType,
      intensity: intensity ?? this.intensity,
      isCompleted: isCompleted ?? this.isCompleted,
      pluginName: pluginName ?? this.pluginName,
      redirectUrl: redirectUrl ?? this.redirectUrl,
      streakDays: streakDays ?? this.streakDays,
    );
  }
}
