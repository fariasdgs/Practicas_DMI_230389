import 'package:cinemapedia/domain/datasources/local_storage_datasource.dart';
import 'package:cinemapedia/infraestructure/datasources/drift_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localStorageProvider = Provider<LocalStorageDatasource>(
  (ref) => DriftDatasource(),
);
