class MovieTrailer {
  final String videoId;
  final String title;
  final String language;

  const MovieTrailer({
    required this.videoId,
    required this.title,
    required this.language,
  });

  Uri get youtubeUrl => Uri.https('www.youtube.com', '/watch', {'v': videoId});
  String get thumbnailUrl => 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg';
}
