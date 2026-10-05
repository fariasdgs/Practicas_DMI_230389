import 'package:flutter/material.dart';

class AppTheme {
  static const background = Color(0xFF09090F);
  static const cyan = Color(0xFF22D3EE);
  static const violet = Color(0xFFA78BFA);

  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Montserrat',
    scaffoldBackgroundColor: background,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: cyan,
          brightness: Brightness.dark,
        ).copyWith(
          primary: cyan,
          secondary: violet,
          surface: background,
          onPrimary: background,
          onSecondary: background,
          onSurface: Colors.white,
        ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: cyan),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: Colors.white,
        shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
      ),
      bodyMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
      ),
    ),
  );
}
