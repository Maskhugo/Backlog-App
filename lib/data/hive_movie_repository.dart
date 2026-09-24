import 'package:hive_ce_flutter/hive_flutter.dart';

import '../models/movie.dart';
import 'movie_repository.dart';

class HiveMovieRepository implements MovieRepository {
  static const _boxName = 'movies';

  Future<Box> _abrirBox() => Hive.openBox(_boxName);

  @override
  Future<List<Movie>> carregarTodos() async {
    final box = await _abrirBox();
    return box.values
        .map((valor) => Movie.fromMap(Map<String, dynamic>.from(valor as Map)))
        .toList();
  }

  @override
  Future<void> salvarTodos(List<Movie> movies) async {
    final box = await _abrirBox();
    await box.clear();
    await box.addAll(movies.map((movie) => movie.toMap()));
  }
}
