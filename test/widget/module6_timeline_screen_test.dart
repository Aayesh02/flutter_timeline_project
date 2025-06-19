import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timeline_project/module6_animated_timeline.dart'; // Import the animated timeline screen

void main() {
  testWidgets('Expands timeline card and shows details', (WidgetTester tester) async {
    // Build the TimelineScreen widget wrapped in MaterialApp (required for Material design components like SnackBar)
    await tester.pumpWidget(
      const MaterialApp(home: TimelineScreen()),
    );

    // Allow staggered animations (fade/size transitions) to play out by pumping for 3 seconds
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle(); // Finish any pending frames or animations

    // Find the first event title on the screen
    final titles = find.text('Project Kickoff');
    expect(titles, findsOneWidget); // Ensure the initial event is present

    // Simulate a tap on the event to expand it
    await tester.tap(titles);
    await tester.pumpAndSettle(); // Wait for animation and rebuild to complete

    // Confirm that the expanded content is displayed
    expect(find.text('Initial project setup and team alignment.'), findsOneWidget);
    expect(find.textContaining('Date: 6/1/2025'), findsOneWidget); // Checks timestamp formatting

    // Tap on the 'More Info' button within the expanded card
    await tester.tap(find.text('More Info'));
    await tester.pump(); // Trigger the display of the SnackBar

    // Verify that the SnackBar appears with the expected message
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Details for "Project Kickoff"'), findsOneWidget);
  });
}
