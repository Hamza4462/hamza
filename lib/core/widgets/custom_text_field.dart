import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final Widget? prefix;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffix,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.body2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        suffixIcon: suffix,
        prefixIcon: prefix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: AppTextStyles.body1,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      obscureText: obscureText,
    );
  }
}