import '../models/movie.dart';

abstract class MovieRepository {
  Future<List<Movie>> carregarTodos();
  Future<void> salvarTodos(List<Movie> movies);
}
