import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:yes_no_app/main.dart';
import 'package:yes_no_app/presentation/chat/chat_screen.dart';
import 'package:yes_no_app/presentation/providers/chat_provider.dart';
import 'package:yes_no_app/presentation/widgets/shared/message_field_box.dart';

class PendingImageStreamCompleter extends ImageStreamCompleter {}

void main() {
  testWidgets('La app configura el chat como pantalla inicial', (tester) async {
    // Evita descargas de imágenes en esta prueba de la configuración del chat.
    final imageCache = PaintingBinding.instance.imageCache;
    for (final url in [
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaDG8IBiiKmM6m1tvpbZAdv9rS3z7bdkwkRgbRvQe8TQ&s=10',
      'https://yesno.wtf/assets/no/20-56c4b19517aa69c8f7081939198341a4.gif',
    ]) {
      imageCache.putIfAbsent(
        NetworkImage(url),
        () => PendingImageStreamCompleter(),
      );
    }
    addTearDown(() {
      imageCache.clear();
      imageCache.clearLiveImages();
    });

    await tester.pumpWidget(const MyApp());
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    final context = tester.element(find.byType(ChatScreen));
    expect(context.read<ChatProvider>(), isA<ChatProvider>());

    expect(app.title, 'Yes No App');
    expect(app.home, isA<ChatScreen>());
    expect(app.debugShowCheckedModeBanner, isFalse);
    expect(find.text('Hola amor!'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Hola CBUM');
    await tester.tap(find.byIcon(Icons.send_outlined));
    await tester.pumpAndSettle();
    expect(context.read<ChatProvider>().messageList.last.text, 'Hola CBUM');
    expect(find.text('Hola CBUM'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
  });

  testWidgets('La caja de mensajes permite escribir', (tester) async {
    final sentMessages = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MessageFieldBox(onValue: sentMessages.add)),
      ),
    );

    expect(find.text('End your message with a "?"'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Hola');
    expect(find.text('Hola'), findsOneWidget);
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    expect(sentMessages, ['Hola']);
    expect(find.text('Hola'), findsNothing);
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.byIcon(Icons.send_outlined));
    expect(sentMessages, ['Hola']);
  });
}
