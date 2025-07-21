// test/timeline_widget_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timeline_project/models/timeline_event.dart';
import 'package:flutter_timeline_project/notifiers/timeline_notifier.dart';

/// Main function to define and run unit tests.
void main() {
  /// Group of tests for the [TimelineEvent] model.
  group('TimelineEvent', () {
    /// Test that a TimelineEvent instance can be created correctly with expected values.
    test('TimelineEvent can be instantiated correctly', () {
      final now = DateTime.now();
      final event = TimelineEvent(
        id: 1,
        title: 'Test Event',
        description: 'This is a test description.',
        timestamp: now,
        customIcon: CustomEventIcon.checkmark,
      );

      // Assert all properties have expected values
      expect(event.id, 1);
      expect(event.title, 'Test Event');
      expect(event.description, 'This is a test description.');
      expect(event.timestamp, now);
      expect(event.customIcon, CustomEventIcon.checkmark);
    });

    /// Test that TimelineEvent equality is based on the ID field.
    test('TimelineEvent equality works based on ID', () {
      final now = DateTime.now();
      final event1 = TimelineEvent(id: 1, title: 'A', description: 'Desc', timestamp: now);
      final event2 = TimelineEvent(id: 1, title: 'B', description: 'Another Desc', timestamp: now.add(const Duration(hours: 1)));
      final event3 = TimelineEvent(id: 2, title: 'A', description: 'Desc', timestamp: now);

      // event1 and event2 have same ID, so they are equal
      expect(event1, event2);
      // event1 and event3 have different IDs, so they are not equal
      expect(event1 == event3, isFalse);
    });

    /// Test the copyWith method creates a new instance with updated fields, preserving others.
    test('copyWith creates a new instance with updated values', () {
      final originalEvent = TimelineEvent(
        id: 1,
        title: 'Original Title',
        description: 'Original Description',
        timestamp: DateTime(2023, 1, 1),
        customIcon: CustomEventIcon.info,
      );

      // Create an updated copy with changed title and customIcon
      final updatedEvent = originalEvent.copyWith(
        title: 'New Title',
        customIcon: CustomEventIcon.checkmark,
      );

      // Verify a new instance was created (not the same object)
      expect(originalEvent, isNot(same(updatedEvent)));
      // Verify updated fields are changed
      expect(updatedEvent.title, 'New Title');
      expect(updatedEvent.customIcon, CustomEventIcon.checkmark);
      // Verify other fields remain unchanged
      expect(updatedEvent.id, originalEvent.id);
      expect(updatedEvent.description, originalEvent.description);
      expect(updatedEvent.timestamp, originalEvent.timestamp);
    });
  });

  /// Group of tests for the [TimelineNotifier] state management.
  group('TimelineNotifier', () {
    late ProviderContainer container;
    late TimelineNotifier notifier;

    /// Setup a fresh provider container and notifier before each test.
    setUp(() {
      container = ProviderContainer();
      notifier = container.read(timelineProvider.notifier);
    });

    /// Dispose the container after each test.
    tearDown(() {
      container.dispose();
    });

    /// Verify that the initial state has an empty event list and no expanded items.
    test('initial state is empty', () {
      expect(notifier.state.events, isEmpty);
      expect(notifier.state.expandedIndexes, isEmpty);
    });

    /// Test that addNewEvent inserts events and sorts them by timestamp descending.
    test('addNewEvent adds a new event and sorts by timestamp', () {
      final event1 = TimelineEvent(id: 1, title: 'Event 1', description: 'Desc1', timestamp: DateTime(2023, 1, 3));
      final event2 = TimelineEvent(id: 2, title: 'Event 2', description: 'Desc2', timestamp: DateTime(2023, 1, 1));
      final event3 = TimelineEvent(id: 3, title: 'Event 3', description: 'Desc3', timestamp: DateTime(2023, 1, 2));

      // Add events in arbitrary order
      notifier.addNewEvent(event1);
      notifier.addNewEvent(event2);
      notifier.addNewEvent(event3);

      // After adding, events should be sorted descending by timestamp
      expect(notifier.state.events.length, 3);
      expect(notifier.state.events[0].id, event1.id);
      expect(notifier.state.events[1].id, event3.id);
      expect(notifier.state.events[2].id, event2.id);
      // No events expanded initially
      expect(notifier.state.expandedIndexes, isEmpty);
    });

    /// Test editing an event updates it correctly and re-sorts the list.
    test('editEvent updates an existing event and re-sorts', () {
      final initialEvent1 = TimelineEvent(id: 1, title: 'Event A', description: 'DescA', timestamp: DateTime(2023, 1, 1));
      final initialEvent2 = TimelineEvent(id: 2, title: 'Event B', description: 'DescB', timestamp: DateTime(2023, 1, 10));
      notifier.addNewEvent(initialEvent1);
      notifier.addNewEvent(initialEvent2);

      // Initially, events sorted by timestamp descending
      expect(notifier.state.events.map((e) => e.title), ['Event B', 'Event A']);

      // Create updated event with new title and later timestamp
      final updatedEvent1 = initialEvent1.copyWith(title: 'Updated A', timestamp: DateTime(2023, 1, 15));
      final int initialEvent1Index = notifier.state.events.indexOf(initialEvent1);
      notifier.editEvent(initialEvent1Index, updatedEvent1);

      // After edit, event list is re-sorted with updated event first
      expect(notifier.state.events.length, 2);
      expect(notifier.state.events[0].title, 'Updated A');
      expect(notifier.state.events[1].title, 'Event B');
      // The updated event index should be expanded
      expect(notifier.state.expandedIndexes, contains(0));
    });

    /// Test deleting an event removes it and updates expanded indexes accordingly.
    test('deleteEvent removes an event and adjusts expandedIndexes', () {
      final event1 = TimelineEvent(id: 1, title: 'Event 1', description: 'Desc1', timestamp: DateTime(2023, 1, 1));
      final event2 = TimelineEvent(id: 2, title: 'Event 2', description: 'Desc2', timestamp: DateTime(2023, 1, 2));
      final event3 = TimelineEvent(id: 3, title: 'Event 3', description: 'Desc3', timestamp: DateTime(2023, 1, 3));

      notifier.addNewEvent(event1);
      notifier.addNewEvent(event2);
      notifier.addNewEvent(event3);

      // Expand first and last events
      notifier.toggleExpand(0);
      notifier.toggleExpand(2);
      expect(notifier.state.expandedIndexes, containsAll([0, 2]));

      // Delete the event at index 1 (middle one)
      notifier.deleteEvent(1);

      // Expect only two events remain, sorted by timestamp descending
      expect(notifier.state.events.length, 2);
      expect(notifier.state.events[0].id, event3.id);
      expect(notifier.state.events[1].id, event1.id);
      // Expanded indexes updated: previous index 2 moves down to 1
      expect(notifier.state.expandedIndexes, containsAll([0, 1]));
      expect(notifier.state.expandedIndexes.length, 2);
    });

    /// Test toggling expansion of events (expand then collapse).
    test('toggleExpand expands and collapses an event', () {
      final event = TimelineEvent(id: 1, title: 'Event', description: 'Desc', timestamp: DateTime.now());
      notifier.addNewEvent(event);

      // Initially no expanded events
      expect(notifier.state.expandedIndexes, isEmpty);

      // Toggle expand index 0
      notifier.toggleExpand(0);
      expect(notifier.state.expandedIndexes, contains(0));

      // Toggle collapse index 0
      notifier.toggleExpand(0);
      expect(notifier.state.expandedIndexes, isEmpty);
    });

    /// Test that addFrequencyChangeEvent adds events with correct titles, descriptions, and icons.
    test('addFrequencyChangeEvent adds a frequency change event', () {
      final now = DateTime(2025, 1, 1, 12, 0, 0);

      notifier.addFrequencyChangeEvent(
        type: 'Meeting Frequency',
        value: 5,
        increased: true,
        timestamp: now,
      );

      notifier.addFrequencyChangeEvent(
        type: 'Reward Frequency',
        value: 2,
        increased: false,
        timestamp: now.add(const Duration(seconds: 1)),
      );

      expect(notifier.state.events.length, 2);

      final firstEvent = notifier.state.events[0];
      // Since events are sorted descending, the decreased event is first
      expect(firstEvent.title, 'Frequency Decreased');
      expect(firstEvent.description, 'Reward Frequency changed to 2');
      expect(firstEvent.customIcon, CustomEventIcon.minus);

      final secondEvent = notifier.state.events[1];
      expect(secondEvent.title, 'Frequency Increased');
      expect(secondEvent.description, 'Meeting Frequency changed to 5');
      expect(secondEvent.customIcon, CustomEventIcon.checkmark);
    });
  });
}
