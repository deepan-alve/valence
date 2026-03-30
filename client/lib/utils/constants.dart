import 'package:flutter/material.dart';

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
    blue,
    lime,
    amber,
    pink,
    orange,
    teal,
    purple,
    coral,
    mint,
    slate,
  ];

  static const List<String> names = [
    'Blue',
    'Lime',
    'Amber',
    'Pink',
    'Orange',
    'Teal',
    'Purple',
    'Coral',
    'Mint',
    'Slate',
  ];
}

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
