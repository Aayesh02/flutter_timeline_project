// Import Flutter framework for UI components
import 'package:flutter/material.dart';

// Import Flutter's test package for widget testing
import 'package:flutter_test/flutter_test.dart';

// Import your main application entry point
import 'package:flutter_timeline_project/main.dart'; // Adjust the path if needed

void main() {
  // Define a widget test to ensure the animated timeline screen renders correctly
  testWidgets('Animated timeline screen loads with expected UI elements', (WidgetTester tester) async {
    // Load the full app widget
    await tester.pumpWidget(const MyApp());

    // Allow any animations and frame builds to complete (home screen loads here)
    await tester.pumpAndSettle();

    // Simulate a tap on the "Module 6 - Animated Timeline" button to navigate to the timeline screen
    await tester.tap(find.text('Module 6 - Animated Timeline'));

    // Wait for the navigation animation and target screen to fully render
    await tester.pumpAndSettle();

    // Check that the screen displays the expected AppBar title for Module 6
    expect(find.text('Animated Timeline'), findsOneWidget);

    // Confirm an AppBar is rendered on this screen
    expect(find.byType(AppBar), findsOneWidget);
  });
}
