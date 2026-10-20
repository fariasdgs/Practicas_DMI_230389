/// Fecha simulada opcional, configurada al ejecutar con --dart-define.
class AppDate {
  static const configuredDate = String.fromEnvironment('TIKITOKI_DATE');

  static bool get isFixed => configuredDate.isNotEmpty;

  static DateTime now({String dateOverride = configuredDate}) {
    if (dateOverride.isEmpty) return DateTime.now();
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(dateOverride);
    if (match != null) {
      final year = int.parse(match[1]!);
      final month = int.parse(match[2]!);
      final day = int.parse(match[3]!);
      final date = DateTime(year, month, day);
      if (date.year == year && date.month == month && date.day == day) {
        return date;
      }
    }
    throw FormatException(
      'TIKITOKI_DATE debe ser una fecha válida con formato AAAA-MM-DD',
      dateOverride,
    );
  }
}
