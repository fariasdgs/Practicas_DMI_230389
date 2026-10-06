import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tikitoki/presentation/widgets/video/video_background.dart';
import 'package:video_player/video_player.dart';

class FullScreenPlayer extends StatefulWidget {
  final String videoUrl;
  final String caption;
  final bool isActive;

  const FullScreenPlayer({
    super.key,
    required this.videoUrl,
    required this.caption,
    this.isActive = true,
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
    controller = VideoPlayerController.asset(widget.videoUrl);
    initializeVideo = _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    await controller.initialize();
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
                'No se pudo cargar el video: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        return GestureDetector(
          onTap: _togglePlayback,
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: Stack(
              children: [
                VideoPlayer(controller),

                //gradient
                VideoBackground(stops: const [0.8, 1.0]),

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
                  child: _VideoCaption(caption: widget.caption),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VideoCaption extends StatelessWidget {
  final String caption;

  const _VideoCaption({required this.caption});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final tittleStyle = Theme.of(context).textTheme.titleLarge;

    return SizedBox(
      width: size.width * 0.6,
      child: Text(caption, maxLines: 2, style: tittleStyle),
    );
  }
}
