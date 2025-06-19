import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timeline_project/module3_counter_riverpod.dart'; // Import the screen you're testing

void main() {
  // Test to verify that tapping the FloatingActionButton increments the counter
  testWidgets('Counter increments when FAB is tapped', (WidgetTester tester) async {
    // Build the widget and wrap it with ProviderScope (required for Riverpod)
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CounterHomeScreen(), // Screen under test
        ),
      ),
    );

    // Verify that the initial counter text is shown
    expect(find.text('Counter: 0'), findsOneWidget); // Initial state
    expect(find.text('Counter: 1'), findsNothing);   // Not yet incremented

    // Simulate a tap on the FloatingActionButton
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(); // Trigger a rebuild to reflect state change

    // Verify that the counter increments correctly
    expect(find.text('Counter: 1'), findsOneWidget); // Updated state
    expect(find.text('Counter: 0'), findsNothing);   // Old state should no longer exist
  });
}
