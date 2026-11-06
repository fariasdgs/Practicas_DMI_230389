import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

class FavoriteMovies extends Table {
  IntColumn get movieId => integer()();
  TextColumn get backdropPath => text()();
  TextColumn get originalTitle => text()();
  TextColumn get posterPath => text()();
  TextColumn get title => text()();
  RealColumn get voteAverage => real().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {movieId};
}

@DriftDatabase(tables: [FavoriteMovies])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'cinemapedia',
              web: DriftWebOptions(
                sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                driftWorker: Uri.parse('drift_worker.dart.js'),
              ),
            ),
      );

  @override
  int get schemaVersion => 1;
}

final db = AppDatabase();
