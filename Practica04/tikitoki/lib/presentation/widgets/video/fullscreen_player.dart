import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tikitoki/config/theme/app_theme.dart';
import 'package:tikitoki/presentation/widgets/video/video_background.dart';
import 'package:video_player/video_player.dart';
import 'package:tikitoki/presentation/widgets/shared/brand_loading.dart';
import 'package:tikitoki/presentation/widgets/shared/video_description.dart';

class FullScreenPlayer extends StatefulWidget {
  final String videoUrl;
  final String caption;
  final bool isActive;
  final AppSeason season;
  final bool isNetwork;
  final String? attribution;
  final String? author;
  final VoidCallback? onAttributionTap;

  const FullScreenPlayer({
    super.key,
    required this.videoUrl,
    required this.caption,
    this.isActive = true,
    this.season = AppSeason.tech,
    this.isNetwork = false,
    this.attribution,
    this.author,
    this.onAttributionTap,
  });

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer> {
  late VideoPlayerController controller;
  late final Future<void> initializeVideo;
  Timer? playbackIconTimer;
  IconData? playbackIcon;
  bool isMuted = false;

  void _togglePlayback() {
    if (!widget.isActive) return;
    playbackIconTimer?.cancel();
    final isPlaying = controller.value.isPlaying;
    if (isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
    setState(() {
      playbackIcon = isPlaying ? Icons.pause : Icons.play_arrow;
    });
    if (!isPlaying) {
      playbackIconTimer = Timer(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() => playbackIcon = null);
      });
    }
  }

  void _toggleAudio() {
    setState(() => isMuted = !isMuted);
    controller.setVolume(isMuted ? 0 : 1);
  }

  @override
  void initState() {
    super.initState();
    controller = widget.isNetwork
        ? VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
        : VideoPlayerController.asset(widget.videoUrl);
    initializeVideo = _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    await controller.initialize().timeout(const Duration(seconds: 25));
    if (!mounted) return;
    await controller.setVolume(1);
    if (!mounted) return;
    await controller.setLooping(true);
    if (!mounted) return;
    if (widget.isActive) {
      await controller.play();
    }
  }

  @override
  void didUpdateWidget(covariant FullScreenPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive == widget.isActive ||
        !controller.value.isInitialized) {
      return;
    }
    if (widget.isActive) {
      controller.play();
    } else {
      controller.pause();
    }
    playbackIconTimer?.cancel();
    playbackIcon = null;
  }

  @override
  void dispose() {
    playbackIconTimer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: initializeVideo,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No se pudo reproducir este video. Desliza para ver el siguiente.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return BrandLoading(season: widget.season);
        }
        return GestureDetector(
          onTap: _togglePlayback,
          child: Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                ),
              ),

              // Degradado oscuro detrás del texto del video.
              const VideoBackground(),

              if (playbackIcon != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Icon(
                        playbackIcon,
                        size: 80,
                        color: Colors.white,
                        shadows: const [
                          Shadow(color: Colors.black54, blurRadius: 12),
                        ],
                      ),
                    ),
                  ),
                ),

              Positioned(
                top: 0,
                right: 12,
                child: SafeArea(
                  child: IconButton(
                    onPressed: _toggleAudio,
                    tooltip: isMuted ? 'Activar audio' : 'Silenciar audio',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black45,
                      foregroundColor: Colors.white,
                    ),
                    icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
                  ),
                ),
              ),

              //text
              Positioned(
                bottom: 50,
                left: 20,
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width - 110,
                  child: VideoDescription(
                    caption: widget.caption,
                    season: widget.season,
                    source: widget.attribution,
                    author: widget.author,
                    onSourceTap: widget.onAttributionTap,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
