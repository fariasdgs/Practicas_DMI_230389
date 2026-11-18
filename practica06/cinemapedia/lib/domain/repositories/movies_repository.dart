import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/domain/entities/movie_trailer.dart';

abstract class MoviesRepository {
  Future<List<Movie>> getMoviesByCountry({int page = 1});

  Future<List<Movie>> getNowPlaying({int page = 1});
  Future<List<Movie>> getPopular({int page = 1});
  Future<List<Movie>> getUpcoming({int page = 1});
  Future<List<Movie>> getTopRated({int page = 1});
  Future<MovieTrailer?> getTrailer(String movieId);

  Future<String?> getCertification(String movieId);

  Future<Movie> getMovieById(String id);
  Future<List<Movie>> searchMovies(String query);
}
