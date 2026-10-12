import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikitoki/config/theme/app_theme.dart';
import 'package:tikitoki/presentation/widgets/shared/video_description.dart';

void main() {
  Future<void> pumpCaption(WidgetTester tester, String caption) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 260,
            child: VideoDescription(caption: caption, season: AppSeason.tech),
          ),
        ),
      ),
    );
  }

  testWidgets('Descripción corta no muestra Ver más', (tester) async {
    await pumpCaption(tester, 'Un video corto');
    expect(find.text('Ver más'), findsNothing);
  });

  testWidgets('Descripción larga alterna Ver más y Ver menos', (tester) async {
    final caption = List.filled(3, 'texto largo de descripción').join(' ');
    await pumpCaption(tester, caption);
    expect(find.text('Ver más'), findsOneWidget);
    await tester.tap(find.text('Ver más'));
    await tester.pump();
    expect(find.text('Ver menos'), findsOneWidget);
    await tester.tap(find.text('Ver menos'));
    await tester.pump();
    expect(find.text('Ver más'), findsOneWidget);
  });
}
