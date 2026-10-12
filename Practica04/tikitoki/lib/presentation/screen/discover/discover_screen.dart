import 'package:flutter/material.dart';
import 'package:tikitoki/presentation/widgets/shared/brand_loading.dart';
import 'package:provider/provider.dart';
import 'package:tikitoki/config/theme/app_theme.dart';
import 'package:tikitoki/presentation/providers/discover_provider.dart';
import 'package:tikitoki/presentation/widgets/shared/video_scrollable_view.dart';

class DiscoverScreen extends StatefulWidget {
  final AppSeason season;
  final bool playbackEnabled;

  const DiscoverScreen({
    super.key,
    this.season = AppSeason.tech,
    this.playbackEnabled = true,
  });

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  static const _paraTi = 0;
  static const _descubrir = 1;
  static const _favoritos = 2;

  int selectedTab = _paraTi;
  int remoteFeedVersion = 0;

  void _selectTab(int tab) {
    if (selectedTab == tab) return;
    setState(() => selectedTab = tab);
    // Favoritos también necesita los videos remotos que tengan like.
    if (tab != _paraTi) context.read<DiscoverProvider>().loadRemoteVideos();
  }

  Future<void> _retry() async {
    await context.read<DiscoverProvider>().loadRemoteVideos(retry: true);
    if (mounted) setState(() => remoteFeedVersion++);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiscoverProvider>();
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Row(
              children: [
                if (widget.season != AppSeason.tech)
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Tooltip(
                      message: switch (widget.season) {
                        AppSeason.valentine => 'San Valentín',
                        AppSeason.halloween => 'Halloween',
                        _ => 'Navidad',
                      },
                      child: Text(switch (widget.season) {
                        AppSeason.valentine => '💘',
                        AppSeason.halloween => '🎃',
                        _ => '🎄',
                      }),
                    ),
                  ),
                Expanded(
                  child: _tab(
                    'PARA TI',
                    selectedTab == _paraTi,
                    () => _selectTab(_paraTi),
                  ),
                ),
                Expanded(
                  child: _tab(
                    'DESCUBRIR',
                    selectedTab == _descubrir,
                    () => _selectTab(_descubrir),
                  ),
                ),
                Expanded(
                  child: _tab(
                    'FAVORITOS',
                    selectedTab == _favoritos,
                    () => _selectTab(_favoritos),
                  ),
                ),
              ],
            ),
          ),
          if (selectedTab == _descubrir && provider.remoteNotices.isNotEmpty)
            Material(
              color: colors.surface,
              child: ListTile(
                dense: true,
                leading: Icon(
                  Icons.info_outline,
                  color: colors.primary,
                  size: 20,
                ),
                title: Text(
                  '${provider.remoteVideos.isNotEmpty ? 'Mostrando las fuentes disponibles.\n' : ''}${provider.remoteNotices.join('\n')}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: IconButton(
                  tooltip: 'Reintentar fuentes',
                  onPressed: provider.remoteLoading ? null : _retry,
                  icon: const Icon(Icons.refresh),
                ),
              ),
            ),
          Expanded(
            child: IndexedStack(
              index: selectedTab,
              children: [
                if (provider.initialLoading)
                  BrandLoading(
                    season: widget.season,
                    label: 'Preparando tu feed',
                  )
                else if (provider.videos.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No hay videos disponibles con vistas mayores o iguales a los likes.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  VideoScrollableView(
                    key: const ValueKey('local-feed'),
                    videos: provider.videos,
                    season: widget.season,
                    isActive: widget.playbackEnabled && selectedTab == _paraTi,
                  ),
                if (provider.remoteLoading)
                  BrandLoading(
                    season: widget.season,
                    label: 'Preparando tu feed',
                  )
                else if (provider.remoteVideos.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.travel_explore, size: 48),
                          const SizedBox(height: 12),
                          const Text(
                            'Descubre videos de YouTube, Pixabay y NASA.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Si no aparecen videos, revisa tu conexión e inténtalo de nuevo.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _retry,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  VideoScrollableView(
                    key: ValueKey('remote-feed-$remoteFeedVersion'),
                    videos: provider.remoteVideos,
                    season: widget.season,
                    isActive:
                        widget.playbackEnabled && selectedTab == _descubrir,
                  ),
                if (provider.favorites.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite_border, size: 48),
                          SizedBox(height: 12),
                          Text(
                            'Aún no tienes favoritos.',
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Da like a un video para guardarlo aquí.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  VideoScrollableView(
                    key: const ValueKey('favorites-feed'),
                    videos: provider.favorites,
                    season: widget.season,
                    isActive:
                        widget.playbackEnabled && selectedTab == _favoritos,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, bool selected, VoidCallback onTap) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: selected ? colors.primary : Colors.white60,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: selected ? 32 : 12,
              height: 3,
              decoration: BoxDecoration(
                color: selected ? colors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
