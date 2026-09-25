import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:backlog_app/data/tmdb_repository.dart';
import 'package:backlog_app/screens/search_screen.dart';
import 'package:backlog_app/state/movie_list_controller.dart';

import 'support/fake_movie_repository.dart';

/// Uma TMDB "de mentira": em vez de ir na internet, sempre devolve o
/// mesmo filme. Assim o teste não depende de internet nem do token.
///
/// `extends TmdbRepository` herda tudo do repositório real, e o
/// `@override` substitui só o método `buscarFilmes`.
class FakeTmdbRepository extends TmdbRepository {
  @override
  Future<List<TmdbSearchResult>> buscarFilmes(String query) async {
    return [
      const TmdbSearchResult(id: 1, titulo: 'Filme Falso', url_da_capa: '', ano: 2024),
    ];
  }
}

void main() {
  testWidgets('busca exibe resultados e adiciona ao backlog ao tocar', (tester) async {
    // Prepara um controller com o repositório falso e carrega a lista inicial.
    final controller = MovieListController(FakeMovieRepository());
    await controller.carregar();
    // Guarda quantos filmes tinha antes, para comparar no final.
    final tamanhoInicial = controller.movies.length;

    // Monta só a tela de busca, entregando o nosso controller para ela
    // (`ChangeNotifierProvider.value` usa um controller já existente).
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          home: SearchScreen(repository: FakeTmdbRepository()),
        ),
      ),
    );

    // Simula o usuário digitando e apertando a lupa do teclado.
    await tester.enterText(find.byType(TextField), 'busca qualquer');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    // O resultado falso deve aparecer na tela.
    expect(find.text('Filme Falso'), findsOneWidget);

    // Simula o toque no resultado.
    await tester.tap(find.text('Filme Falso'));
    await tester.pumpAndSettle();

    // Confere que o filme entrou no backlog, com o título e o ano certos.
    expect(controller.movies.length, tamanhoInicial + 1);
    expect(controller.movies.last.titulo, 'Filme Falso');
    expect(controller.movies.last.ano, 2024);
  });
}
