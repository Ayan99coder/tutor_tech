import 'package:flutter/material.dart';

class AppMotion {
  // Durations
  static const microFast = Duration(milliseconds: 150);   // button press, chip select
  static const standard  = Duration(milliseconds: 300);   // page elements, card expand
  static const slow      = Duration(milliseconds: 450);   // page transitions, hero reveal
  static const shimmerLoop = Duration(milliseconds: 1200); // skeleton shimmer cycle

  // Curves
  static const enter = Curves.easeOutCubic;   // things arriving
  static const exit  = Curves.easeInCubic;    // things leaving
  static const bounce = Curves.elasticOut;    // success/celebration only, use sparingly
  static const spring = Curves.easeOutBack;   // button press feedback
}
