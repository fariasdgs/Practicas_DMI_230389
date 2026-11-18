import 'package:animate_do/animate_do.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_country_provider.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemapedia/domain/entities/movie.dart';

class MoviesSlideshow extends ConsumerStatefulWidget {
  final List<Movie> movies;
  final bool isActive;

  const MoviesSlideshow({
    super.key,
    required this.movies,
    this.isActive = true,
  });

  @override
  ConsumerState<MoviesSlideshow> createState() => _MoviesSlideshowState();
}

class _MoviesSlideshowState extends ConsumerState<MoviesSlideshow> {
  final _controller = SwiperController();
  int _currentIndex = 0;

  Future<void> _goTo(int index) async {
    if (widget.movies.isEmpty) return;
    final target = index.clamp(0, widget.movies.length - 1);
    if (target == _currentIndex) return;
    _controller.stopAutoplay();
    await _controller.move(target);
    if (mounted) _updateAutoplay();
  }

  void _updateAutoplay() {
    if (!mounted) return;
    if (widget.isActive && widget.movies.length > 1) {
      _controller.startAutoplay();
    } else {
      _controller.stopAutoplay();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateAutoplay());
  }

  @override
  void didUpdateWidget(covariant MoviesSlideshow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive ||
        oldWidget.movies.length != widget.movies.length) {
      _controller.stopAutoplay();
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateAutoplay());
    }
  }

  @override
  void dispose() {
    _controller.stopAutoplay();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final country = ref.watch(movieCountryProvider);
    final colors = Theme.of(context).colorScheme;
    final movies = widget.movies;
    if (movies.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 210,
      width: double.infinity,
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification &&
                  notification.dragDetails != null) {
                _controller.stopAutoplay();
              } else if (notification is ScrollEndNotification) {
                _updateAutoplay();
              }
              return false;
            },
            child: Swiper(
              controller: _controller,
              onIndexChanged: (index) => _currentIndex = index,
              viewportFraction: 0.8,
              scale: 0.9,
              // Keep Swiper's subtree stable; pause its timer through the controller.
              autoplay: false,
              pagination: SwiperPagination(
                margin: const EdgeInsets.only(top: 0),
                builder: DotSwiperPaginationBuilder(
                  activeColor: colors.primary,
                  color: colors.secondary,
                ),
              ),
              onTap: (index) =>
                  context.push('/home/0/movie/${movies[index].id}'),
              itemCount: movies.length,
              itemBuilder: (context, index) => _Slide(movie: movies[index]),
            ),
          ),
          Positioned(
            left: 4,
            top: 66,
            child: GestureDetector(
              onDoubleTap: () => _goTo(0),
              child: IconButton.filledTonal(
                key: const ValueKey('carousel-previous'),
                tooltip:
                    '${country.text('previous')} · 2× ${country.text('start')}',
                onPressed: () => _goTo(_currentIndex - 1),
                icon: const Icon(Icons.chevron_left),
              ),
            ),
          ),
          Positioned(
            right: 4,
            top: 66,
            child: GestureDetector(
              onDoubleTap: () => _goTo(movies.length - 1),
              child: IconButton.filledTonal(
                key: const ValueKey('carousel-next'),
                tooltip: '${country.text('next')} · 2× ${country.text('end')}',
                onPressed: () => _goTo(_currentIndex + 1),
                icon: const Icon(Icons.chevron_right),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final Movie movie;

  const _Slide({required this.movie});

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 10)),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: DecoratedBox(
        decoration: decoration,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                movie.backdropPath,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const Center(child: Icon(Icons.movie_outlined)),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress != null) {
                    return const DecoratedBox(
                      decoration: BoxDecoration(color: Colors.black12),
                    );
                  }
                  return FadeIn(child: child);
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 28, 12, 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                  child: Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
