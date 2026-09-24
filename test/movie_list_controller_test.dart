import 'package:flutter_test/flutter_test.dart';

import 'package:backlog_app/state/movie_list_controller.dart';

void main() {
  group('MovieListController', () {
    late MovieListController controller;

    setUp(() {
      controller = MovieListController();
    });

    test('addMovie appends a new movie to the list', () {
      final tamanhoInicial = controller.movies.length;

      controller.addMovie(titulo: 'Novo Filme', url_da_capa: 'https://example.com/capa.jpg');

      expect(controller.movies.length, tamanhoInicial + 1);
      expect(controller.movies.last.titulo, 'Novo Filme');
    });

    test('removeMovie removes the movie with the matching id', () {
      final alvo = controller.movies.first;

      controller.removeMovie(alvo.id);

      expect(controller.movies.any((movie) => movie.id == alvo.id), isFalse);
    });

    test('toggleFavorite flips the favorito flag', () {
      final alvo = controller.movies.first;
      final favoritoInicial = alvo.favorito;

      controller.toggleFavorite(alvo.id);

      final atualizado = controller.movies.firstWhere((movie) => movie.id == alvo.id);
      expect(atualizado.favorito, !favoritoInicial);
    });

    test('toggleWatched flips the foi_visto flag', () {
      final alvo = controller.movies.first;
      final vistoInicial = alvo.foi_visto;

      controller.toggleWatched(alvo.id);

      final atualizado = controller.movies.firstWhere((movie) => movie.id == alvo.id);
      expect(atualizado.foi_visto, !vistoInicial);
    });

    test('setRating updates the nota field', () {
      final alvo = controller.movies.first;

      controller.setRating(alvo.id, 9.5);

      final atualizado = controller.movies.firstWhere((movie) => movie.id == alvo.id);
      expect(atualizado.nota, 9.5);
    });
  });
}
