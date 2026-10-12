import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:tikitoki/infraestructure/repositories/remote_video_repository.dart';
import 'package:tikitoki/presentation/providers/discover_provider.dart';

http.Response jsonResponse(Object data) => http.Response(
  jsonEncode(data),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test(
    'YouTube sin clave ofrece ejemplos, sin simular búsqueda por API',
    () async {
      final repo = RemoteVideoRepository(
        youtubeKey: '',
        pixabayKey: '',
        client: MockClient((request) async {
          expect(request.url.host, 'images-api.nasa.gov');
          return jsonResponse({
            'collection': {'items': []},
          });
        }),
      );
      addTearDown(repo.dispose);
      final result = await repo.load();
      expect(result.videos, hasLength(2));
      expect(result.videos.every((video) => video.youtubeId != null), isTrue);
    },
  );

  test('Adapta tres fuentes, elige MP4, alterna y conserva créditos', () async {
    var pixabayCalls = 0;
    final repo = RemoteVideoRepository(
      youtubeKey: 'test-youtube',
      pixabayKey: 'test-pixabay',
      client: MockClient((request) async {
        if (request.url.host == 'www.googleapis.com') {
          expect(request.url.queryParameters['videoEmbeddable'], 'true');
          expect(request.url.queryParameters['key'], 'test-youtube');
          return jsonResponse({
            'items': [
              {
                'id': {'videoId': 'M7lc1UVf-VE'},
                'snippet': {
                  'title': 'Video de YouTube',
                  'channelTitle': 'Canal',
                },
              },
              {
                'id': {'videoId': 'invalid'},
                'snippet': {'title': 'Inválido'},
              },
            ],
          });
        }
        if (request.url.host == 'pixabay.com') {
          pixabayCalls++;
          expect(request.url.queryParameters['key'], 'test-pixabay');
          return jsonResponse({
            'hits': [
              {
                'id': 1,
                'tags': 'bosque',
                'likes': 5,
                'views': 8,
                'user': 'Persona',
                'pageURL': 'https://pixabay.com/videos/id-1/',
                'videos': {
                  'small': {'url': 'https://cdn.test/pixabay.mp4'},
                },
              },
            ],
          });
        }
        if (request.url.path == '/search') {
          return jsonResponse({
            'collection': {
              'items': [
                {
                  'data': [
                    {'nasa_id': 'space-one', 'title': 'Espacio'},
                  ],
                },
                {
                  'data': [
                    {'nasa_id': 'broken', 'title': 'Falla'},
                  ],
                },
              ],
            },
          });
        }
        if (request.url.path.endsWith('/broken')) return http.Response('', 500);
        return jsonResponse({
          'collection': {
            'items': [
              {
                'href':
                    'http://images-assets.nasa.gov/video/space-one~orig.mp4',
              },
              {
                'href':
                    'http://images-assets.nasa.gov/video/space-one~medium.mp4',
              },
              {'href': 'https://images-assets.nasa.gov/video/thumb.jpg'},
            ],
          },
        });
      }),
    );
    addTearDown(repo.dispose);
    final result = await repo.load();
    expect(result.videos.map((v) => v.storageId), [
      'youtube:M7lc1UVf-VE',
      'pixabay:1',
      'nasa:space-one',
    ]);
    expect(
      result.videos.first.videoUrl,
      'https://www.youtube.com/watch?v=M7lc1UVf-VE',
    );
    expect(
      result.videos.last.videoUrl,
      'https://images-assets.nasa.gov/video/space-one~medium.mp4',
    );
    expect(
      result.videos.every((v) => v.isNetwork && v.sourceUrl != null),
      isTrue,
    );
    expect(result.videos[1].likes, 5);
    expect(result.notices, isEmpty);
    await repo.load();
    expect(
      pixabayCalls,
      1,
      reason: 'Pixabay reutiliza la respuesta durante 24 horas',
    );
  });

  test('Fallas y claves ausentes no ocultan videos de otra fuente', () async {
    final repo = RemoteVideoRepository(
      youtubeKey: 'test-youtube',
      pixabayKey: 'key-not-to-display',
      client: MockClient((request) async {
        if (request.url.host == 'www.googleapis.com') {
          return http.Response('', 503);
        }
        if (request.url.host == 'pixabay.com') {
          return http.Response('key-not-to-display', 401);
        }
        if (request.url.path == '/search') {
          return jsonResponse({
            'collection': {
              'items': [
                {
                  'data': [
                    {'nasa_id': 'one', 'title': 'NASA'},
                  ],
                },
              ],
            },
          });
        }
        return jsonResponse({
          'collection': {
            'items': [
              {'href': 'http://images-assets.nasa.gov/one.mp4'},
            ],
          },
        });
      }),
    );
    addTearDown(repo.dispose);
    final result = await repo.load();
    expect(result.videos.single.sourceName, 'NASA');
    expect(result.notices, hasLength(2));
    expect(result.notices.join(), isNot(contains('key-not-to-display')));
  });

  test(
    'El like remoto usa ID estable aunque cambie el enlace; no altera PARA TI',
    () async {
      var revision = 1;
      RemoteVideoRepository repository() => RemoteVideoRepository(
        youtubeKey: 'test-youtube',
        pixabayKey: '',
        client: MockClient((request) async {
          if (request.url.host == 'www.googleapis.com') {
            return jsonResponse({'items': []});
          }
          if (request.url.path == '/search') {
            return jsonResponse({
              'collection': {
                'items': [
                  {
                    'data': [
                      {'nasa_id': 'same-id', 'title': 'NASA'},
                    ],
                  },
                ],
              },
            });
          }
          return jsonResponse({
            'collection': {
              'items': [
                {
                  'href':
                      'https://images-assets.nasa.gov/version-$revision.mp4',
                },
              ],
            },
          });
        }),
      );
      final provider = DiscoverProvider(remoteRepository: repository());
      addTearDown(provider.dispose);
      await provider.loadNextPage();
      final localCount = provider.videos.length;
      await provider.loadRemoteVideos();
      await provider.toggleLike(provider.remoteVideos.single);
      expect(provider.likesFor(provider.remoteVideos.single), 1);
      revision++;
      final reopened = DiscoverProvider(remoteRepository: repository());
      addTearDown(reopened.dispose);
      await reopened.loadRemoteVideos();
      expect(reopened.remoteVideos.single.videoUrl, contains('version-2'));
      expect(reopened.isLiked(reopened.remoteVideos.single), isTrue);
      await reopened.toggleLike(reopened.remoteVideos.single);
      expect(reopened.likesFor(reopened.remoteVideos.single), 0);
      expect(provider.videos.length, localCount);
    },
  );
}
