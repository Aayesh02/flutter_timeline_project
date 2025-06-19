import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timeline_project/module4_timeline_screen.dart'; // Import the screen you're testing

void main() {
  // A widget test to verify that the Module 4 Timeline renders as expected
  testWidgets('Module 4: Timeline renders events and indicators', (WidgetTester tester) async {
    // Build the timeline screen widget inside a MaterialApp to provide necessary context
    await tester.pumpWidget(const MaterialApp(
      home: Module4TimelineScreen(), // Screen under test
    ));

    // Verify that the app bar title is correctly displayed
    expect(find.text('Timeline (Module 4)'), findsOneWidget);

    // Verify that specific timeline events (with date and title) are displayed
    expect(find.text('2025-06-01: Started Project'), findsOneWidget);
    expect(find.text('2025-06-02: Completed Module 1'), findsOneWidget);
    expect(find.text('2025-06-07: Now on Module 4'), findsOneWidget);

    // Optionally check that there are exactly 4 checkmark icons (one per event)
    // These represent the DotIndicator children
    expect(find.byIcon(Icons.check), findsNWidgets(4));
  });
}
