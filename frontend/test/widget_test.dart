import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cross_platform/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(
      const ProviderScope(
        child: NoBrokerApp(),
      ),
    );

    // Verify app loads
    expect(find.text('NoBroker Owner Listings'), findsOneWidget);
  });
}
