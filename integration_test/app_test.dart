// Import Flutter material UI toolkit
import 'package:flutter/material.dart';

// Import Flutter's widget testing framework
import 'package:flutter_test/flutter_test.dart';

// Import the integration test bindings
import 'package:integration_test/integration_test.dart';

// Import the main app entry point
import 'package:flutter_timeline_project/main.dart'; // Ensure this path is correct for your project

void main() {
  // Initialize the integration test binding so the test can run on a real device or emulator
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Define a test case for a full app smoke test
  testWidgets('Full app smoke test', (WidgetTester tester) async {
    // Build and render the entire Flutter app starting from the MyApp widget
    await tester.pumpWidget(const MyApp());

    // Wait for all frames and animations to complete
    await tester.pumpAndSettle();

    // Look for the navigation button to Module 6 and ensure it exists
    expect(find.text('Module 6 - Animated Timeline'), findsOneWidget);

    // Simulate a tap on the "Module 6 - Animated Timeline" button
    await tester.tap(find.text('Module 6 - Animated Timeline'));

    // Wait for the navigation animation and new screen to render
    await tester.pumpAndSettle();

    // Verify that the "Animated Timeline" title is now visible on the screen
    expect(find.text('Animated Timeline'), findsOneWidget);

    // Confirm that the screen contains an AppBar (to verify general UI structure)
    expect(find.byType(AppBar), findsOneWidget);
  });
}
