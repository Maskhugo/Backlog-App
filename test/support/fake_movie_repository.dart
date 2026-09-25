import 'package:backlog_app/data/movie_repository.dart';
import 'package:backlog_app/models/movie.dart';

/// Um repositório "de mentira" usado SÓ nos testes.
///
/// Ele cumpre o mesmo contrato do `HiveMovieRepository` (tem
/// carregarTodos e salvarTodos), mas em vez de gravar no celular, guarda
/// a lista numa variável na memória.
///
/// Por que não usar o Hive nos testes? Porque o Hive precisa de uma
/// pasta de verdade no dispositivo, e os testes rodam no computador,
/// sem celular. Assim os testes ficam rápidos e sempre começam do zero.
class FakeMovieRepository implements MovieRepository {
  // Começa vazio, igual a um app recém-instalado.
  List<Movie> _armazenados = [];

  // Devolve uma CÓPIA da lista (`List.of`), para que quem recebe não
  // consiga alterar o que está "salvo" sem chamar salvarTodos.
  @override
  Future<List<Movie>> carregarTodos() async => List.of(_armazenados);

  @override
  Future<void> salvarTodos(List<Movie> movies) async {
    _armazenados = List.of(movies);
  }
}
