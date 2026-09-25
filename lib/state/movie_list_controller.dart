// `foundation.dart` traz o `ChangeNotifier`, a base do nosso controller.
import 'package:flutter/foundation.dart';

import '../data/mock_movies.dart';
import '../data/movie_repository.dart';
import '../models/movie.dart';

/// O "cérebro" do app: guarda a lista de filmes e todas as ações sobre ela.
///
/// `extends ChangeNotifier` dá a esta classe o poder de avisar as telas
/// quando algo muda. Toda vez que chamamos `notifyListeners()`, as telas
/// que estão "ouvindo" (com `context.watch`) se redesenham sozinhas.
///
/// Existe só UM controller no app inteiro (criado no main.dart), então
/// todas as telas enxergam a mesma lista.
///
/// Cada ação segue o mesmo padrão:
///   1. muda a lista na memória;
///   2. chama `notifyListeners()` (a tela atualiza na hora);
///   3. chama `_persistir()` (salva no celular em segundo plano).
class MovieListController extends ChangeNotifier {
  // O controller recebe o repositório de fora. Ele não sabe se é o
  // Hive (app de verdade) ou um falso (testes), e nem precisa saber.
  MovieListController(this._repository);

  final MovieRepository _repository;

  // A lista de filmes em memória. O `_` deixa ela privada: de fora,
  // só dá para ler pelo getter `movies`, e só dá para mudar pelos
  // métodos desta classe. Assim ninguém muda a lista sem avisar a tela.
  List<Movie> _movies = [];

  // Fica `true` quando terminamos de ler os filmes salvos.
  // A tela usa isso para mostrar um "carregando" enquanto é false.
  bool _carregado = false;

  /// A lista de filmes para as telas lerem.
  ///
  /// `List.unmodifiable` devolve uma versão "só leitura": se alguma tela
  /// tentar adicionar/remover direto nela, o app acusa erro.
  List<Movie> get movies => List.unmodifiable(_movies);

  /// Se os filmes salvos já foram carregados.
  bool get carregado => _carregado;

  /// Lê os filmes salvos no celular. É chamado uma vez, quando o app abre.
  Future<void> carregar() async {
    final salvos = await _repository.carregarTodos();
    // Se já tinha filmes salvos, usa eles. Se não (primeira vez que
    // o app abre), começa com a lista de exemplo.
    _movies = salvos.isNotEmpty ? salvos : List.of(mock_movies);
    _carregado = true;
    // Avisa a tela: "pode tirar o carregando e mostrar a lista".
    notifyListeners();
    // Na primeira vez, salva a lista de exemplo para a próxima abertura.
    if (salvos.isEmpty) await _persistir();
  }

  // Salva a lista atual inteira no repositório (no celular).
  Future<void> _persistir() => _repository.salvarTodos(_movies);

  /// Adiciona um filme novo ao backlog.
  void addMovie({required String titulo, required String url_da_capa, int? ano}) {
    _movies.add(
      Movie(
        // Usamos a data/hora atual em microssegundos como id. É um número
        // que nunca se repete na prática, então serve como id único.
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        titulo: titulo,
        url_da_capa: url_da_capa,
        ano: ano,
      ),
    );
    notifyListeners();
    _persistir();
  }

  /// Remove o filme com esse id.
  void removeMovie(String id) {
    // `removeWhere` apaga todos os itens que passam no teste
    // (aqui: o filme cujo id é igual ao informado).
    _movies.removeWhere((movie) => movie.id == id);
    notifyListeners();
    _persistir();
  }

  /// Marca como visto (ou desmarca, se já estava visto).
  void toggleWatched(String id) {
    // `!` inverte o valor: true vira false, false vira true.
    _updateMovie(id, (movie) => movie.copyWith(foi_visto: !movie.foi_visto));
  }

  /// Marca como favorito (ou desmarca, se já era favorito).
  void toggleFavorite(String id) {
    _updateMovie(id, (movie) => movie.copyWith(favorito: !movie.favorito));
  }

  /// Define a nota do filme.
  void setRating(String id, double nota) {
    _updateMovie(id, (movie) => movie.copyWith(nota: nota));
  }

  // Função auxiliar usada pelos três métodos acima, para não repetir código.
  // Ela acha o filme pelo id e troca ele pela versão atualizada.
  // `update` é uma função que recebe o filme antigo e devolve o novo.
  void _updateMovie(String id, Movie Function(Movie movie) update) {
    // Procura a posição do filme na lista. Devolve -1 se não achar.
    final index = _movies.indexWhere((movie) => movie.id == id);
    if (index == -1) return;
    // Troca o filme antigo pela cópia atualizada.
    _movies[index] = update(_movies[index]);
    notifyListeners();
    _persistir();
  }
}
