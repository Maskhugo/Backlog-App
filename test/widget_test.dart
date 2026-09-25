import 'package:flutter_test/flutter_test.dart';

import 'package:backlog_app/data/mock_movies.dart';
import 'package:backlog_app/main.dart';

import 'support/fake_movie_repository.dart';

// Todo arquivo de teste começa pela função `main`, que agrupa os testes.
void main() {
  // `testWidgets` cria um teste que monta widgets numa tela invisível.
  // O `tester` é quem "mexe" no app: desenha, toca, digita...
  testWidgets('Home screen lists mocked movies', (WidgetTester tester) async {
    // Monta o app inteiro, mas com o repositório falso (sem Hive).
    await tester.pumpWidget(MyApp(repository: FakeMovieRepository()));
    // A lista carrega de forma assíncrona. `pumpAndSettle` espera até
    // a tela parar de mudar (o carregamento terminar e a lista aparecer).
    await tester.pumpAndSettle();

    // `expect(o que procurar, quantas vezes deve aparecer)`.
    // Aqui: o título do primeiro filme de exemplo aparece exatamente 1 vez.
    expect(find.text(mock_movies.first.titulo), findsOneWidget);
  });
}
