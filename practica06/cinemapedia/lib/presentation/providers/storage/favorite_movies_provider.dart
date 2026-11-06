import 'package:cinemapedia/domain/datasources/local_storage_datasource.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'local_storage_provider.dart';

final favoriteMoviesProvider =
    StateNotifierProvider<FavoriteMoviesNotifier, AsyncValue<List<Movie>>>((
      ref,
    ) {
      return FavoriteMoviesNotifier(ref.watch(localStorageProvider));
    });

class FavoriteMoviesNotifier extends StateNotifier<AsyncValue<List<Movie>>> {
  final LocalStorageDatasource storage;
  late final Future<void> initialLoad;
  bool _loading = false;
  bool _hasMore = true;
  int _offset = 0;

  FavoriteMoviesNotifier(this.storage) : super(const AsyncLoading()) {
    initialLoad = loadNextPage();
  }

  Future<void> loadNextPage() async {
    if (_loading || !_hasMore) return;
    _loading = true;
    final previous = state.asData?.value ?? <Movie>[];
    try {
      final movies = await storage.loadFavoriteMovies(offset: _offset);
      if (!mounted) return;
      _offset += movies.length;
      _hasMore = movies.length == 10;
      state = AsyncData(
        {
          for (final movie in [...previous, ...movies]) movie.id: movie,
        }.values.toList(),
      );
    } catch (error, stack) {
      if (mounted) state = AsyncError(error, stack);
    } finally {
      _loading = false;
    }
  }

  Future<void> toggleFavoriteMovie(Movie movie) async {
    // Finish the initial read before applying edits to the loaded collection.
    await initialLoad;
    final wasFavorite = await storage.isFavoriteMovie(movie.id);
    await storage.toggleFavoriteMovie(movie);
    if (!mounted) return;
    final previous = state.asData?.value ?? <Movie>[];
    // Re-read the loaded prefix so insertions/removals cannot skip stored rows.
    final limit = _offset + 1 < 10 ? 10 : _offset + 1;
    final movies = await storage.loadFavoriteMovies(limit: limit);
    if (!mounted) return;
    _offset = movies.length;
    _hasMore = movies.length == limit;
    // Retain previously visible favorites and expose a newly added movie even
    // when it is stored beyond the first page. The storage offset tracks only
    // the fetched prefix, so subsequent pages still load without skipping rows.
    state = AsyncData(
      {
        if (!wasFavorite) movie.id: movie,
        for (final item in [...movies, ...previous])
          if (item.id != movie.id) item.id: item,
      }.values.toList(),
    );
  }
}
