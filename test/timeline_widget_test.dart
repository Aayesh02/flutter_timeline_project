// test/timeline_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timeline_project/main.dart'; // Imports the main application file.
import 'package:flutter_timeline_project/models/timeline_event.dart';
import 'package:flutter_timeline_project/notifiers/timeline_notifier.dart';
import 'package:flutter_timeline_project/widgets/new_event_dialog.dart';

/// Main function to define and run widget tests.
void main() {
  /// Group of tests for the [Module4TimelineScreen] widget.
  group('Module4TimelineScreen Widget Tests', () {
    /// Tests that the app bar and initial instructional text are displayed correctly.
    testWidgets('App bar and initial text are displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Module4TimelineScreen(),
          ),
        ),
      );

      // Verify the presence of key UI elements.
      expect(find.text('Interactive Timeline'), findsOneWidget);
      expect(find.text('Welcome to the Responsive Timeline Project'), findsOneWidget);
      expect(find.text('Start your timeline by adding an event!'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget); // Checks for the Add Event button icon on the main screen.
      expect(find.text('Add Event'), findsOneWidget); // Checks for the Add Event button text on the main screen.
    });

    /// Tests that tapping the "Add Event" button correctly opens the [NewEventDialog].
    testWidgets('Tapping "Add Event" button opens NewEventDialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Module4TimelineScreen(),
          ),
        ),
      );

      // Tap the "Add Event" button on the main screen.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle(); // Waits for the dialog to open and settle.

      // Verify that the NewEventDialog is displayed with its expected elements.
      expect(find.byType(NewEventDialog), findsOneWidget);
      expect(find.text('Add New Timeline Event'), findsOneWidget);
      expect(find.text('Event Title'), findsOneWidget);
      expect(find.text('Event Description'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);
      // Changed from find.text('Time:') to find.textContaining('Time:')
      // because the actual displayed text includes the formatted time.
      expect(find.textContaining('Time:'), findsOneWidget);
      // Verifies the presence of the dialog's "Add Event" and "Cancel" buttons.
      expect(find.widgetWithText(ElevatedButton, 'Add Event'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    /// Tests that adding a new event through the dialog successfully updates the timeline.
    testWidgets('Adding an event through dialog updates timeline', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Module4TimelineScreen(),
          ),
        ),
      );

      // Open the dialog.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Enter event details into the text fields.
      await tester.enterText(find.widgetWithText(TextField, 'Event Title'), 'My First Event');
      await tester.enterText(find.widgetWithText(TextField, 'Event Description'), 'Details of my first event.');
      await tester.pumpAndSettle(); // Allows text fields to update.

      // Tap the "Add Event" button in the dialog to submit.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Event'));
      await tester.pumpAndSettle(); // Waits for the dialog to close and the timeline to update.

      // Verify that the new event appears on the timeline and the initial message is gone.
      expect(find.textContaining('My First Event'), findsOneWidget);
      expect(find.text('Start your timeline by adding an event!'), findsNothing);
      expect(find.text('Click "Add Event" to update the timeline'), findsOneWidget);
    });

    /// Tests that tapping an event expands and collapses its details.
    testWidgets('Tapping an event expands/collapses it', (WidgetTester tester) async {
      final event = TimelineEvent(id: 1, title: 'Expandable Event', description: 'Long description here.', timestamp: DateTime.now());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            timelineProvider.overrideWith((ref) => TimelineNotifier()..addNewEvent(event)),
          ],
          child: const MaterialApp(
            home: Module4TimelineScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially, the description and action buttons should not be visible.
      expect(find.text('Long description here.'), findsNothing);
      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);

      // Tap the event to expand it.
      await tester.tap(find.textContaining('Expandable Event'));
      await tester.pumpAndSettle();

      // After tapping, the description and buttons should be visible.
      expect(find.text('Long description here.'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);

      // Tap the event again to collapse it.
      await tester.tap(find.textContaining('Expandable Event'));
      await tester.pumpAndSettle();

      // After collapsing, the description and buttons should be hidden again.
      expect(find.text('Long description here.'), findsNothing);
      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);
    });

    /// Tests that long-pressing an event shows a details dialog.
    testWidgets('Long-pressing an event shows details dialog', (WidgetTester tester) async {
      final event = TimelineEvent(id: 1, title: 'Details Event', description: 'Detailed info.', timestamp: DateTime.now());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            timelineProvider.overrideWith((ref) => TimelineNotifier()..addNewEvent(event)),
          ],
          child: const MaterialApp(
            home: Module4TimelineScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Long press the event.
      await tester.longPress(find.textContaining('Details Event'));
      await tester.pumpAndSettle();

      // Verify that the details dialog is open with the correct content.
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Details Event'), findsOneWidget);
      expect(find.text('Detailed info.'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      // Close the dialog.
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    /// Tests that tapping the "Edit" button opens [NewEventDialog] with pre-filled data.
    testWidgets('Tapping "Edit" button opens NewEventDialog with pre-filled data', (WidgetTester tester) async {
      final event = TimelineEvent(id: 1, title: 'Original Title', description: 'Original Description', timestamp: DateTime(2023, 1, 1, 10, 0));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            timelineProvider.overrideWith((ref) => TimelineNotifier()..addNewEvent(event)),
          ],
          child: const MaterialApp(
            home: Module4TimelineScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Expand the event to make the edit button visible.
      await tester.tap(find.textContaining('Original Title'));
      await tester.pumpAndSettle();

      // Tap the "Edit" button. Uses .first to target the correct button.
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      // Verify that the dialog is open in edit mode and its fields are pre-filled.
      expect(find.byType(NewEventDialog), findsOneWidget);
      expect(find.text('Edit Timeline Event'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Original Title'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Original Description'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
    });

    /// Tests that editing an event through the dialog correctly updates the timeline.
    testWidgets('Editing an event updates the timeline', (WidgetTester tester) async {
      final event = TimelineEvent(id: 1, title: 'Old Title', description: 'Old Description', timestamp: DateTime(2023, 1, 1, 10, 0));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            timelineProvider.overrideWith((ref) => TimelineNotifier()..addNewEvent(event)),
          ],
          child: const MaterialApp(
            home: Module4TimelineScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Expand the event and open the edit dialog.
      await tester.tap(find.textContaining('Old Title'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      // Edit the text fields with new values.
      await tester.enterText(find.widgetWithText(TextField, 'Old Title'), 'Updated Title');
      await tester.enterText(find.widgetWithText(TextField, 'Old Description'), 'Updated Description');
      await tester.pumpAndSettle();

      // Tap "Save Changes" to submit the edits.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
      await tester.pumpAndSettle();

      // Verify that the timeline reflects the updated title and the old title is no longer present.
      expect(find.textContaining('Updated Title'), findsOneWidget);
      expect(find.textContaining('Old Title'), findsNothing);
    });

    /// Tests that tapping the "Delete" button shows a confirmation dialog.
    testWidgets('Tapping "Delete" button shows confirmation dialog', (WidgetTester tester) async {
      final event = TimelineEvent(id: 1, title: 'Event to Delete', description: 'Will be deleted.', timestamp: DateTime.now());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            timelineProvider.overrideWith((ref) => TimelineNotifier()..addNewEvent(event)),
          ],
          child: const MaterialApp(
            home: Module4TimelineScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Expand the event to make the delete button visible.
      await tester.tap(find.textContaining('Event to Delete'));
      await tester.pumpAndSettle();

      // Tap the "Delete" button.
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();

      // Verify that the confirmation dialog is displayed with the correct text and buttons.
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Confirm Deletion'), findsOneWidget);
      expect(find.text('Are you sure you want to delete "Event to Delete"?'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Delete'), findsOneWidget);
    });

    /// Tests that confirming deletion removes the event from the timeline.
    testWidgets('Confirming deletion removes the event from timeline', (WidgetTester tester) async {
      final event = TimelineEvent(id: 1, title: 'Event to Be Deleted', description: 'Bye bye.', timestamp: DateTime.now());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            timelineProvider.overrideWith((ref) => TimelineNotifier()..addNewEvent(event)),
          ],
          child: const MaterialApp(
            home: Module4TimelineScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Expand the event and open the delete confirmation dialog.
      await tester.tap(find.textContaining('Event to Be Deleted'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();

      // Confirm the deletion.
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle(); // Waits for the dialog to close and snackbar to appear.

      // Verify that the event is no longer present on the timeline.
      expect(find.text('Event to Be Deleted'), findsNothing);
      // Verify that the initial instructional message reappears.
      expect(find.text('Start your timeline by adding an event!'), findsOneWidget);
      // Verify that a snackbar message confirms the deletion.
      expect(find.text('"Event to Be Deleted" deleted.'), findsOneWidget);
    });
  });

  /// Group of tests specifically for the [NewEventDialog] widget.
  group('NewEventDialog Widget Tests', () {
    /// Tests that [NewEventDialog] renders correctly in "add" mode.
    testWidgets('NewEventDialog renders in add mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => NewEventDialog(maxHeight: MediaQuery.of(context).size.height * 0.8),
            ),
          ),
        ),
      );

      // Verify dialog title and elements specific to add mode.
      expect(find.text('Add New Timeline Event'), findsOneWidget);
      expect(find.text('Event Title'), findsOneWidget);
      expect(find.text('Add Event'), findsOneWidget);
      expect(find.text('Save Changes'), findsNothing); // "Save Changes" should not be present in add mode.
    });

    /// Tests that [NewEventDialog] renders correctly in "edit" mode with initial data.
    testWidgets('NewEventDialog renders in edit mode with initial data', (WidgetTester tester) async {
      final initialEvent = TimelineEvent(id: 1, title: 'Edit Me', description: 'Initial desc', timestamp: DateTime(2023, 5, 10, 15, 30));
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => NewEventDialog(
                initialEvent: initialEvent,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle(); // Allows text fields to populate.

      // Verify dialog title and elements specific to edit mode, including pre-filled data.
      expect(find.text('Edit Timeline Event'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Edit Me'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Initial desc'), findsOneWidget);
      expect(find.widgetWithText(TextField, '2023-05-10'), findsOneWidget); // Checks for the TextField with the formatted date.
      expect(find.textContaining('Time: 3:30 PM'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('Add Event'), findsNothing); // "Add Event" should not be present in edit mode.
    });

    /// Tests that the "Add Event" button is enabled initially even if title/description are empty,
    /// because date and time fields are pre-filled by default.
    testWidgets('NewEventDialog "Add Event" button is enabled initially if fields are empty (due to pre-filled date/time)', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => NewEventDialog(maxHeight: MediaQuery.of(context).size.height * 0.8),
            ),
          ),
        ),
      );

      // Verifies that the "Add Event" button's onPressed callback is not null, meaning it's enabled.
      final addButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Add Event'));
      expect(addButton.onPressed, isNotNull);
    });

    /// Tests that the "Add Event" button remains enabled when only the title field is filled.
    testWidgets('NewEventDialog "Add Event" button remains enabled when title is filled', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => NewEventDialog(maxHeight: MediaQuery.of(context).size.height * 0.8),
            ),
          ),
        ),
      );

      await tester.enterText(find.widgetWithText(TextField, 'Event Title'), 'Test Title');
      await tester.pump(); // Rebuilds the widget tree with the new text.

      // Verifies that the "Add Event" button is still enabled.
      final addButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Add Event'));
      expect(addButton.onPressed, isNotNull);
    });

    /// Tests that tapping the "Cancel" button dismisses the dialog.
    testWidgets('NewEventDialog "Cancel" button dismisses dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => NewEventDialog(maxHeight: MediaQuery.of(context).size.height * 0.8),
            ),
          ),
        ),
      );

      expect(find.byType(NewEventDialog), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle(); // Waits for the dialog to dismiss.

      // Verifies that the NewEventDialog is no longer present.
      expect(find.byType(NewEventDialog), findsNothing);
    });
  });
}
