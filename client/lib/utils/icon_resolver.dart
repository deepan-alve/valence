// client/lib/utils/icon_resolver.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Maps string icon names (stored in model data) to Phosphor IconData.
class IconResolver {
  IconResolver._();

  static IconData resolve(String name) {
    return switch (name) {
      'code' => PhosphorIcons.code(),
      'barbell' => PhosphorIcons.barbell(),
      'book-open' => PhosphorIcons.bookOpen(),
      'brain' => PhosphorIcons.brain(),
      'git-branch' => PhosphorIcons.gitBranch(),
      'globe' => PhosphorIcons.globe(),
      'lightning' => PhosphorIcons.lightning(),
      'pencil-simple' => PhosphorIcons.pencilSimple(),
      'heart' => PhosphorIcons.heart(),
      'fire' => PhosphorIcons.fire(),
      'star' => PhosphorIcons.star(),
      _ => PhosphorIcons.question(),
    };
  }
}
