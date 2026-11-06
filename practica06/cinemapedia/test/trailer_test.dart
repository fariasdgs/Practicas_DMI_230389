import 'package:cinemapedia/config/constants/movie_country.dart';
import 'package:cinemapedia/infraestructure/datasources/moviedb_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> video(
  String key, {
  String type = 'Trailer',
  String site = 'YouTube',
  bool official = true,
  String date = '2026-11-01T00:00:00Z',
}) => {
  'key': key,
  'name': 'Trailer $key',
  'site': site,
  'type': type,
  'official': official,
  'published_at': date,
  'iso_639_1': 'es',
};

void main() {
  setUp(() => dotenv.loadFromString(envString: 'THE_MOVIEDB_KEY=test'));

  test(
    'Chooses the latest official local trailer and ignores unrelated videos',
    () async {
      final languages = <String>[];
      final client = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (request, handler) {
              expect(request.path, '/movie/12/videos');
              languages.add(request.queryParameters['language']);
              handler.resolve(
                Response(
                  requestOptions: request,
                  data: {
                    'results': [
                      video('clipclip123', type: 'Clip'),
                      video('vimeovideo1', site: 'Vimeo'),
                      video('bad/key'),
                      video(
                        'unofficial1',
                        official: false,
                        date: '2026-11-05T00:00:00Z',
                      ),
                      video('oldofficial', date: '2025-01-01T00:00:00Z'),
                      video('newofficial'),
                    ],
                  },
                ),
              );
            },
          ),
        );
      final trailer = await MoviedbDatasource(
        country: MovieCountry.mexico,
        client: client,
      ).getTrailer('12');
      expect(trailer!.videoId, 'newofficial');
      expect(trailer.language, 'es');
      expect(trailer.youtubeUrl.host, 'www.youtube.com');
      expect(languages, ['es-MX']);
    },
  );

  test('Uses English when no supported local trailer is available', () async {
    final languages = <String>[];
    final client = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            final language = request.queryParameters['language'] as String;
            languages.add(language);
            handler.resolve(
              Response(
                requestOptions: request,
                data: {
                  'results': language == 'en-US'
                      ? [
                          {...video('english1234'), 'iso_639_1': 'en'},
                        ]
                      : [],
                },
              ),
            );
          },
        ),
      );
    final trailer = await MoviedbDatasource(
      country: MovieCountry.japan,
      client: client,
    ).getTrailer('12');
    expect(trailer!.language, 'en');
    expect(languages, ['ja-JP', 'en-US']);
  });

  test('Returns no trailer instead of substituting a clip or teaser', () async {
    var count = 0;
    final client = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            count++;
            handler.resolve(
              Response(
                requestOptions: request,
                data: {
                  'results': [video('teaser12345', type: 'Teaser')],
                },
              ),
            );
          },
        ),
      );
    expect(
      await MoviedbDatasource(
        country: MovieCountry.usa,
        client: client,
      ).getTrailer('12'),
      isNull,
    );
    expect(count, 1);
  });

  test(
    'A failed request remains an error so the screen can offer retry',
    () async {
      final client = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (request, handler) {
              handler.reject(
                DioException(
                  requestOptions: request,
                  type: DioExceptionType.connectionError,
                ),
              );
            },
          ),
        );
      expect(
        MoviedbDatasource(client: client).getTrailer('12'),
        throwsA(isA<DioException>()),
      );
    },
  );
}
