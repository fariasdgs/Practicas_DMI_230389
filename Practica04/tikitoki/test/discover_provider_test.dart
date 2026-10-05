import 'package:flutter_test/flutter_test.dart';
import 'package:tikitoki/presentation/providers/discover_provider.dart';

void main() {
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
