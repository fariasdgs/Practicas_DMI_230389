import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:tikitoki/presentation/providers/discover_provider.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test(
    'Dar y quitar like conserva el total original y persiste por video',
    () async {
      final source = [
        {'name': 'Uno', 'videoUrl': 'one.mp4', 'likes': 0, 'views': 0},
        {'name': 'Dos', 'videoUrl': 'two.mp4', 'likes': 10, 'views': 20},
      ];
      final provider = DiscoverProvider(source: source);
      addTearDown(provider.dispose);
      await provider.loadNextPage();
      final video = provider.videos.first;
      await provider.toggleLike(video);
      expect(provider.isLiked(video), isTrue);
      expect(provider.likesFor(video), 1);
      expect(provider.likesFor(provider.videos.last), 10);

      final reopened = DiscoverProvider(source: source);
      addTearDown(reopened.dispose);
      await reopened.loadNextPage();
      expect(reopened.isLiked(reopened.videos.first), isTrue);
      expect(reopened.likesFor(reopened.videos.first), 1);
      await reopened.toggleLike(reopened.videos.first);
      expect(reopened.likesFor(reopened.videos.first), 0);

      final reopenedAgain = DiscoverProvider(source: source);
      addTearDown(reopenedAgain.dispose);
      await reopenedAgain.loadNextPage();
      expect(reopenedAgain.isLiked(reopenedAgain.videos.first), isFalse);
      expect(reopenedAgain.likesFor(reopenedAgain.videos.first), 0);
    },
  );
  test(
    'Descarta vistas menores, conserva igualdad y orden, y notifica',
    () async {
      final provider = DiscoverProvider(
        source: [
          {'name': 'Inválido', 'videoUrl': 'bad.mp4', 'likes': 11, 'views': 10},
          {
            'name': 'Iguales',
            'videoUrl': 'equal.mp4',
            'likes': 10,
            'views': 10,
          },
          {
            'name': 'Más vistas',
            'videoUrl': 'valid.mp4',
            'likes': 10,
            'views': 11,
          },
          {'name': 'Sin métricas', 'videoUrl': 'zero.mp4'},
        ],
      );
      addTearDown(provider.dispose);
      var notifications = 0;
      provider.addListener(() => notifications++);
      await provider.loadNextPage();
      expect(provider.videos.map((v) => v.videoUrl), [
        'equal.mp4',
        'valid.mp4',
        'zero.mp4',
      ]);
      expect(provider.initialLoading, isFalse);
      expect(notifications, 1);
    },
  );

  test(
    'El catálogo actual omite los tres videos con cifras inválidas',
    () async {
      final provider = DiscoverProvider();
      addTearDown(provider.dispose);
      await provider.loadNextPage();
      expect(provider.videos, isNotEmpty);
      expect(provider.videos.every((v) => v.views >= v.likes), isTrue);
      expect(
        provider.videos.map((v) => v.videoUrl),
        isNot(contains('assets/videos/1.mp4')),
      );
      expect(
        provider.videos.map((v) => v.videoUrl),
        isNot(contains('assets/videos/2.mp4')),
      );
      expect(
        provider.videos.map((v) => v.videoUrl),
        isNot(contains('assets/videos/3.mp4')),
      );
      expect(
        provider.videos.map((v) => v.videoUrl),
        contains('assets/videos/9.mp4'),
      );
    },
  );
}
