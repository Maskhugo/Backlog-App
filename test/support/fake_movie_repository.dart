import 'package:backlog_app/data/movie_repository.dart';
import 'package:backlog_app/models/movie.dart';

class FakeMovieRepository implements MovieRepository {
  List<Movie> _armazenados = [];

  @override
  Future<List<Movie>> carregarTodos() async => List.of(_armazenados);

  @override
  Future<void> salvarTodos(List<Movie> movies) async {
    _armazenados = List.of(movies);
  }
}
