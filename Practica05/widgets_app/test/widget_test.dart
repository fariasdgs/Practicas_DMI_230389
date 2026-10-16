
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgets_app/config/router/app_router.dart';
import 'package:widgets_app/config/theme/app.theme.dart';
import 'package:widgets_app/main.dart';

void main() {
  testWidgets('El tema cambia el color y el modo de toda la aplicación', (
    tester,
  ) async {
    appRouter.go('/');
    await tester.pumpWidget(const ProviderScope(child: MainApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tema'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(RadioListTile<int>).at(1));
    await tester.pumpAndSettle();
    var theme = Theme.of(tester.element(find.byType(Scaffold).last));
    expect(theme.colorScheme, AppTheme(selectedColor: 1).getTheme().colorScheme);

    await tester.tap(find.byIcon(Icons.light_mode_outlined));
    await tester.pumpAndSettle();
    theme = Theme.of(tester.element(find.byType(Scaffold).last));
    expect(theme.brightness, Brightness.dark);

    appRouter.pop();
    await tester.pumpAndSettle();
    expect(find.text('Flutter + Material 3'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.dark,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
