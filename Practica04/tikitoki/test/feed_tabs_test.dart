import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:tikitoki/config/theme/app_theme.dart';
import 'package:tikitoki/infraestructure/repositories/remote_video_repository.dart';
import 'package:tikitoki/presentation/providers/discover_provider.dart';
import 'package:tikitoki/presentation/screen/discover/discover_screen.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class TestVideoPlatform extends VideoPlayerPlatform {
  final sources = <int, DataSource>{};
  final playing = <int>{};
  final streams = <int, StreamController<VideoEvent>>{};

  @override
  Future<void> init() async {}
  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    final id = sources.length;
    sources[id] = options.dataSource;
    streams[id] = StreamController<VideoEvent>()
      ..add(
        VideoEvent(
          eventType: VideoEventType.initialized,
          duration: const Duration(minutes: 1),
          size: const Size(1080, 1920),
        ),
      );
    return id;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => streams[playerId]!.stream;
  @override
  Future<void> dispose(int playerId) async {
    playing.remove(playerId);
    await streams[playerId]!.close();
  }

  @override
  Future<void> play(int playerId) async {
    playing.add(playerId);
  }

  @override
  Future<void> pause(int playerId) async {
    playing.remove(playerId);
  }

  @override
  Future<void> setLooping(int playerId, bool looping) async {}
  @override
  Future<void> setVolume(int playerId, double volume) async {}
  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}
  @override
  Future<void> setPreventsDisplaySleepDuringVideoPlayback(
    int playerId,
    bool value,
  ) async {}
  @override
  Future<Duration> getPosition(int playerId) async => Duration.zero;
  @override
  Widget buildView(int playerId) => const ColoredBox(color: Colors.black);
}

void main() {
  testWidgets('Pestañas separan los feeds y pausan el video oculto', (
    tester,
  ) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    final previousPlatform = VideoPlayerPlatform.instance;
    final platform = TestVideoPlatform();
    VideoPlayerPlatform.instance = platform;
    addTearDown(() {
      VideoPlayerPlatform.instance = previousPlatform;
    });
    var requests = 0;
    final provider = DiscoverProvider(
      source: [
        {
          'name': 'Mi video local',
          'videoUrl': 'local.mp4',
          'likes': 2,
          'views': 3,
        },
      ],
      remoteRepository: RemoteVideoRepository(
        youtubeKey: 'test-youtube',
        pixabayKey: '',
        client: MockClient((request) async {
          requests++;
          if (request.url.host == 'www.googleapis.com') {
            return http.Response(jsonEncode({'items': []}), 200);
          }
          return http.Response(
            jsonEncode(
              request.url.path == '/search'
                  ? {
                      'collection': {
                        'items': [
                          {
                            'data': [
                              {'nasa_id': 'one', 'title': 'Video espacial'},
                            ],
                          },
                        ],
                      },
                    }
                  : {
                      'collection': {
                        'items': [
                          {'href': 'https://images-assets.nasa.gov/one.mp4'},
                        ],
                      },
                    },
            ),
            200,
          );
        }),
      ),
    );
    addTearDown(provider.dispose);
    await provider.loadNextPage();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: DiscoverScreen(season: AppSeason.halloween),
        ),
      ),
    );
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(requests, 0, reason: 'DESCUBRIR carga al seleccionarse');
    expect(find.text('Mi video local'), findsOneWidget);
    expect(find.text('🎃  👻'), findsOneWidget);
    expect(platform.playing, {0});
    await tester.tap(find.text('DESCUBRIR'));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(find.text('Video espacial'), findsOneWidget);
    expect(find.text('Mi video local'), findsNothing);
    expect(find.textContaining('Pixabay: falta configurar'), findsOneWidget);
    expect(platform.sources[1]!.sourceType, DataSourceType.network);
    expect(platform.playing, {1});
    await tester.tap(find.text('PARA TI'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(platform.playing, {0});
    expect(find.text('Mi video local'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
