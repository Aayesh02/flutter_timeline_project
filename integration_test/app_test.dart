// integration_test/app_test.dart

import 'package:flutter_test/flutter_test.dart'; // Flutter testing framework
import 'package:integration_test/integration_test.dart'; // Integration testing utilities
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod for state management
import 'package:flutter/material.dart'; // Flutter material widgets

// Import your main app file to access Module4TimelineScreen widget
import 'package:flutter_timeline_project/main.dart';

void main() {
  // Initialize the integration test binding, which connects the test framework
  // with Flutter's engine and enables integration testing features.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Define an integration test scenario with a descriptive name
  testWidgets('Add Intervention flow', (WidgetTester tester) async {
    // Build and render the widget tree that matches your app's UI entrypoint.
    // Here, you wrap the main screen inside ProviderScope (for Riverpod state)
    // and MaterialApp to provide material design context.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Module4TimelineScreen(),
        ),
      ),
    );
    // Wait for all animations and async tasks to complete
    await tester.pumpAndSettle();

    // Find the "Add Intervention" button by its unique Key
    final addInterventionButton = find.byKey(const Key('add_intervention_button'));
    // Verify that the button exists exactly once in the widget tree
    expect(addInterventionButton, findsOneWidget);

    // Simulate a tap on the "Add Intervention" button
    await tester.tap(addInterventionButton);
    // Wait for any animations, dialogs, or state updates triggered by the tap
    await tester.pumpAndSettle();

    // Find the title of the intervention dialog by its Key
    final dialogTitle = find.byKey(const Key('add_intervention_dialog_title'));
    // Verify the dialog is displayed
    expect(dialogTitle, findsOneWidget);

    // Find the increment button for meeting frequency by Key
    final meetingFreqIncrement = find.byKey(const Key('meeting_frequency_increment'));
    expect(meetingFreqIncrement, findsOneWidget);
    // Simulate tapping the increment button to increase meeting frequency
    await tester.tap(meetingFreqIncrement);
    await tester.pumpAndSettle();

    // Find the decrement button for reward frequency by Key
    final rewardFreqDecrement = find.byKey(const Key('reward_frequency_decrement'));
    expect(rewardFreqDecrement, findsOneWidget);
    // Simulate tapping the decrement button to decrease reward frequency
    await tester.tap(rewardFreqDecrement);
    await tester.pumpAndSettle();

    // Find the text input field for reward frequency by Key
    final rewardFreqField = find.byKey(const Key('reward_frequency_field'));
    expect(rewardFreqField, findsOneWidget);
    // Enter the text "3" into the reward frequency field
    await tester.enterText(rewardFreqField, '3');
    await tester.pumpAndSettle();

    // Find the Save button on the dialog by Key
    final saveButton = find.byKey(const Key('add_intervention_dialog_save_button'));
    expect(saveButton, findsOneWidget);
    // Simulate tapping the Save button to close the dialog and save changes
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify the "Add Intervention" button is still present after closing dialog
    expect(addInterventionButton, findsOneWidget);
  });
}
