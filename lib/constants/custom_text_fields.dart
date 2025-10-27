import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextField {
  static InputDecoration outline(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.primaryLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      );
}
