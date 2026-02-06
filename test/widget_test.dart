// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:irish_driving_test/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const IrishDrivingTestApp(navigatorObservers: []));
    // Use pump with duration because HomeScreen has infinite animations (shaking car)
    // which causes pumpAndSettle to timeout.
    await tester.pump(const Duration(seconds: 2));

    // Verify basic app structure
    expect(find.byType(MaterialApp), findsOneWidget);
    // You might want to add more specific expectations based on HomeScreen content
    // For now, ensuring it boots up without error is a good verification
  });
}
