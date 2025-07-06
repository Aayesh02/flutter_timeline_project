// integration_test/app_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_timeline_project/main.dart' as app; // Imports the main application file.
import 'package:flutter/widgets.dart'; // Imports Flutter's widget library, including debugDumpApp.
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Imports Riverpod for state management.
import 'package:flutter_timeline_project/notifiers/timeline_notifier.dart'; // Imports the timeline notifier.

/// Main function to define and run integration tests.
void main() {
  // Ensures that the integration test binding is initialized before running tests.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Group of end-to-End tests for the Timeline application.
  group('End-to-End Timeline App Test Suite', () {
    /// Tests the complete flow of adding, editing, and deleting a timeline event.
    testWidgets('Add, Edit, and Delete a Timeline Event', (WidgetTester tester) async {
      // 1. Launch the application.
      // This calls the main function of the app, setting up the widget tree including the ProviderScope.
      app.main();
      // Waits for all widgets to build and all animations to settle.
      // This is crucial after launching the app or after any significant UI change.
      await tester.pumpAndSettle();

      // Verify the initial state of the application.
      // Checks for the main app title and the initial instruction message.
      expect(find.text('Interactive Timeline'), findsOneWidget);
      expect(find.text('Start your timeline by adding an event!'), findsOneWidget);

      // 2. Add a new event.
      // Finds and taps the 'Add Event' button using its Key.
      await tester.tap(find.byKey(const Key('add_event_button')));
      await tester.pumpAndSettle(); // Waits for the new event dialog to appear.

      // Verifies that the 'Add New Timeline Event' dialog is open.
      expect(find.text('Add New Timeline Event'), findsOneWidget);

      // Enters text into the 'Event Title' and 'Event Description' text fields.
      await tester.enterText(find.widgetWithText(TextField, 'Event Title'), 'My First Test Event');
      await tester.enterText(find.widgetWithText(TextField, 'Event Description'), 'This is a description for my first test event.');
      await tester.pumpAndSettle(); // Ensures the text input is processed and UI updates.

      // Taps the 'Add Event' button within the dialog to submit the new event.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Event'));
      await tester.pumpAndSettle(); // Waits for the dialog to close and the timeline to update.

      // Verifies that the newly added event appears on the timeline.
      // The initial message should now be gone as an event has been added.
      expect(find.textContaining('My First Test Event'), findsOneWidget);
      expect(find.text('Start your timeline by adding an event!'), findsNothing);

      // 3. Expand the event to reveal Edit/Delete buttons
      // Tap the event's title to toggle its expansion.
      await tester.tap(find.textContaining('My First Test Event'));
      await tester.pumpAndSettle();

      // Verifies that the description and action buttons are visible after expansion.
      expect(find.text('This is a description for my first test event.'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);

      // 4. Edit the timeline event
      // Tap the 'Edit' button associated with the event.
      // Uses .first to target the first 'edit' icon found, in case of multiple events.
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle(); // Waits for the edit event dialog to appear.

      // Verifies that the 'Edit Timeline Event' dialog is open and pre-filled.
      expect(find.text('Edit Timeline Event'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'My First Test Event'), findsOneWidget);

      // Changes the event details.
      await tester.enterText(find.widgetWithText(TextField, 'My First Test Event'), 'Updated Test Event');
      await tester.enterText(find.widgetWithText(TextField, 'This is a description for my first test event.'), 'This event was updated via integration test.');
      await tester.pumpAndSettle(); // Ensures text input is processed.

      // Taps the 'Save Changes' button within the dialog.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
      await tester.pumpAndSettle(); // Waits for the dialog to close and timeline to update.

      // --- DEBUGGING STEP: Verify Riverpod state after edit ---
      // Finds a BuildContext that is a descendant of ProviderScope (e.g., Scaffold).
      // This is necessary to access the ProviderContainer.
      await tester.pump(); // Ensures a frame is pumped to establish context.
      final BuildContext scaffoldContext = tester.element(find.byType(Scaffold));
      final container = ProviderScope.containerOf(scaffoldContext);
      final notifier = container.read(timelineProvider.notifier);
      final currentState = notifier.state;

      // Prints current timeline state to the console for debugging.
      tester.printToConsole('--- Current timeline state after edit (DEBUG) ---');
      if (currentState.events.isNotEmpty) {
        for (var event in currentState.events) {
          tester.printToConsole('  Event: ${event.title}, Desc: ${event.description}, ID: ${event.id}');
        }
      } else {
        tester.printToConsole('  No events in state.');
      }
      tester.printToConsole('-------------------------------------------------');
      // --- END DEBUGGING STEP ---

      // Verify the updated title is present.
      final updatedTitleTextFinder = find.textContaining('Updated Test Event');
      expect(updatedTitleTextFinder, findsOneWidget, reason: 'Updated event title text should be found after edit.');
      await tester.pumpAndSettle(); // Ensure the text is fully rendered and settled

      // Removed the re-tap on updatedTitleTextFinder here, as the editEvent
      // notifier method ensures the event remains expanded. Tapping it again
      // would cause it to collapse.

      // Robustly wait for the updated description text to appear.
      final updatedDescriptionFinder = find.textContaining('This event was updated via integration test.');
      
      await tester.runAsync(() async {
        bool found = false;
        // Sets a maximum wait time of 5 seconds (50 attempts * 100ms per pumpAndSettle).
        for (int i = 0; i < 50; i++) {
          await tester.pumpAndSettle(const Duration(milliseconds: 100));
          if (tester.any(updatedDescriptionFinder)) {
            found = true;
            break;
          }
        }
        // If the text is not found within the timeout, print debug info and fail the test.
        if (!found) {
          tester.printToConsole('Updated description text not found after multiple attempts within timeout. Dumping widget tree:');
          debugDumpApp(); // Dumps the widget tree for detailed debugging.
          fail('Updated description text not found after multiple attempts within timeout.');
        }
      });
      
      // Final assertion: The updated description text should be visible.
      expect(updatedDescriptionFinder, findsOneWidget);

      // 5. Delete the timeline event
      // Tap the 'Delete' button.
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle(); // Waits for the confirmation dialog to appear.

      // Verifies that the 'Confirm Deletion' dialog is open.
      expect(find.text('Confirm Deletion'), findsOneWidget);
      expect(find.text('Are you sure you want to delete "Updated Test Event"?'), findsOneWidget);

      // Confirms the deletion.
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle(); // Waits for the dialog to close and the snackbar to appear.

      // Verifies that the event is removed from the timeline and the initial message reappears.
      expect(find.text('Updated Test Event'), findsNothing);
      expect(find.text('Start your timeline by adding an event!'), findsOneWidget);
      // Verifies the snackbar message confirming deletion.
      expect(find.text('"Updated Test Event" deleted.'), findsOneWidget);
    });

    /// Tests that the application handles window resizing gracefully, preventing overflows.
    testWidgets('App handles window resize gracefully', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Simulates a small mobile landscape width.
      tester.view.physicalSize = const Size(600, 300);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpAndSettle();

      // Asserts that no overflow errors occur after resizing.
      expect(tester.takeException(), isNull); 

      // Simulates a desktop width.
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Resets the view to default for consistency with other tests.
      tester.view.reset();
    });
  });
}
