import 'package:frontend/theme/app_theme.dart';
import 'package:flutter/material.dart';

class InputDecorations {
  static InputDecoration authInputDecoration({
    required bool isDarkMode,
    required String hintText,
    String? labelText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: AppTheme.primaryColor,
        ),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: AppTheme.primaryColor,
          width: 2,
        ),
      ),
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Colors.grey,
      ),
      labelText: labelText,
      labelStyle: const TextStyle(
        color: Colors.black,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppTheme.primaryColor)
          : null,
    );
  }
}
