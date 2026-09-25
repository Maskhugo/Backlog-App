import 'package:hive_ce_flutter/hive_flutter.dart';

import '../models/movie.dart';
import 'movie_repository.dart';

/// Salva e lê os filmes na memória interna do celular usando o Hive.
///
/// O Hive é um banco de dados local: os dados ficam guardados num
/// arquivo dentro do celular e não se perdem quando você fecha o app.
///
/// `implements MovieRepository` = esta classe cumpre o "contrato"
/// definido em movie_repository.dart (tem os métodos carregarTodos e
/// salvarTodos).
class HiveMovieRepository implements MovieRepository {
  // No Hive, os dados ficam em "caixas" (Box). Cada caixa tem um nome
  // e vira um arquivo no celular. A nossa se chama 'movies'.
  static const _boxName = 'movies';

  // Abre a caixa (ou cria, se for a primeira vez).
  // O `_` no começo do nome deixa o método privado: só esta classe usa.
  Future<Box> _abrirBox() => Hive.openBox(_boxName);

  /// Lê todos os filmes salvos na caixa e transforma cada um de volta
  /// num objeto `Movie`.
  @override
  Future<List<Movie>> carregarTodos() async {
    // `await` = espera a caixa abrir antes de continuar.
    final box = await _abrirBox();
    // `box.values` são todos os itens salvos (cada um é um Map).
    // `.map(...)` transforma cada Map num Movie, e `.toList()` junta
    // tudo numa lista.
    return box.values
        .map((valor) => Movie.fromMap(Map<String, dynamic>.from(valor as Map)))
        .toList();
  }

  /// Salva a lista inteira de filmes na caixa.
  ///
  /// A estratégia é simples: apaga tudo e grava a lista de novo.
  /// Para algumas centenas de filmes isso é rápido e evita ter que
  /// controlar qual filme mudou.
  @override
  Future<void> salvarTodos(List<Movie> movies) async {
    final box = await _abrirBox();
    // Apaga tudo o que estava salvo.
    await box.clear();
    // Converte cada filme em Map (com toMap) e grava todos de uma vez.
    await box.addAll(movies.map((movie) => movie.toMap()));
  }
}
