import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgets_app/config/theme/app.theme.dart';

final colorListProvider = Provider((ref) => colorList);
final themeNotifierProvider = NotifierProvider<ThemeNotifier, AppTheme>(
  ThemeNotifier.new,
);

class ThemeNotifier extends Notifier<AppTheme> {
  @override
  AppTheme build() => AppTheme();

  void toggleDarkmode() =>
      state = state.copyWith(isDarkmode: !state.isDarkmode);

  void changeColorIndex(int index) =>
      state = state.copyWith(selectedColor: index);
}
