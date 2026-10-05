import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tikitoki/presentation/providers/discover_provider.dart';
import 'package:tikitoki/presentation/screen/discover/discover_screen.dart';
import 'package:tikitoki/presentation/widgets/video/fullscreen_player.dart';

void main() {
  testWidgets(
    'Si todos los videos fallan el filtro, muestra un aviso sin reproductor',
    (tester) async {
      final provider = DiscoverProvider(
        source: [
          {'name': 'Inválido', 'videoUrl': 'bad.mp4', 'likes': 2, 'views': 1},
        ],
      );
      addTearDown(provider.dispose);
      await provider.loadNextPage();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: DiscoverScreen()),
        ),
      );
      expect(find.textContaining('No hay videos disponibles'), findsOneWidget);
      expect(find.byType(FullScreenPlayer), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );
}
