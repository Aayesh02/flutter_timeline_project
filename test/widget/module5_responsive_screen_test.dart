import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timeline_project/module5_responsive_ui.dart'; // Import the responsive screen to be tested

void main() {
  // Test case to verify the layout for mobile-sized screens (small width)
  testWidgets('Displays mobile layout on small screens', (WidgetTester tester) async {
    // Build the ResponsiveHomeScreen inside a MediaQuery and MaterialApp
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(), // Provide default media data
          child: Center(
            child: SizedBox(
              width: 400, // Simulate a narrow screen (mobile width)
              height: 800,
              child: const ResponsiveHomeScreen(), // Screen under test
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(); // Wait for any animations or async operations

    // Verify the mobile-specific UI text is shown
    expect(find.text('Mobile Layout - Timeline Summary'), findsOneWidget);
  });

  // Test case to verify the layout for desktop-sized screens (wide width)
  testWidgets('Displays desktop layout on wide screens', (WidgetTester tester) async {
    // Build the ResponsiveHomeScreen in a wider layout
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(), // Provide default media data
          child: Center(
            child: SizedBox(
              width: 800, // Simulate a wide screen (desktop/tablet width)
              height: 800,
              child: const ResponsiveHomeScreen(), // Screen under test
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(); // Wait for the widget to finish building

    // Verify desktop-specific widgets/texts are displayed
    expect(find.text('Left Panel - Timeline List'), findsOneWidget);
    expect(find.text('Right Panel - Timeline Details'), findsOneWidget);
  });
}

