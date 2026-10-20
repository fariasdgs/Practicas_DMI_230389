import 'package:flutter_test/flutter_test.dart';
import 'package:tikitoki/config/helpers/app_date.dart';
import 'package:tikitoki/config/theme/app_theme.dart';

void main() {
  test('La fecha simulada permite seleccionar las cuatro temporadas', () {
    for (final entry in {
      '2026-02-14': AppSeason.valentine,
      '2026-10-31': AppSeason.halloween,
      '2026-12-25': AppSeason.christmas,
      '2026-07-01': AppSeason.tech,
    }.entries) {
      expect(
        AppTheme.seasonFor(AppDate.now(dateOverride: entry.key)),
        entry.value,
      );
    }
  });

  test('Sin fecha simulada se usa el reloj real', () {
    final before = DateTime.now();
    final actual = AppDate.now(dateOverride: '');
    final after = DateTime.now();
    expect(actual.isBefore(before), isFalse);
    expect(actual.isAfter(after), isFalse);
  });

  test('Rechaza formatos incorrectos y fechas inexistentes', () {
    for (final date in ['14/02/2026', '2026-02-30', '2026-13-01']) {
      expect(() => AppDate.now(dateOverride: date), throwsFormatException);
    }
    expect(AppDate.now(dateOverride: '2028-02-29'), DateTime(2028, 2, 29));
  });
}
