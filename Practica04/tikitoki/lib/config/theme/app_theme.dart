import 'package:flutter/material.dart';

enum AppSeason { tech, halloween, christmas }

class AppTheme {
  static const background = Color(0xFF09090F);
  static const cyan = Color(0xFF22D3EE);
  static const violet = Color(0xFFA78BFA);

  static AppSeason seasonFor(DateTime date) => switch (date.month) {
    10 => AppSeason.halloween,
    12 => AppSeason.christmas,
    _ => AppSeason.tech,
  };

  ThemeData getTheme({DateTime? date}) =>
      themeFor(seasonFor(date ?? DateTime.now()));

  ThemeData themeFor(AppSeason season) {
    final (primary, secondary, surface) = switch (season) {
      AppSeason.halloween => (
        const Color(0xFFFF9F43),
        const Color(0xFFC084FC),
        const Color(0xFF100B18),
      ),
      AppSeason.christmas => (
        const Color(0xFF4ADE80),
        const Color(0xFFFF6B6B),
        const Color(0xFF07140F),
      ),
      AppSeason.tech => (cyan, violet, background),
    };
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Montserrat',
      scaffoldBackgroundColor: surface,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: primary,
            brightness: Brightness.dark,
          ).copyWith(
            primary: primary,
            secondary: secondary,
            surface: surface,
            onPrimary: background,
            onSecondary: background,
            onSurface: Colors.white,
          ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
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
}
