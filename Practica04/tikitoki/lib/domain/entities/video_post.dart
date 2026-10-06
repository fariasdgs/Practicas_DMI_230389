class VideoPost {
  final String caption;
  final String videoUrl;
  final int likes;
  final int views;
  final String? id;
  final String? sourceName;
  final String? sourceUrl;
  final String? author;
  final String? youtubeId;

  String get storageId => id ?? videoUrl;
  bool get isNetwork => Uri.tryParse(videoUrl)?.scheme == 'https';

  VideoPost({
    required this.caption,
    required this.videoUrl,
    this.likes = 0,
    this.views = 0,
    this.id,
    this.sourceName,
    this.sourceUrl,
    this.author,
    this.youtubeId,
  });
}
