import 'package:flutter_test/flutter_test.dart';
import 'package:tikitoki/config/theme/app_theme.dart';

void main() {
  test('El tema respeta los límites de octubre y diciembre', () {
    final cases = {
      DateTime(2026, 9, 30, 23, 59): AppSeason.tech,
      DateTime(2026, 10, 1): AppSeason.halloween,
      DateTime(2026, 10, 31, 23, 59): AppSeason.halloween,
      DateTime(2026, 11, 1): AppSeason.tech,
      DateTime(2026, 12, 1): AppSeason.christmas,
      DateTime(2026, 12, 31, 23, 59): AppSeason.christmas,
      DateTime(2027, 1, 1): AppSeason.tech,
    };
    for (final entry in cases.entries) {
      expect(AppTheme.seasonFor(entry.key), entry.value);
    }
  });

  test('Los temas cambian la paleta y conservan Montserrat', () {
    final theme = AppTheme();
    final tech = theme.getTheme(date: DateTime(2026, 7, 1));
    final halloween = theme.getTheme(date: DateTime(2026, 10, 4));
    final christmas = theme.getTheme(date: DateTime(2026, 12, 25));
    expect(halloween.colorScheme.primary, isNot(tech.colorScheme.primary));
    expect(christmas.colorScheme.primary, isNot(halloween.colorScheme.primary));
    for (final selected in [tech, halloween, christmas]) {
      expect(selected.textTheme.bodyMedium?.fontFamily, 'Montserrat');
      expect(
        selected.progressIndicatorTheme.color,
        selected.colorScheme.primary,
      );
    }
  });
}
