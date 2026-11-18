import 'package:cinemapedia/domain/entities/movie.dart';

abstract class LocalStorageDatasource {
  Future<bool> isFavoriteMovie(int movieId);
  Future<List<Movie>> loadFavoriteMovies({int limit = 10, int offset = 0});
  Future<void> toggleFavoriteMovie(Movie movie);
}
