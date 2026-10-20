import 'package:flutter_riverpod/flutter_riverpod.dart';

class Movie {
  final String title;

  const Movie({required this.title});
}

final nowPlayingMoviesProvider =
    NotifierProvider<MoviesNotifier, List<Movie>>(MoviesNotifier.new);

class MoviesNotifier extends Notifier<List<Movie>> {
  @override
  List<Movie> build() => [];

  Future<void> loadNextPage() async {
    // TODO: Connect the movie datasource when it is available.
  }
}
