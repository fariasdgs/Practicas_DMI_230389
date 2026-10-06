import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tikitoki/domain/entities/video_post.dart';
import 'package:tikitoki/infraestructure/models/local_video_model.dart';
import 'package:tikitoki/infraestructure/repositories/remote_video_repository.dart';
import 'package:tikitoki/shared/data/local_video_post.dart';

class DiscoverProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _source;

  DiscoverProvider({List<Map<String, dynamic>>? source, this.remoteRepository})
    : _source = source ?? videoPosts;

  bool initialLoading = true;
  List<VideoPost> videos = [];
  SharedPreferencesWithCache? _preferences;
  Future<SharedPreferencesWithCache>? _preferencesFuture;
  RemoteVideoRepository? remoteRepository;
  List<VideoPost> remoteVideos = [];
  List<String> remoteNotices = [];
  bool remoteLoading = false;
  bool remoteLoaded = false;
  final Set<String> _likedVideos = {};
  final Set<String> _savingLikes = {};
  bool _disposed = false;

  String _likeKey(String videoUrl) => 'tikitoki.like.$videoUrl';

  bool isLiked(VideoPost video) => _likedVideos.contains(video.storageId);

  bool isSavingLike(VideoPost video) => _savingLikes.contains(video.storageId);

  int likesFor(VideoPost video) => video.likes + (isLiked(video) ? 1 : 0);

  Future<void> toggleLike(VideoPost video) async {
    final preferences = _preferences;
    if (preferences == null || isSavingLike(video) || _disposed) return;
    final wasLiked = isLiked(video);
    final url = video.storageId;
    _savingLikes.add(url);
    if (wasLiked) {
      _likedVideos.remove(url);
    } else {
      _likedVideos.add(url);
    }
    notifyListeners();
    try {
      await preferences.setBool(_likeKey(url), !wasLiked);
    } catch (_) {
      if (wasLiked) {
        _likedVideos.add(url);
      } else {
        _likedVideos.remove(url);
      }
      rethrow;
    } finally {
      _savingLikes.remove(url);
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    remoteRepository?.dispose();
    super.dispose();
  }

  Future<void> loadNextPage() async {
    await _initializePreferences();
    if (_disposed) return;

    final List<VideoPost> newVideos = _source
        .map((video) => LocalVideoModel.fromJson(video).toVideoPostEntity())
        .where((video) => video.views >= video.likes)
        .toList();

    videos.addAll(newVideos);
    for (final video in newVideos) {
      if (_preferences!.getBool(_likeKey(video.storageId)) ?? false) {
        _likedVideos.add(video.storageId);
      }
    }
    initialLoading = false;
    notifyListeners();
  }

  Future<void> _initializePreferences() async {
    _preferencesFuture ??= SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
    _preferences = await _preferencesFuture;
  }

  Future<void> loadRemoteVideos({bool retry = false}) async {
    if (_disposed || remoteLoading || (remoteLoaded && !retry)) return;
    remoteLoading = true;
    notifyListeners();
    try {
      await _initializePreferences();
      if (_disposed) return;
      remoteRepository ??= RemoteVideoRepository();
      final result = await remoteRepository!.load();
      if (_disposed) return;
      remoteVideos = result.videos;
      remoteNotices = result.notices;
      for (final video in remoteVideos) {
        if (_preferences!.getBool(_likeKey(video.storageId)) ?? false) {
          _likedVideos.add(video.storageId);
        }
      }
      remoteLoaded = true;
    } catch (_) {
      remoteNotices = [
        'No se pudieron cargar los videos. Revisa tu conexión y reintenta.',
      ];
    } finally {
      remoteLoading = false;
      if (!_disposed) notifyListeners();
    }
  }
}
