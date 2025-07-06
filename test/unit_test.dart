// test/unit_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timeline_project/models/timeline_event.dart';
import 'package:flutter_timeline_project/notifiers/timeline_notifier.dart';

/// Main function to define and run unit tests.
void main() {
  /// Group of tests for the [TimelineEvent] model.
  group('TimelineEvent', () {
    /// Tests that a [TimelineEvent] can be instantiated with correct property values.
    test('TimelineEvent can be instantiated correctly', () {
      final now = DateTime.now();
      final event = TimelineEvent(
        id: 1,
        title: 'Test Event',
        description: 'This is a test description.',
        timestamp: now,
      );

      // Verify that all properties are set as expected.
      expect(event.id, 1);
      expect(event.title, 'Test Event');
      expect(event.description, 'This is a test description.');
      expect(event.timestamp, now);
    });

    /// Tests that [TimelineEvent] equality works based on the 'id' property.
    ///
    /// Events with the same ID should be considered equal, regardless of other property changes.
    test('TimelineEvent equality works based on ID', () {
      final now = DateTime.now();
      // event1 and event2 have the same ID but different titles/timestamps.
      final event1 = TimelineEvent(id: 1, title: 'A', description: 'Desc', timestamp: now);
      final event2 = TimelineEvent(id: 1, title: 'B', description: 'Another Desc', timestamp: now.add(const Duration(hours: 1)));
      // event3 has a different ID.
      final event3 = TimelineEvent(id: 2, title: 'A', description: 'Desc', timestamp: now);

      // Expect event1 and event2 to be equal due to matching IDs.
      expect(event1, event2);
      // Expect event1 and event3 to be not equal due to different IDs.
      expect(event1 == event3, isFalse);
    });
  });

  /// Group of tests for the [TimelineNotifier] state management logic.
  group('TimelineNotifier', () {
    late ProviderContainer container;
    late TimelineNotifier notifier;

    /// Sets up the test environment before each test in this group.
    setUp(() {
      // Create a new ProviderContainer for each test to ensure test isolation.
      container = ProviderContainer();
      // Read the notifier instance from the container.
      notifier = container.read(timelineProvider.notifier);
    });

    /// Tears down the test environment after each test in this group.
    tearDown(() {
      // Dispose the container to clean up resources and prevent memory leaks.
      container.dispose();
    });

    /// Tests that the initial state of the timeline notifier is empty.
    test('initial state is empty', () {
      expect(notifier.state.events, isEmpty);
      expect(notifier.state.expandedIndexes, isEmpty);
    });

    /// Tests that [addNewEvent] correctly adds a new event to the timeline.
    test('addNewEvent adds a new event', () {
      final event = TimelineEvent(id: 1, title: 'New Event', description: 'Desc', timestamp: DateTime.now());
      notifier.addNewEvent(event);

      // Verify that the event list contains one event and it's the added event.
      expect(notifier.state.events.length, 1);
      expect(notifier.state.events.first, event);
    });

    /// Tests that [editEvent] correctly updates an existing event.
    test('editEvent updates an existing event', () {
      final initialEvent = TimelineEvent(id: 1, title: 'Old Title', description: 'Old Desc', timestamp: DateTime(2023));
      notifier.addNewEvent(initialEvent);

      final updatedEvent = TimelineEvent(id: 1, title: 'New Title', description: 'New Desc', timestamp: DateTime(2024));
      // Edit the event at index 0.
      notifier.editEvent(0, updatedEvent);

      // Verify that the event list still has one event, and its properties are updated.
      expect(notifier.state.events.length, 1);
      expect(notifier.state.events.first.title, 'New Title');
      expect(notifier.state.events.first.description, 'New Desc');
      expect(notifier.state.events.first.timestamp.year, 2024);
    });

    /// Tests that [deleteEvent] correctly removes an event from the timeline.
    test('deleteEvent removes an event', () {
      final event1 = TimelineEvent(id: 1, title: 'Event 1', description: 'Desc1', timestamp: DateTime(2023, 1, 1));
      final event2 = TimelineEvent(id: 2, title: 'Event 2', description: 'Desc2', timestamp: DateTime(2023, 1, 2));
      notifier.addNewEvent(event1);
      notifier.addNewEvent(event2);

      expect(notifier.state.events.length, 2);

      // Delete the event at index 0.
      notifier.deleteEvent(0);

      // Verify that one event is left and it's the correct one.
      expect(notifier.state.events.length, 1);
      expect(notifier.state.events.first, event2);
    });

    /// Tests that [toggleExpand] correctly expands an event.
    test('toggleExpand expands an event', () {
      final event = TimelineEvent(id: 1, title: 'Event', description: 'Desc', timestamp: DateTime.now());
      notifier.addNewEvent(event);

      expect(notifier.state.expandedIndexes, isEmpty);
      // Toggle to expand the event at index 0.
      notifier.toggleExpand(0);
      expect(notifier.state.expandedIndexes, contains(0));
    });

    /// Tests that [toggleExpand] correctly collapses an event.
    test('toggleExpand collapses an event', () {
      final event = TimelineEvent(id: 1, title: 'Event', description: 'Desc', timestamp: DateTime.now());
      notifier.addNewEvent(event);
      notifier.toggleExpand(0); // First, expand the event.

      expect(notifier.state.expandedIndexes, contains(0));
      notifier.toggleExpand(0); // Then, toggle again to collapse.
      expect(notifier.state.expandedIndexes, isEmpty);
    });

    /// Tests that expanded indexes are correctly adjusted when an event is deleted.
    test('expandedIndexes are adjusted correctly after deletion', () {
      final event1 = TimelineEvent(id: 1, title: 'Event 1', description: 'Desc1', timestamp: DateTime(2023, 1, 1));
      final event2 = TimelineEvent(id: 2, title: 'Event 2', description: 'Desc2', timestamp: DateTime(2023, 1, 2));
      final event3 = TimelineEvent(id: 3, title: 'Event 3', description: 'Desc3', timestamp: DateTime(2023, 1, 3));

      // Add events to the timeline.
      notifier.addNewEvent(event1); // index 0
      notifier.addNewEvent(event2); // index 1
      notifier.addNewEvent(event3); // index 2

      // Expand events at index 0 and 2.
      notifier.toggleExpand(0);
      notifier.toggleExpand(2);

      expect(notifier.state.expandedIndexes, containsAll([0, 2]));

      // Delete the event at index 1 (Event 2).
      notifier.deleteEvent(1);

      // Verify that Event 1 (originally at index 0) is still expanded.
      // Verify that Event 3 (originally at index 2) is now at index 1 and still expanded.
      expect(notifier.state.expandedIndexes, containsAll([0, 1]));
      expect(notifier.state.expandedIndexes.length, 2);
    });
  });
}
