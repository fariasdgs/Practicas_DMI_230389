import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:flutter/material.dart';
import 'package:cinemapedia/config/constants/movie_country.dart';

class SearchMovieDelegate extends SearchDelegate<Movie?> {
  final MovieCountry country;
  final List<Movie> initialMovies;
  final Future<List<Movie>> Function(String) searchMovies;
  String? _lastQuery;
  Future<List<Movie>>? _results;

  SearchMovieDelegate({
    this.country = MovieCountry.mexico,
    required this.initialMovies,
    required this.searchMovies,
  }) : super(searchFieldLabel: country.text('search'));

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear)),
  ];
  @override
  Widget buildLeading(BuildContext context) => IconButton(
    onPressed: () => close(context, null),
    icon: const Icon(Icons.arrow_back),
  );
  @override
  Widget buildResults(BuildContext context) => _buildMovies(context);
  @override
  Widget buildSuggestions(BuildContext context) => _buildMovies(context);

  Widget _buildMovies(BuildContext context) {
    if (_lastQuery != query) {
      _lastQuery = query;
      final currentQuery = query;
      _results = currentQuery.trim().isEmpty
          ? Future.value(initialMovies)
          : Future<List<Movie>>(() => searchMovies(currentQuery));
    }
    return FutureBuilder<List<Movie>>(
      future: _results,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (snapshot.hasError) {
          return Center(child: Text(country.text('searchError')));
        }
        final movies = snapshot.data ?? [];
        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return ListTile(
              leading: Image.network(
                movie.posterPath,
                width: 45,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(Icons.movie_outlined),
              ),
              title: Text(movie.title),
              subtitle: Text(
                movie.overview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => close(context, movie),
            );
          },
        );
      },
    );
  }
}
