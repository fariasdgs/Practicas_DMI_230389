import 'package:flutter/material.dart';
import 'package:tikitoki/config/theme/app_theme.dart';

class VideoDescription extends StatelessWidget {
  final String caption;
  final AppSeason season;
  final String? author;
  final String? source;
  final VoidCallback? onSourceTap;
  const VideoDescription({
    super.key,
    required this.caption,
    required this.season,
    this.author,
    this.source,
    this.onSourceTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              author ?? (source == null ? 'Tu colección' : source!),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
            if (season != AppSeason.tech)
              ExcludeSemantics(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.primary.withValues(alpha: 0.22),
                        colors.secondary.withValues(alpha: 0.18),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 2,
                    ),
                    child: Text(
                      season == AppSeason.christmas ? '🎄  🎁  ✨' : '🎃  👻',
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          caption,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 17,
            height: 1.4,
          ),
        ),
        if (source != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onSourceTap,
            style: TextButton.styleFrom(
              foregroundColor: colors.primary,
              backgroundColor: Colors.black26,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.open_in_new_rounded, size: 13),
            label: Text(
              'Video de $source',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ],
    );
  }
}
