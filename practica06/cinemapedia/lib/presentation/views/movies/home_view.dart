import 'package:cinemapedia/presentation/providers/movies/movie_country_provider.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_providers.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_slideshow_provider.dart';
import 'package:cinemapedia/presentation/widgets/movies/movie_horizontal_listview.dart';
import 'package:cinemapedia/presentation/widgets/movies/movies_slideshow.dart';
import 'package:cinemapedia/presentation/widgets/shared/custom_appbar.dart';
import 'package:cinemapedia/presentation/widgets/shared/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeView extends ConsumerStatefulWidget {
  final bool isActive;
  const HomeView({super.key, this.isActive = true});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final country = ref.watch(movieCountryProvider);
    ref.listen(movieCountryProvider, (_, _) {
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    });
    final providers = [
      countryMoviesProvider,
      nowPlayingMoviesProvider,
      upcomingMoviesProvider,
      popularMoviesProvider,
      topRatedMoviesProvider,
    ];
    final lists = providers.map((provider) => ref.watch(provider)).toList();
    const titles = [
      'countryMovies',
      'nowPlaying',
      'upcoming',
      'popular',
      'topRated',
    ];
    return CustomScrollView(
      key: const PageStorageKey('home-scroll'),
      controller: _scrollController,
      slivers: [
        const SliverAppBar(
          pinned: true,
          titleSpacing: 0,
          title: CustomAppbar(),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${country.flag} ${country.name} · ${country.text('countryMovies')}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              if (lists.first.isLoading && lists.first.movies.isEmpty)
                const SizedBox(height: 210, child: FullScreenLoader()),
              MoviesSlideshow(
                key: ValueKey(country),
                movies: ref.watch(moviesSlideshowProvider),
                isActive: widget.isActive,
              ),
              for (var index = 0; index < lists.length; index++) ...[
                if (lists[index].error != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text(country.text('error')),
                        TextButton(
                          onPressed: () => ref
                              .read(providers[index].notifier)
                              .loadNextPage(),
                          child: Text(country.text('retry')),
                        ),
                      ],
                    ),
                  ),
                if (lists[index].movies.isEmpty &&
                    !lists[index].isLoading &&
                    lists[index].error == null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(country.text('empty')),
                  ),
                MovieHorizontalListview(
                  key: ValueKey('${country.code}-$index'),
                  movies: lists[index].movies,
                  title: country.text(titles[index]),
                  loadNextPage: () =>
                      ref.read(providers[index].notifier).loadNextPage(),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}
