import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/presentation/widgets/chat/message_bubble.dart';

void main() {
  testWidgets('Muestra hora fija HH:mm en mensajes enviados y recibidos', (
    tester,
  ) async {
    final messages = [
      Message(
        '¿Hoy toca entrenar?',
        null,
        FromWho.mine,
        sentAt: DateTime(2026, 9, 28, 9, 5),
      ),
      Message('Sí', null, FromWho.hers, sentAt: DateTime(2026, 9, 28, 9, 6)),
      Message('No', null, FromWho.hers, sentAt: DateTime(2026, 9, 28, 14, 30)),
      Message(
        'Tal Vez',
        null,
        FromWho.hers,
        sentAt: DateTime(2026, 9, 28, 23, 59),
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorSchemeSeed: const Color(0xFF6C63FF)),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: messages
                    .map((message) => MessageBubble(message: message))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
    for (final time in ['09:05', '09:06', '14:30', '23:59']) {
      expect(find.text(time), findsOneWidget);
    }
    await tester.pump(const Duration(minutes: 2));
    expect(find.text('09:05'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Un mensaje largo cabe en una pantalla pequeña', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            message: Message(
              '¿Este mensaje largo puede ocupar varias líneas sin tapar su hora de envío?',
              null,
              FromWho.mine,
              sentAt: DateTime(2026, 9, 28, 9, 5),
            ),
          ),
        ),
      ),
    );
    expect(find.text('09:05'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
