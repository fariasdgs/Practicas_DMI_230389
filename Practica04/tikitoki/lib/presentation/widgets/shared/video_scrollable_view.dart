import 'package:flutter/material.dart';
import 'package:tikitoki/domain/entities/video_post.dart';
import 'package:tikitoki/presentation/widgets/shared/video_buttons.dart';
import 'package:tikitoki/presentation/widgets/video/fullscreen_player.dart';

class VideoScrollableView extends StatefulWidget {
  final List<VideoPost> videos;

  const VideoScrollableView({super.key, required this.videos});

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
                isActive: index == currentIndex,
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
