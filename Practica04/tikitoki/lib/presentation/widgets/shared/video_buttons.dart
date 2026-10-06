import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tikitoki/config/helpers/human_formats.dart';
import 'package:tikitoki/domain/entities/video_post.dart';
import 'package:tikitoki/presentation/providers/discover_provider.dart';

class VideoButtons extends StatelessWidget {
  final VideoPost video;

  const VideoButtons({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final discover = context.watch<DiscoverProvider>();
    final liked = discover.isLiked(video);
    final likes = discover.likesFor(video);
    return Column(
      children: [
        _CustomIconButton(
          value: likes,
          iconData: liked ? Icons.favorite : Icons.favorite_border,
          iconColor: liked ? colors.secondary : Colors.white,
          tooltip: '${liked ? 'Quitar like' : 'Dar like'} · $likes likes',
          onPressed: discover.isSavingLike(video)
              ? null
              : () async {
                  try {
                    await discover.toggleLike(video);
                  } catch (_) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No se pudo guardar tu like. Inténtalo de nuevo.',
                        ),
                      ),
                    );
                  }
                },
        ),
        const SizedBox(height: 20),
        _CustomIconButton(
          value: video.views,
          iconData: Icons.remove_red_eye_outlined,
          iconColor: colors.primary,
        ),
        const SizedBox(height: 20),
        SpinPerfect(
          infinite: true,
          duration: const Duration(seconds: 5),
          child: _CustomIconButton(
            value: 0,
            iconData: Icons.play_circle_outlined,
            iconColor: colors.primary,
          ),
        ),
      ],
    );
  }
}

class _CustomIconButton extends StatelessWidget {
  final int value;
  final IconData iconData;
  final Color? color;
  final VoidCallback? onPressed;
  final String? tooltip;

  const _CustomIconButton({
    required this.value,
    required this.iconData,
    iconColor,
    this.onPressed,
    this.tooltip,
  }) : color = iconColor ?? Colors.white;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: tooltip == null ? () {} : onPressed,
          tooltip: tooltip,
          icon: Icon(iconData, color: color, size: 30),
        ),
        if (value > 0) Text(HumanFormats.humanReadbleNumber(value.toDouble())),
      ],
    );
  }
}
