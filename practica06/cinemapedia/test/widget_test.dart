import 'package:card_swiper/card_swiper.dart';
import 'package:cinemapedia/main.dart';
import 'package:cinemapedia/domain/entities/movie_trailer.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_info_provider.dart';
import 'package:cinemapedia/presentation/widgets/movies/movie_rating.dart';
import 'package:cinemapedia/presentation/widgets/movies/movie_trailer.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_country_provider.dart';
import 'package:cinemapedia/presentation/widgets/movies/country_selector.dart';
import 'package:cinemapedia/config/constants/movie_country.dart';
import 'package:cinemapedia/config/router/app_router.dart';
import 'package:cinemapedia/domain/datasources/local_storage_datasource.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/actors/actors_repository_provider.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';
import 'package:cinemapedia/presentation/providers/storage/local_storage_provider.dart';
import 'package:cinemapedia/presentation/screens/movies/home_screen.dart';
import 'package:cinemapedia/presentation/views/movies/home_view.dart';
import 'package:cinemapedia/presentation/widgets/movies/movies_slideshow.dart';
import 'package:cinemapedia/presentation/widgets/movies/movie_horizontal_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_support.dart';

class MemoryStorage extends LocalStorageDatasource {
  final Map<int, Movie> favorites = {};
  @override
  Future<bool> isFavoriteMovie(int movieId) async =>
      favorites.containsKey(movieId);
  @override
  Future<List<Movie>> loadFavoriteMovies({
    int limit = 10,
    int offset = 0,
  }) async => favorites.values.skip(offset).take(limit).toList();
  @override
  Future<void> toggleFavoriteMovie(Movie movie) async {
    if (favorites.containsKey(movie.id)) {
      favorites.remove(movie.id);
    } else {
      favorites[movie.id] = movie;
    }
  }
}

class CountingRepository extends FakeMoviesRepository {
  int nowPlayingRequests = 0;
  CountingRepository() : super(MovieCountry.mexico);
  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) {
    nowPlayingRequests++;
    return super.getNowPlaying(page: page);
  }
}

Widget app(
  GoRouter router, {
  FakeMoviesRepository? repository,
  MemoryStorage? storage,
}) => ProviderScope(
  overrides: [
    movieRepositoryProvider.overrideWithValue(
      repository ?? FakeMoviesRepository(MovieCountry.mexico),
    ),
    actorsRepositoryProvider.overrideWithValue(FakeActorsRepository()),
    localStorageProvider.overrideWithValue(storage ?? MemoryStorage()),
  ],
  child: MaterialApp.router(routerConfig: router),
);

GoRouter routerForTest({String location = '/home/0'}) =>
    GoRouter(initialLocation: location, routes: appRouter.configuration.routes);

Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump();
}

void main() {
  testWidgets('Rating and trailer appear beneath the actors on movie details', (
    tester,
  ) async {
    final router = routerForTest();
    addTearDown(router.dispose);
    await tester.pumpWidget(app(router));
    await tester.pumpAndSettle();
    router.push('/home/0/movie/1');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('movie-trailer')));
    await tester.pumpAndSettle();
    expect(find.text('Calificación'), findsOneWidget);
    expect(find.text('4.0/5'), findsOneWidget);
    expect(find.text('Reproducir tráiler'), findsOneWidget);
    expect(find.text('Idioma del tráiler: ES'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byType(MovieRating)).dy,
      greaterThan(tester.getTopLeft(find.text('Reparto')).dy),
    );
    expect(
      tester.getTopLeft(find.byType(MovieTrailerSection)).dy,
      greaterThan(tester.getTopLeft(find.byType(MovieRating)).dy),
    );
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets(
    'Missing trailers show a clear message rather than a broken player',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            movieTrailerProvider('1').overrideWith((ref) async => null),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: MovieTrailerSection(movieId: '1'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('No hay tráiler disponible para esta película.'),
        findsOneWidget,
      );
      expect(find.text('Reproducir tráiler'), findsNothing);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );

  testWidgets('Trailers reload for the selected country', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          movieTrailerProvider('1').overrideWith((ref) async {
            final country = ref.watch(movieCountryProvider);
            return MovieTrailer(
              videoId: 'abcdefghijk',
              title: country.code,
              language: country.languageCode,
            );
          }),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  CountrySelector(),
                  MovieTrailerSection(movieId: '1'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Idioma del tráiler: ES'), findsOneWidget);
    await tester.tap(find.byType(CountrySelector));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deutschland'));
    await tester.pumpAndSettle();
    expect(find.text('Sprache des Trailers: DE'), findsOneWidget);
    expect(find.text('Trailer abspielen'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets(
    'Carousel arrows step once and double taps jump to first or last',
    (tester) async {
      final router = routerForTest();
      addTearDown(router.dispose);
      await tester.pumpWidget(app(router));
      await tester.pumpAndSettle();
      final carousel = find.descendant(
        of: find.byType(MoviesSlideshow),
        matching: find.byType(PageView),
      );
      final controller = tester.widget<PageView>(carousel).controller!;
      final previous = find.byKey(const ValueKey('carousel-previous'));
      final next = find.byKey(const ValueKey('carousel-next'));
      expect(controller.page, closeTo(0, 0.01));
      await tester.tap(next);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(controller.page, closeTo(1, 0.01));
      await tester.tap(previous);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(controller.page, closeTo(0, 0.01));
      await tester.tap(next);
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(controller.page, closeTo(2, 0.01));
      await tester.tap(previous);
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tap(previous);
      await tester.pumpAndSettle();
      expect(controller.page, closeTo(0, 0.01));
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );

  testWidgets('Own logo and left hamburger menu keep tab navigation working', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final router = routerForTest();
    addTearDown(router.dispose);
    await tester.pumpWidget(app(router));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Logo Cinemapedia'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsOneWidget);
    expect(find.text('CINEMAPEDIA'), findsOneWidget);
    await tester.tap(find.widgetWithText(ListTile, 'Favoritos'));
    await tester.pumpAndSettle();
    expect(find.text('No tienes películas favoritas'), findsOneWidget);
    await tester.tap(find.text('Inicio'));
    await tester.pumpAndSettle();
    expect(find.byType(MoviesSlideshow), findsOneWidget);
    expect(find.byType(CountrySelector), findsOneWidget);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets(
    'Flags change language and country recommendations without losing favorites',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 740));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final storage = MemoryStorage();
      storage.favorites[99] = sampleMovie(99);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            movieRepositoryProvider.overrideWith(
              (ref) => FakeMoviesRepository(ref.watch(movieCountryProvider)),
            ),
            actorsRepositoryProvider.overrideWithValue(FakeActorsRepository()),
            localStorageProvider.overrideWithValue(storage),
          ],
          child: const MainApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Películas del país'), findsOneWidget);
      for (final country in MovieCountry.values) {
        await tester.tap(find.byType(CountrySelector));
        await tester.pumpAndSettle();
        final choice = find.widgetWithText(
          PopupMenuItem<MovieCountry>,
          country.name,
        );
        await tester.ensureVisible(choice);
        await tester.tap(choice);
        await tester.pumpAndSettle();
        expect(
          Localizations.localeOf(tester.element(find.byType(HomeScreen))),
          Locale(country.languageCode, country.code),
        );
        expect(find.text(country.text('countryMovies')), findsOneWidget);
        final featuredTitle = find.descendant(
          of: find.byType(MoviesSlideshow),
          matching: find.text('${country.code} película 1'),
        );
        expect(featuredTitle, findsWidgets);
        expect(find.text(country.text('home')), findsOneWidget);
        expect(tester.takeException(), isNull, reason: country.code);
      }
      await tester.tap(find.text('Favorites'));
      await tester.pumpAndSettle();
      expect(storage.favorites.containsKey(99), isTrue);
      expect(find.text('You have no favorite movies'), findsNothing);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(
        find.text('🇦🇺 Australia · Movies from this country'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );

  testWidgets(
    'Inicio keeps carousel, vertical scroll and lists after visiting Favoritos',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final router = routerForTest();
      addTearDown(router.dispose);
      final repository = CountingRepository();
      await tester.pumpWidget(app(router, repository: repository));
      await tester.pumpAndSettle();
      expect(find.text('Inicio'), findsOneWidget);
      expect(find.text('Categorías'), findsOneWidget);
      expect(find.text('Favoritos'), findsOneWidget);

      final homeState = tester.state(find.byType(HomeView));
      final carousel = find.descendant(
        of: find.byType(MoviesSlideshow),
        matching: find.byType(PageView),
      );
      final carouselState = tester.state(carousel);
      final initialPage = tester.widget<PageView>(carousel).controller!.page!;
      await tester.drag(carousel, const Offset(-310, 0));
      await tester.pumpAndSettle();
      final pageController = tester.widget<PageView>(carousel).controller!;
      var page = pageController.page!;
      expect(page, greaterThan(initialPage));

      final mainScroll = find.byType(CustomScrollView);
      final vertical = tester.widget<CustomScrollView>(mainScroll).controller!;
      await tester.drag(mainScroll, const Offset(0, -280));
      await tester.pumpAndSettle();
      final offset = vertical.offset;
      expect(offset, greaterThan(0));
      final horizontalList = find.descendant(
        of: find.byType(MovieHorizontalListview).first,
        matching: find.byType(ListView),
      );
      await tester.drag(horizontalList, const Offset(-200, 0));
      await tester.pumpAndSettle();
      final horizontal = tester.widget<ListView>(horizontalList).controller!;
      final horizontalOffset = horizontal.offset;
      expect(horizontalOffset, greaterThan(0));
      final requests = repository.nowPlayingRequests;
      page = pageController.page!;

      await tester.tap(find.text('Favoritos'));
      await tester.pumpAndSettle();
      expect(find.text('No tienes películas favoritas'), findsOneWidget);
      expect(
        tester
            .widget<Swiper>(find.byType(Swiper, skipOffstage: false))
            .autoplay,
        isFalse,
      );
      // Stay away longer than the autoplay interval: a hidden carousel must not advance.
      await tester.pump(const Duration(seconds: 8));
      expect(pageController.page, closeTo(page, 0.01));
      await tester.tap(find.text('Inicio'));
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(HomeView)), same(homeState));
      expect(tester.state(carousel), same(carouselState));
      expect(pageController.page, closeTo(page, 0.01));
      expect(vertical.offset, closeTo(offset, 0.1));
      expect(horizontal.offset, closeTo(horizontalOffset, 0.1));
      expect(repository.nowPlayingRequests, requests);
      // Automatic playback resumes only after returning to Inicio.
      await tester.pump(const Duration(milliseconds: 3100));
      await tester.pump(const Duration(milliseconds: 400));
      expect(pageController.page, isNot(closeTo(page, 0.01)));
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );

  testWidgets('Adding and removing a favorite works through the movie screen', (
    tester,
  ) async {
    final router = routerForTest();
    addTearDown(router.dispose);
    final storage = MemoryStorage();
    await tester.pumpWidget(app(router, storage: storage));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MoviesSlideshow));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agregar a favoritos'));
    await tester.pumpAndSettle();
    expect(storage.favorites.containsKey(1), isTrue);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.text('Quitar de favoritos'), findsOneWidget);
    expect(find.text('Película agregada a Favoritos'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();
    expect(find.text('No tienes películas favoritas'), findsNothing);
    // Opening a favorite keeps its tab underneath the details route.
    await tester.tap(find.byType(Image).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quitar de favoritos'));
    await tester.pumpAndSettle();
    expect(storage.favorites, isEmpty);
    router.pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();
    expect(find.text('No tienes películas favoritas'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('Empty and failed catalogues keep tab navigation usable', (
    tester,
  ) async {
    for (final fail in [false, true]) {
      final router = routerForTest();
      await tester.pumpWidget(
        app(
          router,
          repository: FakeMoviesRepository(
            MovieCountry.mexico,
            fail: fail,
            empty: !fail,
          ),
        ),
      );
      await tester.pumpAndSettle();
      if (fail) {
        expect(find.text('Reintentar'), findsWidgets);
      } else {
        expect(
          find.text('No hay películas disponibles en esta región.'),
          findsWidgets,
        );
      }
      await tester.tap(find.text('Favoritos'));
      await tester.pumpAndSettle();
      expect(find.text('No tienes películas favoritas'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await unmount(tester);
      router.dispose();
    }
  });

  testWidgets(
    'Search opens a selected movie without build-time provider changes',
    (tester) async {
      final router = routerForTest();
      addTearDown(router.dispose);
      await tester.pumpWidget(app(router));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'película');
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'MX película 1'), findsOneWidget);
      await tester.tap(find.widgetWithText(ListTile, 'MX película 1'));
      await tester.pumpAndSettle();
      expect(find.text('Agregar a favoritos'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );

  testWidgets('Invalid tab parameters do not crash navigation', (tester) async {
    for (final location in ['/home/invalid', '/home/99', '/home/-2']) {
      final router = routerForTest(location: location);
      await tester.pumpWidget(app(router));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await unmount(tester);
      router.dispose();
    }
  });
}
