import 'package:cinemapedia/domain/entities/movie_trailer.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_country_provider.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class MovieTrailerSection extends ConsumerWidget {
  final String movieId;
  const MovieTrailerSection({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(movieCountryProvider);
    final trailer = ref.watch(movieTrailerProvider(movieId));
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            country.text('trailer'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          trailer.when(
            loading: () => const SizedBox(
              height: 150,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(country.text('trailerError')),
                TextButton.icon(
                  onPressed: () =>
                      ref.invalidate(movieTrailerProvider(movieId)),
                  icon: const Icon(Icons.refresh),
                  label: Text(country.text('retry')),
                ),
              ],
            ),
            data: (video) => video == null
                ? Text(country.text('noTrailer'))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TrailerPlayer(
                        key: ValueKey(
                          '${video.videoId}-${country.languageCode}',
                        ),
                        trailer: video,
                        language: country.languageCode,
                        playLabel: country.text('playTrailer'),
                      ),
                      const SizedBox(height: 8),
                      if (video.title.isNotEmpty)
                        Text(
                          video.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      Text(
                        '${country.text('trailerLanguage')}: ${video.language.toUpperCase()}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          try {
                            final launched = await launchUrl(
                              video.youtubeUrl,
                              mode: LaunchMode.externalApplication,
                            );
                            if (!launched) {
                              throw StateError('Video could not be opened');
                            }
                          } catch (_) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(country.text('trailerError')),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: Text(country.text('youtube')),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _TrailerPlayer extends StatefulWidget {
  final MovieTrailer trailer;
  final String language;
  final String playLabel;
  const _TrailerPlayer({
    super.key,
    required this.trailer,
    required this.language,
    required this.playLabel,
  });

  @override
  State<_TrailerPlayer> createState() => _TrailerPlayerState();
}

class _TrailerPlayerState extends State<_TrailerPlayer> {
  YoutubePlayerController? _controller;

  void _play() {
    setState(() {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: widget.trailer.videoId,
        autoPlay: true,
        params: YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          interfaceLanguage: widget.language,
          captionLanguage: widget.language,
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: _controller != null
          ? YoutubePlayer(controller: _controller!, aspectRatio: 16 / 9)
          : AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.trailer.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => ColoredBox(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      child: const Icon(Icons.movie_outlined, size: 48),
                    ),
                  ),
                  const ColoredBox(color: Colors.black38),
                  Center(
                    child: FilledButton.icon(
                      onPressed: _play,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(widget.playLabel),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
