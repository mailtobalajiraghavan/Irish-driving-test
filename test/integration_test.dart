import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:irish_driving_test/main.dart';
import 'package:irish_driving_test/screens/home_screen.dart';

void main() {
  group('Irish Driving Test - Simplified Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('App boots successfully', (WidgetTester tester) async {
      await tester.pumpWidget(const IrishDrivingTestApp(navigatorObservers: []));
      await tester.pump(const Duration(seconds: 1));
      
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Home screen shows all quiz mode cards', (WidgetTester tester) async {
      await tester.pumpWidget(const IrishDrivingTestApp(navigatorObservers: []));
      await tester.pump(const Duration(seconds: 1));

      // Verify all 8 quiz mode options are present
      expect(find.text('Learning Path'), findsOneWidget);
      expect(find.text('Mock Test'), findsOneWidget);
      expect(find.text('Quick Mode'), findsOneWidget);
      expect(find.text('Blitz Mode'), findsOneWidget);
      expect(find.text('Sudden Death'), findsOneWidget);
      expect(find.text('All Questions'), findsOneWidget);
      expect(find.text('Wrong Questions'), findsOneWidget);
      expect(find.text('My Progress'), findsOneWidget);
    });

    testWidgets('XP progress bar is visible on home screen', (WidgetTester tester) async {
      await tester.pumpWidget(const IrishDrivingTestApp(navigatorObservers: []));
      await tester.pump(const Duration(seconds: 1));

      // Should show XP-related text
      expect(find.textContaining('XP'), findsWidgets);
      expect(find.textContaining('Level'), findsWidgets);
    });

    testWidgets('Dashboard stats are visible', (WidgetTester tester) async {
      await tester.pumpWidget(const IrishDrivingTestApp(navigatorObservers: []));
      await tester.pump(const Duration(seconds: 1));

      // Should show stats
      expect(find.textContaining('Completed'), findsWidgets);
      expect(find.textContaining('Accuracy'), findsWidgets);
    });

    testWidgets('All quiz mode cards are tappable widgets', (WidgetTester tester) async {
      await tester.pumpWidget(const IrishDrivingTestApp(navigatorObservers: []));
      await tester.pump(const Duration(seconds: 1));

      // Find all quiz mode cards
      final learningPath = find.text('Learning Path');
      final mockTest = find.text('Mock Test');
      final quickMode = find.text('Quick Mode');

      // Verify they exist
      expect(learningPath, findsOneWidget);
      expect(mockTest, findsOneWidget);
      expect(quickMode, findsOneWidget);

      // Verify they're inside interactive widgets (InkWell, GestureDetector, etc.)
      expect(find.ancestor(of: learningPath, matching: find.byType(InkWell)), findsWidgets);
    });

    testWidgets('App title is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(const IrishDrivingTestApp(navigatorObservers: []));
      await tester.pump(const Duration(seconds: 1));

      // App should have material app with title
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, 'Irish Driving Test');
    });
  });
}
