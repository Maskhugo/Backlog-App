import 'package:flutter_test/flutter_test.dart';

import 'package:backlog_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our welcome text is present.
    expect(find.text('Welcome to Backlog App'), findsOneWidget);
  });
}
