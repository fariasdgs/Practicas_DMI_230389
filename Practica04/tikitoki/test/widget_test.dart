import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:tikitoki/presentation/providers/discover_provider.dart';
import 'package:tikitoki/presentation/screen/discover/discover_screen.dart';
import 'package:tikitoki/presentation/widgets/video/fullscreen_player.dart';
import 'package:tikitoki/presentation/widgets/shared/video_buttons.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('El corazón alterna y el contador suma y resta un like', (
    tester,
  ) async {
    final provider = DiscoverProvider(
      source: [
        {'name': 'Video', 'videoUrl': 'test.mp4', 'likes': 10, 'views': 20},
      ],
    );
    addTearDown(provider.dispose);
    await provider.loadNextPage();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: Scaffold(body: VideoButtons(video: provider.videos.first)),
        ),
      ),
    );
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pump();
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pump();
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
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
