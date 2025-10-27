import 'package:flutter/material.dart';

extension ColorWithAlpha on Color {
  /// Convert opacity value to alpha and create a new color
  Color withAlphaFromOpacity(double opacity) {
    return withAlpha((opacity * 255).round());
  }
}