import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timeline_project/main.dart';

void main() {
  testWidgets('Animated timeline screen loads with expected UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Allow animations/timers to complete
    await tester.pumpAndSettle();

    // Verify expected UI content
    expect(find.text('Animated Timeline'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });
}

