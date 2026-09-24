import 'package:flutter/foundation.dart';

import '../data/mock_movies.dart';
import '../models/movie.dart';

class MovieListController extends ChangeNotifier {
  final List<Movie> _movies = List.of(mock_movies);

  List<Movie> get movies => List.unmodifiable(_movies);

  void addMovie({required String titulo, required String url_da_capa}) {
    _movies.add(
      Movie(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        titulo: titulo,
        url_da_capa: url_da_capa,
      ),
    );
    notifyListeners();
  }

  void removeMovie(String id) {
    _movies.removeWhere((movie) => movie.id == id);
    notifyListeners();
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
  }
}
