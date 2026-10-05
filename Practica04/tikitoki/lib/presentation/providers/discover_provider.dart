import 'package:flutter/material.dart';
import 'package:tikitoki/domain/entities/video_post.dart';
import 'package:tikitoki/infraestructure/models/local_video_model.dart';
import 'package:tikitoki/shared/data/local_video_post.dart';

class DiscoverProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _source;

  DiscoverProvider({List<Map<String, dynamic>>? source})
    : _source = source ?? videoPosts;

  bool initialLoading = true;
  List<VideoPost> videos = [];

  Future<void> loadNextPage() async {
    //await Future.delayed(const Duration(seconds: 2));

    final List<VideoPost> newVideos = _source
        .map((video) => LocalVideoModel.fromJson(video).toVideoPostEntity())
        .where((video) => video.views >= video.likes)
        .toList();

    videos.addAll(newVideos);
    initialLoading = false;
    notifyListeners();
  }
}
