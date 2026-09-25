import '../models/movie.dart';

/// Um "contrato" que diz O QUE um repositório de filmes precisa saber
/// fazer, mas não COMO fazer.
///
/// `abstract class` = uma classe que não pode ser usada sozinha; ela só
/// define os métodos que outras classes são obrigadas a implementar.
///
/// Por que isso é útil? Porque o `MovieListController` só conhece este
/// contrato. Assim podemos trocar a implementação sem mexer no controller:
/// - no app de verdade, usamos `HiveMovieRepository` (salva no celular);
/// - nos testes, usamos `FakeMovieRepository` (guarda só na memória).
abstract class MovieRepository {
  /// Lê todos os filmes salvos.
  ///
  /// `Future` significa "uma resposta que vai chegar no futuro": ler do
  /// disco demora um pouquinho, então o app não fica travado esperando.
  Future<List<Movie>> carregarTodos();

  /// Salva a lista inteira de filmes (substituindo o que tinha antes).
  Future<void> salvarTodos(List<Movie> movies);
}
