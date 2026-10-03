import 'package:flutter/material.dart';
import 'package:tikitoki/domain/entities/video_post.dart';
import 'package:tikitoki/presentation/widgets/shared/video_buttons.dart';
import 'package:tikitoki/presentation/widgets/video/fullscreen_player.dart';

class VideoScrollableView extends StatelessWidget {
  final List<VideoPost> videos;

  const VideoScrollableView({super.key, required this.videos});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final videoPost = videos[index];

        return Stack(
          children: [
            // Video player + gradiente
            SizedBox.expand(
              child: FullScreenPlayer(
                videoUrl: videoPost.videoUrl,
                caption: videoPost.caption,
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
