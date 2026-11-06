import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/domain/entities/movie.dart';

import 'movies_providers.dart';

final moviesSlideshowProvider = Provider<List<Movie>>((ref) {
  final countryMovies = ref.watch(countryMoviesProvider).movies;

  if (countryMovies.isEmpty) return [];

  return countryMovies.take(6).toList();
});
