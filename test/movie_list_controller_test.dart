import 'package:flutter_test/flutter_test.dart';

import 'package:backlog_app/state/movie_list_controller.dart';

import 'support/fake_movie_repository.dart';

// Testes de unidade: testam o controller sozinho, sem tela nenhuma.
// Cada `test` segue o formato "prepara → executa → confere".
void main() {
  // `group` junta testes relacionados sob um mesmo nome.
  group('MovieListController', () {
    // `late` = a variável é preenchida depois, no setUp.
    late MovieListController controller;

    // `setUp` roda ANTES de cada teste. Assim cada teste começa com um
    // controller novinho e não é afetado pelo teste anterior.
    setUp(() async {
      controller = MovieListController(FakeMovieRepository());
      await controller.carregar();
    });

    test('addMovie appends a new movie to the list', () {
      final tamanhoInicial = controller.movies.length;

      controller.addMovie(titulo: 'Novo Filme', url_da_capa: 'https://example.com/capa.jpg');

      // A lista deve ter um filme a mais, e ele deve ser o último.
      expect(controller.movies.length, tamanhoInicial + 1);
      expect(controller.movies.last.titulo, 'Novo Filme');
    });

    test('removeMovie removes the movie with the matching id', () {
      final alvo = controller.movies.first;

      controller.removeMovie(alvo.id);

      // `any` pergunta "existe algum filme com esse id?". Deve ser falso.
      expect(controller.movies.any((movie) => movie.id == alvo.id), isFalse);
    });

    test('toggleFavorite flips the favorito flag', () {
      final alvo = controller.movies.first;
      final favoritoInicial = alvo.favorito;

      controller.toggleFavorite(alvo.id);

      // Buscamos o filme de novo na lista, porque o controller troca o
      // objeto por uma cópia nova (o `alvo` antigo não muda).
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

    // Este teste confere que as mudanças são SALVAS, simulando o app
    // fechando e abrindo de novo.
    test('mutações são persistidas no repositório (write-through)', () async {
      // Um repositório compartilhado entre os dois controllers abaixo,
      // fazendo o papel do "armazenamento do celular".
      final repository = FakeMovieRepository();
      final outroController = MovieListController(repository);
      await outroController.carregar();

      outroController.addMovie(titulo: 'Persistido', url_da_capa: 'https://example.com/x.jpg');
      // O salvamento roda em segundo plano; esta linha dá uma "pausa"
      // mínima para ele terminar antes de continuarmos.
      await Future<void>.delayed(Duration.zero);

      // Um controller NOVO, lendo do mesmo repositório = "reabrir o app".
      final controllerRecarregado = MovieListController(repository);
      await controllerRecarregado.carregar();

      // O filme adicionado antes deve estar lá.
      expect(
        controllerRecarregado.movies.any((movie) => movie.titulo == 'Persistido'),
        isTrue,
      );
    });
  });
}
