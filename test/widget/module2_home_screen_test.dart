import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timeline_project/module2_home_screen.dart'; // Import the screen to be tested

void main() {
  // A widget test to verify the UI of Module2HomeScreen
  testWidgets('Module2HomeScreen displays welcome message', (WidgetTester tester) async {
    // Pump the widget into the test environment
    // Wrap it in MaterialApp to provide necessary context for widgets like AppBar and Scaffold
    await tester.pumpWidget(
      const MaterialApp(
        home: Module2HomeScreen(), // The widget we are testing
      ),
    );

    // Assert that the welcome message appears exactly once on screen
    expect(find.text('Welcome to the Responsive Timeline Project'), findsOneWidget);

    // Assert that an AppBar is present in the widget tree
    expect(find.byType(AppBar), findsOneWidget);

    // Assert that the AppBar contains the expected title text
    expect(find.text('Module 2: Flutter Basics'), findsOneWidget);
  });
}

