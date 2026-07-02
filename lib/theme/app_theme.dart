import 'package:flutter/material.dart';

/// Shared visual style for the whole app.
///
/// Built for early readers: big rounded shapes, high-contrast bright
/// colors, and no reliance on small text for meaning.
class AppTheme {
  AppTheme._();

  static const Color background = Color(0xFFFFF8EE);

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6C63FF),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: background,
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: const Color(0xFF2B2640),
        displayColor: const Color(0xFF2B2640),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(64, 64),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}
