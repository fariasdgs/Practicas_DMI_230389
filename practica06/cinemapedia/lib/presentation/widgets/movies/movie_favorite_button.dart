import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/storage/favorite_movies_provider.dart';
import 'package:cinemapedia/presentation/providers/storage/is_favorite_movie_provider.dart';
import 'package:flutter/material.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_country_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MovieFavoriteButton extends ConsumerStatefulWidget {
  final Movie movie;
  const MovieFavoriteButton({super.key, required this.movie});

  @override
  ConsumerState<MovieFavoriteButton> createState() =>
      _MovieFavoriteButtonState();
}

class _MovieFavoriteButtonState extends ConsumerState<MovieFavoriteButton> {
  bool _saving = false;

  Future<void> _toggleFavorite() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(favoriteMoviesProvider.notifier)
          .toggleFavoriteMovie(widget.movie);
      if (!mounted) return;
      final isFavorite = await ref.refresh(
        isFavoriteMovieProvider(widget.movie.id).future,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              isFavorite
                  ? ref.read(movieCountryProvider).text('favoriteAdded')
                  : ref.read(movieCountryProvider).text('favoriteRemoved'),
            ),
          ),
        );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(movieCountryProvider).text('favoriteError')),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final country = ref.watch(movieCountryProvider);
    final favorite = ref.watch(isFavoriteMovieProvider(widget.movie.id));
    final selected = favorite.asData?.value ?? false;
    final busy = _saving || favorite.isLoading;
    return TextButton.icon(
      style: TextButton.styleFrom(foregroundColor: Colors.white),
      onPressed: busy
          ? null
          : favorite.hasError
          ? () => ref.invalidate(isFavoriteMovieProvider(widget.movie.id))
          : _toggleFavorite,
      icon: busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              selected ? Icons.favorite : Icons.favorite_border_outlined,
              color: selected ? Colors.red : Colors.white,
            ),
      label: Text(
        _saving
            ? country.text('saving')
            : favorite.hasError
            ? country.text('retryFavorites')
            : selected
            ? country.text('removeFavorite')
            : country.text('addFavorite'),
      ),
    );
  }
}
