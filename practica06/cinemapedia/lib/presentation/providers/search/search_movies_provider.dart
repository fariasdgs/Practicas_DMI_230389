import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';
import 'package:flutter_riverpod/legacy.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final searchedMoviesProvider =
    StateNotifierProvider<SearchedMoviesNotifier, List<Movie>>((ref) {
      return SearchedMoviesNotifier(
        search: ref.watch(movieRepositoryProvider).searchMovies,
        onQuery: (query) =>
            ref.read(searchQueryProvider.notifier).state = query,
      );
    });

class SearchedMoviesNotifier extends StateNotifier<List<Movie>> {
  final Future<List<Movie>> Function(String) search;
  final void Function(String) onQuery;
  int _request = 0;
  SearchedMoviesNotifier({required this.search, required this.onQuery})
    : super([]);

  Future<List<Movie>> searchMoviesByQuery(String query) async {
    final request = ++_request;
    onQuery(query);
    final movies = await search(query.trim());
    if (mounted && request == _request) state = movies;
    return movies;
  }
}
