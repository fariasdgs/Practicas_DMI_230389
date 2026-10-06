import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tikitoki/config/theme/app_theme.dart';
import 'package:tikitoki/domain/entities/video_post.dart';
import 'package:tikitoki/presentation/widgets/shared/video_buttons.dart';
import 'package:tikitoki/presentation/widgets/video/fullscreen_player.dart';

class VideoScrollableView extends StatefulWidget {
  final List<VideoPost> videos;
  final AppSeason season;
  final bool isActive;

  const VideoScrollableView({
    super.key,
    required this.videos,
    this.season = AppSeason.tech,
    this.isActive = true,
  });

  @override
  State<VideoScrollableView> createState() => _VideoScrollableViewState();
}

class _VideoScrollableViewState extends State<VideoScrollableView> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      itemCount: widget.videos.length,
      onPageChanged: (index) => setState(() => currentIndex = index),
      itemBuilder: (context, index) {
        final videoPost = widget.videos[index];

        return Stack(
          children: [
            // Video player + gradiente
            SizedBox.expand(
              child: FullScreenPlayer(
                videoUrl: videoPost.videoUrl,
                caption: videoPost.caption,
                key: ValueKey(videoPost.storageId),
                isActive: widget.isActive && index == currentIndex,
                season: widget.season,
                isNetwork: videoPost.isNetwork,
                attribution: videoPost.sourceName == null
                    ? null
                    : '${videoPost.sourceName} · ${videoPost.author ?? videoPost.sourceName}',
                onAttributionTap: videoPost.sourceUrl == null
                    ? null
                    : () async {
                        final url = Uri.tryParse(videoPost.sourceUrl!);
                        if (url == null || url.scheme != 'https') return;
                        try {
                          final opened = await launchUrl(url);
                          if (!opened) {
                            throw StateError('No se pudo abrir el enlace');
                          }
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'No se pudo abrir el crédito del video.',
                              ),
                            ),
                          );
                        }
                      },
              ),
            ),

            // botones
            Positioned(
              bottom: 40,
              right: 20,
              child: VideoButtons(video: videoPost),
            ),
          ],
        );
      },
    );
  }
}
