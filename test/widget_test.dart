// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:fire_management/main.dart';

void main() {
  testWidgets('Fire safety app loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FireSafetyApp());

    expect(find.text('🔥 Smart Fire Safety'), findsOneWidget);
    expect(find.text('Checking...'), findsOneWidget);
    expect(find.text('Emergency Response'), findsOneWidget);
  });
}
