import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'favorite_movies_provider.dart';
import 'local_storage_provider.dart';

final isFavoriteMovieProvider = FutureProvider.autoDispose.family<bool, int>((
  ref,
  movieId,
) {
  ref.watch(favoriteMoviesProvider);
  return ref.watch(localStorageProvider).isFavoriteMovie(movieId);
});
