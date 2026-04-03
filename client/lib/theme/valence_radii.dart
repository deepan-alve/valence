import 'package:flutter/material.dart';

class ValenceRadii {
  ValenceRadii._();

  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double xl = 20;
  static const double round = 999;

  static BorderRadius get smallAll => BorderRadius.circular(small);
  static BorderRadius get mediumAll => BorderRadius.circular(medium);
  static BorderRadius get largeAll => BorderRadius.circular(large);
  static BorderRadius get xlAll => BorderRadius.circular(xl);
  static BorderRadius get roundAll => BorderRadius.circular(round);
}
