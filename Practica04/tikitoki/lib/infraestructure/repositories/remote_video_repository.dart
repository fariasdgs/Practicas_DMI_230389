import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tikitoki/domain/entities/video_post.dart';

class RemoteVideoResult {
  final List<VideoPost> videos;
  final List<String> notices;

  const RemoteVideoResult({required this.videos, this.notices = const []});
}

class RemoteVideoRepository {
  final http.Client _client;
  final String pixabayKey;
  final SharedPreferencesAsync _cache;

  RemoteVideoRepository({
    http.Client? client,
    this.pixabayKey = const String.fromEnvironment('PIXABAY_API_KEY'),
    SharedPreferencesAsync? cache,
  }) : _client = client ?? http.Client(),
       _cache = cache ?? SharedPreferencesAsync();

  void dispose() => _client.close();

  Future<RemoteVideoResult> load() async {
    Future<RemoteVideoResult> fetch(
      String name,
      Future<List<VideoPost>> Function() request, {
      bool configured = true,
    }) async {
      if (!configured) {
        return RemoteVideoResult(
          videos: [],
          notices: ['$name: falta configurar la clave.'],
        );
      }
      try {
        final videos = await request();
        return RemoteVideoResult(
          videos: videos,
          notices: videos.isEmpty ? ['$name: no hay videos disponibles.'] : [],
        );
      } catch (_) {
        // No mostrar URLs ni respuestas: pueden contener claves de acceso.
        return RemoteVideoResult(
          videos: [],
          notices: ['$name: no se pudo cargar. Reintenta.'],
        );
      }
    }

    final results = await Future.wait([
      fetch('Internet Archive', _archive),
      fetch('Pixabay', _pixabay, configured: pixabayKey.trim().isNotEmpty),
      fetch('NASA', _nasa),
    ]);
    final videos = <VideoPost>[];
    // Alternar fuentes para que ninguna quede al final del feed.
    for (var index = 0; results.any((r) => index < r.videos.length); index++) {
      for (final result in results) {
        if (index < result.videos.length) videos.add(result.videos[index]);
      }
    }
    return RemoteVideoResult(
      videos: videos,
      notices: results.expand((r) => r.notices).toList(),
    );
  }

  Future<Map<String, dynamic>> _get(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    final response = await _client
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw const FormatException('Error del servicio');
    }
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  bool _playable(dynamic value) {
    final uri = value is String ? Uri.tryParse(value) : null;
    return uri != null &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty &&
        uri.path.toLowerCase().endsWith('.mp4');
  }

  List<Map<String, dynamic>> _items(dynamic value) =>
      value is List ? value.whereType<Map<String, dynamic>>().toList() : [];

  int _count(dynamic value) => value is num && value >= 0 ? value.toInt() : 0;

  Future<List<VideoPost>> _archive() async {
    final data = await _get(
      Uri.https('archive.org', '/advancedsearch.php', {
        'q':
            'mediatype:movies AND creator:"Blender Foundation" AND '
            '(title:Caminandes OR title:Spring OR title:"Big Buck Bunny") AND licenseurl:*',
        'output': 'json',
        'rows': '6',
        'fl[]': 'identifier',
      }),
    );
    final response = data['response'];
    if (response is! Map) return [];
    final videos = await Future.wait(
      _items(response['docs']).take(6).map((item) async {
        try {
          final id = item['identifier'] as String;
          final record = await _get(Uri.https('archive.org', '/metadata/$id'));
          if (record['is_dark'] == true) return null;
          final metadata = record['metadata'] as Map;
          final license = Uri.tryParse('${metadata['licenseurl'] ?? ''}');
          if (license == null ||
              license.host != 'creativecommons.org' ||
              !(license.path.startsWith('/licenses/by/') ||
                  license.path.startsWith('/licenses/by-sa/'))) {
            return null;
          }
          final files = _items(record['files']).where((file) {
            final name = file['name'];
            final size = int.tryParse('${file['size']}') ?? 0;
            return name is String &&
                name.toLowerCase().endsWith('.mp4') &&
                file['private'] != 'true' &&
                file['private'] != true &&
                size > 0 &&
                size <= 250000000;
          }).toList();
          if (files.isEmpty) return null;
          files.sort(
            (a, b) =>
                int.parse('${a['size']}').compareTo(int.parse('${b['size']}')),
          );
          final name = files.first['name'] as String;
          final creator = metadata['creator'];
          final author = creator is List
              ? creator.join(', ')
              : '${creator ?? 'Blender Foundation'}';
          return VideoPost(
            id: 'archive:$id',
            caption: '${metadata['title'] ?? 'Corto de animación'}',
            videoUrl: Uri(
              scheme: 'https',
              host: 'archive.org',
              pathSegments: ['download', id, ...name.split('/')],
            ).toString(),
            sourceName: 'Internet Archive',
            sourceUrl: Uri.https('archive.org', '/details/$id').toString(),
            author:
                '$author · ${license.path.startsWith('/licenses/by-sa/') ? 'CC BY-SA' : 'CC BY'}',
          );
        } catch (_) {
          return null;
        }
      }),
    );
    return videos.whereType<VideoPost>().toList();
  }

  Future<List<VideoPost>> _pixabay() async {
    const cacheKey = 'tikitoki.pixabay.nature.v1';
    Map<String, dynamic>? data;
    try {
      final saved = await _cache.getString(cacheKey);
      if (saved != null) {
        final record = jsonDecode(saved) as Map<String, dynamic>;
        final savedAt = DateTime.fromMillisecondsSinceEpoch(
          record['savedAt'] as int,
        );
        final age = DateTime.now().difference(savedAt);
        if (!age.isNegative && age < const Duration(hours: 24)) {
          data = record['data'] as Map<String, dynamic>;
        }
      }
    } catch (_) {
      // Una caché corrupta no impide consultar el servicio.
    }
    if (data == null) {
      data = await _get(
        Uri.https('pixabay.com', '/api/videos/', {
          'key': pixabayKey,
          'q': 'nature',
          'per_page': '6',
          'safesearch': 'true',
        }),
      );
      // Guardar la respuesta 24 horas como exige Pixabay, sin guardar la clave.
      await _cache.setString(
        cacheKey,
        jsonEncode({
          'savedAt': DateTime.now().millisecondsSinceEpoch,
          'data': data,
        }),
      );
    }
    final videos = <VideoPost>[];
    for (final item in _items(data['hits'])) {
      final variants = item['videos'];
      if (variants is! Map || item['id'] == null) continue;
      String? url;
      for (final size in ['small', 'tiny', 'medium']) {
        final file = variants[size];
        if (file is Map && _playable(file['url'])) {
          url = file['url'] as String;
          break;
        }
      }
      if (url == null) continue;
      videos.add(
        VideoPost(
          id: 'pixabay:${item['id']}',
          caption: '${item['tags'] ?? 'Naturaleza'}',
          videoUrl: url,
          likes: _count(item['likes']),
          views: _count(item['views']),
          sourceName: 'Pixabay',
          sourceUrl: item['pageURL'] as String?,
          author: item['user'] as String?,
        ),
      );
    }
    return videos;
  }

  Future<List<VideoPost>> _nasa() async {
    final data = await _get(
      Uri.https('images-api.nasa.gov', '/search', {
        'q': 'space',
        'media_type': 'video',
        'page_size': '6',
      }),
    );
    final collection = data['collection'];
    if (collection is! Map) return [];
    final videos = await Future.wait(
      _items(collection['items']).take(6).map((item) async {
        try {
          final metadata = _items(item['data']).first;
          final id = metadata['nasa_id'] as String;
          final assets = await _get(
            Uri.https('images-api.nasa.gov', '/asset/$id'),
          );
          final manifest = assets['collection'] as Map;
          final urls = _items(manifest['items'])
              .map((file) {
                final href = file['href'];
                final uri = href is String ? Uri.tryParse(href) : null;
                // NASA todavía devuelve algunos enlaces HTTP; usar su CDN HTTPS.
                if (uri != null && uri.host == 'images-assets.nasa.gov') {
                  return uri.replace(scheme: 'https').toString();
                }
                return href;
              })
              .where(_playable)
              .cast<String>()
              .toList();
          if (urls.isEmpty) return null;
          final url = urls.firstWhere(
            (url) => url.contains('~medium'),
            orElse: () => urls.firstWhere(
              (url) => url.contains('~small'),
              orElse: () => urls.first,
            ),
          );
          return VideoPost(
            id: 'nasa:$id',
            caption: '${metadata['title'] ?? 'Explora el espacio'}',
            videoUrl: url,
            sourceName: 'NASA',
            author: 'NASA',
            sourceUrl: Uri.https('images.nasa.gov', '/details/$id').toString(),
          );
        } catch (_) {
          return null;
        }
      }),
    );
    return videos.whereType<VideoPost>().toList();
  }
}
