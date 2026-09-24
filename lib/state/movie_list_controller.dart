import 'package:flutter/foundation.dart';

import '../data/mock_movies.dart';
import '../data/movie_repository.dart';
import '../models/movie.dart';

class MovieListController extends ChangeNotifier {
  MovieListController(this._repository);

  final MovieRepository _repository;
  List<Movie> _movies = [];
  bool _carregado = false;

  List<Movie> get movies => List.unmodifiable(_movies);
  bool get carregado => _carregado;

  Future<void> carregar() async {
    final salvos = await _repository.carregarTodos();
    _movies = salvos.isNotEmpty ? salvos : List.of(mock_movies);
    _carregado = true;
    notifyListeners();
    if (salvos.isEmpty) await _persistir();
  }

  Future<void> _persistir() => _repository.salvarTodos(_movies);

  void addMovie({required String titulo, required String url_da_capa, int? ano}) {
    _movies.add(
      Movie(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        titulo: titulo,
        url_da_capa: url_da_capa,
        ano: ano,
      ),
    );
    notifyListeners();
    _persistir();
  }

  void removeMovie(String id) {
    _movies.removeWhere((movie) => movie.id == id);
    notifyListeners();
    _persistir();
  }

  void toggleWatched(String id) {
    _updateMovie(id, (movie) => movie.copyWith(foi_visto: !movie.foi_visto));
  }

  void toggleFavorite(String id) {
    _updateMovie(id, (movie) => movie.copyWith(favorito: !movie.favorito));
  }

  void setRating(String id, double nota) {
    _updateMovie(id, (movie) => movie.copyWith(nota: nota));
  }

  void _updateMovie(String id, Movie Function(Movie movie) update) {
    final index = _movies.indexWhere((movie) => movie.id == id);
    if (index == -1) return;
    _movies[index] = update(_movies[index]);
    notifyListeners();
    _persistir();
  }
}
