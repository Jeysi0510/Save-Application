// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:ipon_challenge/main.dart';

void main() {
  testWidgets('Ipon Challenge app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const IponChallengeApp());
    await tester.pump();
    // App loads without crashing
    expect(find.byType(IponChallengeApp), findsOneWidget);
  });
}
