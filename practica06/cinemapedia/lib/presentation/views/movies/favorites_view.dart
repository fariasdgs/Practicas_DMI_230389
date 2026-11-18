import 'package:cinemapedia/presentation/providers/storage/favorite_movies_provider.dart';
import 'package:cinemapedia/presentation/widgets/movies/movies_mansory.dart';
import 'package:flutter/material.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_country_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesView extends ConsumerWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(movieCountryProvider);
    final favorites = ref.watch(favoriteMoviesProvider);
    return SafeArea(
      child: favorites.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (_, _) => Center(
          child: TextButton(
            onPressed: () =>
                ref.read(favoriteMoviesProvider.notifier).loadNextPage(),
            child: Text(country.text('retryFavorites')),
          ),
        ),
        data: (movies) => movies.isEmpty
            ? Center(child: Text(country.text('emptyFavorites')))
            : MovieMasonry(
                movies: movies,
                loadNextPage: () async {
                  final previousCount =
                      ref.read(favoriteMoviesProvider).asData?.value.length ??
                      0;
                  await ref
                      .read(favoriteMoviesProvider.notifier)
                      .loadNextPage();
                  return (ref.read(favoriteMoviesProvider).asData?.value ?? [])
                      .skip(previousCount)
                      .toList();
                },
              ),
      ),
    );
  }
}
