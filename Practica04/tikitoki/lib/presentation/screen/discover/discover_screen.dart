import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tikitoki/config/theme/app_theme.dart';
import 'package:tikitoki/presentation/providers/discover_provider.dart';
import 'package:tikitoki/presentation/widgets/shared/video_scrollable_view.dart';

class DiscoverScreen extends StatefulWidget {
  final AppSeason season;

  const DiscoverScreen({super.key, this.season = AppSeason.tech});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  bool discovering = false;
  int remoteFeedVersion = 0;

  void _selectTab(bool discover) {
    if (discovering == discover) return;
    setState(() => discovering = discover);
    if (discover) context.read<DiscoverProvider>().loadRemoteVideos();
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
                      message: widget.season == AppSeason.halloween
                          ? 'Halloween'
                          : 'Navidad',
                      child: Text(
                        widget.season == AppSeason.halloween ? '🎃' : '🎄',
                      ),
                    ),
                  ),
                Expanded(
                  child: _tab('PARA TI', !discovering, () => _selectTab(false)),
                ),
                Expanded(
                  child: _tab('DESCUBRIR', discovering, () => _selectTab(true)),
                ),
              ],
            ),
          ),
          if (discovering && provider.remoteNotices.isNotEmpty)
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
              index: discovering ? 1 : 0,
              children: [
                if (provider.initialLoading)
                  const Center(child: CircularProgressIndicator(strokeWidth: 2))
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
                    isActive: !discovering,
                  ),
                if (provider.remoteLoading)
                  const Center(child: CircularProgressIndicator(strokeWidth: 2))
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
                            'Descubre videos de Pixabay, NASA e Internet Archive.',
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
                    isActive: discovering,
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
            Container(
              width: 24,
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
