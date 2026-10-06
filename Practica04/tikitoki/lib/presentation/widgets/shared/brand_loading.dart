import 'package:flutter/material.dart';
import 'package:tikitoki/config/theme/app_theme.dart';

String seasonalLogo(AppSeason season) => switch (season) {
  AppSeason.halloween => 'assets/icon/app_icon_halloween.png',
  AppSeason.christmas => 'assets/icon/app_icon_christmas.png',
  AppSeason.tech => 'assets/icon/app_icon.png',
};

class BrandLoading extends StatelessWidget {
  final AppSeason season;
  final String label;
  const BrandLoading({
    super.key,
    this.season = AppSeason.tech,
    this.label = 'Preparando tu próximo video',
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 76,
                  height: 76,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: colors.primary.withValues(alpha: 0.65),
                    backgroundColor: colors.secondary.withValues(alpha: 0.12),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    seasonalLogo(season),
                    width: 54,
                    height: 54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

class SeasonEntrance extends StatelessWidget {
  final AppSeason season;
  const SeasonEntrance({super.key, required this.season});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final subtitle = switch (season) {
      AppSeason.halloween => 'Una temporada de pequeños sustos',
      AppSeason.christmas => 'Un momento para compartir magia',
      AppSeason.tech => 'Desliza. Reproduce. Explora.',
    };
    return Material(
      key: const ValueKey('season-entrance'),
      color: colors.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: 0.85,
            colors: [colors.secondary.withValues(alpha: 0.12), colors.surface],
          ),
        ),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.scale(scale: 0.92 + value * 0.08, child: child),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.1),
                        blurRadius: 50,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: Image.asset(
                      seasonalLogo(season),
                      width: 180,
                      height: 180,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'tikitoki',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.white60),
                ),
                const SizedBox(height: 28),
                Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: LinearGradient(
                      colors: [colors.primary, colors.secondary],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
