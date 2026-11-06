import 'package:cinemapedia/domain/entities/movie.dart';

import 'movie_metadata.dart';

import 'package:cinemapedia/presentation/providers/movies/movie_country_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MovieRating extends ConsumerWidget {
  final Movie movie;
  const MovieRating({super.key, required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(movieCountryProvider);
    final stars = (movie.voteAverage / 2).clamp(0.0, 5.0);
    final rounded = (stars * 2).round() / 2;
    final format = NumberFormat('0.0', country.language.replaceAll('-', '_'));
    final hasVotes = movie.voteCount > 0;
    final label = hasVotes
        ? '${format.format(stars)}/5'
        : country.text('noVotes');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              country.text('starsRating'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Semantics(
              label: '${country.text('starsRating')}: $label',
              child: ExcludeSemantics(
                child: Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (index) => Icon(
                          !hasVotes || rounded <= index
                              ? Icons.star_outline_rounded
                              : rounded >= index + 1
                              ? Icons.star_rounded
                              : Icons.star_half_rounded,
                          color: Colors.amber.shade700,
                          size: 28,
                        ),
                      ),
                    ),
                    Text(label, style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasVotes
                  ? '${country.text('score')} · ${format.format(movie.voteAverage)}/10 · ${NumberFormat.decimalPattern(country.language.replaceAll('-', '_')).format(movie.voteCount)} ${country.text('votes')}'
                  : country.text('noVotes'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            MovieMetadata(movie: movie, showStars: false),
          ],
        ),
      ),
    );
  }
}
