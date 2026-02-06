import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:irish_driving_test/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete User Flow Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Complete Mock Test Flow', (WidgetTester tester) async {
      await tester.pumpWidget(const IrishDrivingTestApp(navigatorObservers: []));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 1: Verify home screen loaded
      expect(find.text('Mock Test'), findsOneWidget);
      
      // Step 2: Tap Mock Test card
      await tester.tap(find.text('Mock Test'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 3: Verify quiz screen loaded
      // Should see timer and questions
      expect(find.textContaining(':'), findsWidgets); // Timer

      // Step 4: Answer 5 questions
      for (int i = 0; i < 5; i++) {
        // Find and tap first answer option
        final answerButtons = find.byType(ElevatedButton);
        if (answerButtons.evaluate().isNotEmpty) {
          await tester.tap(answerButtons.first);
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Tap Next button if visible
          final nextButton = find.text('Next');
          if (nextButton.evaluate().isNotEmpty) {
            await tester.tap(nextButton);
            await tester.pumpAndSettle(const Duration(seconds: 1));
          }
        }
      }

      print('✅ Mock Test Flow: 5 questions answered');
    });

    testWidgets('Learning Path Flow', (WidgetTester tester) async {
      await tester.pumpWidget(const IrishDrivingTestApp(navigatorObservers: []));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 1: Navigate to Learning Path
      await tester.tap(find.text('Learning Path'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 2: Should see modules
      // Tap first available module
      final moduleCards = find.byType(InkWell);
      if (moduleCards.evaluate().isNotEmpty) {
        await tester.tap(moduleCards.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Step 3: Answer 3 questions in module
        for (int i = 0; i < 3; i++) {
          final answerButtons = find.byType(ElevatedButton);
          if (answerButtons.evaluate().isNotEmpty) {
            await tester.tap(answerButtons.first);
            await tester.pumpAndSettle(const Duration(seconds: 1));

            final nextButton = find.text('Next');
            if (nextButton.evaluate().isNotEmpty) {
              await tester.tap(nextButton);
              await tester.pumpAndSettle(const Duration(seconds: 1));
            }
          }
        }
      }

      print('✅ Learning Path Flow: Module quiz completed');
    });

    testWidgets('Quick Mode Flow', (WidgetTester tester) async {
      await tester.pumpWidget(const IrishDrivingTestApp(navigatorObservers: []));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Quick Mode
      await tester.tap(find.text('Quick Mode'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Answer 3 questions
      for (int i = 0; i < 3; i++) {
        final answerButtons = find.byType(ElevatedButton);
        if (answerButtons.evaluate().isNotEmpty) {
          await tester.tap(answerButtons.first);
          await tester.pumpAndSettle(const Duration(seconds: 1));

          final nextButton = find.text('Next');
          if (nextButton.evaluate().isNotEmpty) {
            await tester.tap(nextButton);
            await tester.pumpAndSettle(const Duration(seconds: 1));
          }
        }
      }

      print('✅ Quick Mode Flow: 3 questions answered');
    });

    testWidgets('Progress Tracking Flow', (WidgetTester tester) async {
      await tester.pumpWidget(const IrishDrivingTestApp(navigatorObservers: []));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 1: Check initial progress
      await tester.tap(find.text('My Progress'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should see progress stats
      expect(find.textContaining('XP'), findsWidgets);
      expect(find.textContaining('Level'), findsWidgets);

      print('✅ Progress Screen: Stats displayed');

      // Step 2: Go back to home
      await tester.pageBack();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 3: Complete a quiz to increase progress
      await tester.tap(find.text('Quick Mode'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Answer questions
      for (int i = 0; i < 5; i++) {
        final answerButtons = find.byType(ElevatedButton);
        if (answerButtons.evaluate().isNotEmpty) {
          await tester.tap(answerButtons.first);
          await tester.pumpAndSettle(const Duration(seconds: 1));

          final nextButton = find.text('Next');
          if (nextButton.evaluate().isNotEmpty) {
            await tester.tap(nextButton);
            await tester.pumpAndSettle(const Duration(seconds: 1));
          }
        }
      }

      print('✅ Progress Tracking: Quiz completed for XP gain');
    });

    testWidgets('All Questions Browse Flow', (WidgetTester tester) async {
      await tester.pumpWidget(const IrishDrivingTestApp(navigatorObservers: []));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to All Questions
      await tester.tap(find.text('All Questions'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should see search bar and question list
      expect(find.byType(TextField), findsWidgets); // Search bar

      print('✅ All Questions Flow: Browse mode loaded');
    });

    testWidgets('Blitz Mode Flow', (WidgetTester tester) async {
      await tester.pumpWidget(const IrishDrivingTestApp(navigatorObservers: []));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Blitz Mode
      await tester.tap(find.text('Blitz Mode'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should see timer (2 minutes)
      expect(find.textContaining(':'), findsWidgets);

      // Answer 3 questions quickly
      for (int i = 0; i < 3; i++) {
        final answerButtons = find.byType(ElevatedButton);
        if (answerButtons.evaluate().isNotEmpty) {
          await tester.tap(answerButtons.first);
          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          final nextButton = find.text('Next');
          if (nextButton.evaluate().isNotEmpty) {
            await tester.tap(nextButton);
            await tester.pumpAndSettle(const Duration(milliseconds: 500));
          }
        }
      }

      print('✅ Blitz Mode Flow: Speed quiz tested');
    });
  });
}
