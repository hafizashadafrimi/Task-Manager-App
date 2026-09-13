import 'package:flutter/material.dart';

class AppColors {
  static const purple = Color(0xFF7C3AED);
  static const purpleDark = Color(0xFF5B21B6);
  static const purpleLight = Color(0xFFA78BFA);
  static const cyan = Color(0xFF67E8F9);
  static const cyanDark = Color(0xFF22D3EE);
  static const dark = Color(0xFF1E1B2E);
  static const surface = Color(0xFFF8F7FF);
  static const card = Colors.white;
  static const text = Color(0xFF1E1B2E);
  static const muted = Color(0xFF64748B);
  static const danger = Color(0xFFEF4444);

  static const purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, purpleDark],
  );

  static const softGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF3E8FF), surface],
  );
}
