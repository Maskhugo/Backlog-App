import 'package:flutter_test/flutter_test.dart';

import 'package:backlog_app/data/mock_movies.dart';
import 'package:backlog_app/main.dart';

import 'support/fake_movie_repository.dart';

void main() {
  testWidgets('Home screen lists mocked movies', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(repository: FakeMovieRepository()));
    // The movie list loads asynchronously from the repository.
    await tester.pumpAndSettle();

    // Verify that the mocked movies are rendered in the list.
    expect(find.text(mock_movies.first.titulo), findsOneWidget);
  });
}
