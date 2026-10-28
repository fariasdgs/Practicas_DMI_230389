import 'package:flutter/material.dart';
import 'package:cinemapedia/domain/entities/movie.dart';

class MoviesSlideshow extends StatefulWidget {
  final List<Movie> movies;

  const MoviesSlideshow({super.key, required this.movies});

  @override
  State<MoviesSlideshow> createState() => _MoviesSlideshowState();
}

class _MoviesSlideshowState extends State<MoviesSlideshow> {
  final controller = PageController(viewportFraction: 0.9);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movies = widget.movies;
    if (movies.isEmpty) return const SizedBox.shrink();

    const duration = Duration(milliseconds: 300);

    return SizedBox(
      height: 240,
      child: Stack(
        children: [
          PageView.builder(
            controller: controller,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    movie.backdropPath,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton.filledTonal(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => controller.previousPage(
                  duration: duration,
                  curve: Curves.easeInOut,
                ),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton.filledTonal(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => controller.nextPage(
                  duration: duration,
                  curve: Curves.easeInOut,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
