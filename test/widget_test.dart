import 'package:flutter_test/flutter_test.dart';

import 'package:backlog_app/data/mock_movies.dart';
import 'package:backlog_app/main.dart';

void main() {
  testWidgets('Home screen lists mocked movies', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the mocked movies are rendered in the list.
    expect(find.text(mock_movies.first.titulo), findsOneWidget);
  });
}
