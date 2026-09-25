import 'package:flutter/material.dart';

class AppAnimations {
  AppAnimations._();


  static const Duration fast = Duration(milliseconds: 180);

  static const Duration normal = Duration(milliseconds: 300);

  static const Duration medium = Duration(milliseconds: 450);

  static const Duration slow = Duration(milliseconds: 650);


  static const Curve standard = Curves.easeOutCubic;

  static const Curve emphasized = Curves.easeOutBack;

  static const Curve smooth = Curves.easeInOutCubic;

  static const Curve spring = Curves.elasticOut;


  static Duration feedItemDelay(int index) {
    final milliseconds = 80 * index;

    return Duration(milliseconds: milliseconds > 500 ? 500 : milliseconds);
  }
}
