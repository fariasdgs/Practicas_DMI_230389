import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:tikitoki/domain/entities/video_post.dart';
import 'package:tikitoki/config/theme/app_theme.dart';
import 'package:tikitoki/presentation/widgets/shared/video_description.dart';
import 'package:tikitoki/presentation/widgets/shared/video_buttons.dart';

class YoutubeVideoPlayer extends StatefulWidget {
  final VideoPost video;
  final AppSeason season;
  const YoutubeVideoPlayer({
    super.key,
    required this.video,
    this.season = AppSeason.tech,
  });

  @override
  State<YoutubeVideoPlayer> createState() => _YoutubeVideoPlayerState();
}

class _YoutubeVideoPlayerState extends State<YoutubeVideoPlayer> {
  late final YoutubePlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = YoutubePlayerController.fromVideoId(
      videoId: widget.video.youtubeId!,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        interfaceLanguage: 'es',
        captionLanguage: 'es',
      ),
    );
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  Future<void> _openYoutube() async {
    try {
      if (!await launchUrl(Uri.parse(widget.video.sourceUrl!))) {
        throw StateError('No se pudo abrir YouTube');
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir YouTube.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: YoutubePlayer(controller: controller, aspectRatio: 16 / 9),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VideoDescription(
                      caption: widget.video.caption,
                      season: widget.season,
                      author: widget.video.author,
                      source: 'YouTube',
                      onSourceTap: _openYoutube,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Desliza fuera del reproductor para cambiar de video.',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              VideoButtons(video: widget.video),
            ],
          ),
        ),
      ],
    );
  }
}
