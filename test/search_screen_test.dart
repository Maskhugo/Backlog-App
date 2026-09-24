import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:backlog_app/data/tmdb_repository.dart';
import 'package:backlog_app/screens/search_screen.dart';
import 'package:backlog_app/state/movie_list_controller.dart';

import 'support/fake_movie_repository.dart';

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
    final controller = MovieListController(FakeMovieRepository());
    await controller.carregar();
    final tamanhoInicial = controller.movies.length;

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          home: SearchScreen(repository: FakeTmdbRepository()),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'busca qualquer');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('Filme Falso'), findsOneWidget);

    await tester.tap(find.text('Filme Falso'));
    await tester.pumpAndSettle();

    expect(controller.movies.length, tamanhoInicial + 1);
    expect(controller.movies.last.titulo, 'Filme Falso');
    expect(controller.movies.last.ano, 2024);
  });
}
