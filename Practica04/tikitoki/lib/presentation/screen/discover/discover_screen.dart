import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tikitoki/config/theme/app_theme.dart';
import 'package:tikitoki/presentation/providers/discover_provider.dart';
import 'package:tikitoki/presentation/widgets/shared/video_scrollable_view.dart';

class DiscoverScreen extends StatelessWidget {
  final AppSeason season;

  const DiscoverScreen({super.key, this.season = AppSeason.tech});

  @override
  Widget build(BuildContext context) {
    final discoverProvider = context.watch<DiscoverProvider>();

    return Scaffold(
      body: discoverProvider.initialLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2.0))
          : discoverProvider.videos.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No hay videos disponibles con vistas mayores o iguales a los likes.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Stack(
              children: [
                VideoScrollableView(videos: discoverProvider.videos),
                if (season != AppSeason.tech)
                  Positioned(
                    top: 12,
                    left: 20,
                    child: SafeArea(
                      child: IgnorePointer(
                        child: Chip(
                          avatar: Icon(
                            season == AppSeason.halloween
                                ? Icons.nightlight_round
                                : Icons.ac_unit,
                            color: Theme.of(context).colorScheme.primary,
                            size: 18,
                          ),
                          label: Text(
                            season == AppSeason.halloween
                                ? 'Halloween'
                                : 'Navidad',
                          ),
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surface,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
