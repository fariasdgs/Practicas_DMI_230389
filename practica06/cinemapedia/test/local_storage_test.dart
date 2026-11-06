import 'dart:io';

import 'package:cinemapedia/config/database/database.dart';
import 'package:cinemapedia/infraestructure/datasources/drift_datasource.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/presentation/providers/storage/local_storage_provider.dart';
import 'package:cinemapedia/presentation/providers/storage/favorite_movies_provider.dart';
import 'package:cinemapedia/presentation/providers/storage/is_favorite_movie_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';

void main() {
  test(
    'Newly saved favorites appear immediately beyond the first stored page',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final storage = DriftDatasource(database);
      for (var id = 1; id <= 12; id++) {
        await storage.toggleFavoriteMovie(sampleMovie(id));
      }
      final container = ProviderContainer(
        overrides: [localStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);
      final notifier = container.read(favoriteMoviesProvider.notifier);
      await notifier.initialLoad;
      expect(
        container.read(favoriteMoviesProvider).requireValue,
        hasLength(10),
      );

      await notifier.toggleFavoriteMovie(sampleMovie(2000));
      expect(
        container.read(favoriteMoviesProvider).requireValue.first.id,
        2000,
      );
      expect(
        await container.read(isFavoriteMovieProvider(2000).future),
        isTrue,
      );
      await notifier.toggleFavoriteMovie(sampleMovie(3000));
      expect(
        container
            .read(favoriteMoviesProvider)
            .requireValue
            .map((movie) => movie.id),
        containsAll([2000, 3000]),
      );
      await notifier.loadNextPage();
      expect(
        container
            .read(favoriteMoviesProvider)
            .requireValue
            .map((movie) => movie.id)
            .toSet(),
        {...List.generate(12, (index) => index + 1), 2000, 3000},
      );
      await notifier.toggleFavoriteMovie(sampleMovie(2000));
      expect(
        container
            .read(favoriteMoviesProvider)
            .requireValue
            .any((movie) => movie.id == 2000),
        isFalse,
      );
      expect(await storage.isFavoriteMovie(2000), isFalse);
    },
  );

  test(
    'Favorite movies survive reopening the database and can be removed',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'cinemapedia-storage-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/favorites.sqlite');
      var database = AppDatabase(NativeDatabase(file));
      var source = DriftDatasource(database);
      final movie = sampleMovie(12);
      expect(await source.isFavoriteMovie(movie.id), isFalse);
      await source.toggleFavoriteMovie(movie);
      expect(await source.isFavoriteMovie(movie.id), isTrue);
      await database.close();

      database = AppDatabase(NativeDatabase(file));
      addTearDown(database.close);
      source = DriftDatasource(database);
      final stored = await source.loadFavoriteMovies();
      expect(stored.single.id, movie.id);
      expect(stored.single.title, movie.title);
      expect(stored.single.voteAverage, movie.voteAverage);
      await source.toggleFavoriteMovie(movie);
      expect(await source.loadFavoriteMovies(), isEmpty);
    },
  );
}
