// test/unit_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timeline_project/models/timeline_event.dart';
import 'package:flutter_timeline_project/notifiers/timeline_notifier.dart';

/// The main function for organizing and running our unit tests.
void main() {
  /// A collection of tests specifically for the [TimelineEvent] data model.
  group('TimelineEvent', () {
    /// Verifies that a [TimelineEvent] object can be created successfully
    /// and that all its properties are correctly assigned during instantiation.
    test('TimelineEvent can be instantiated correctly', () {
      final now = DateTime.now();
      final event = TimelineEvent(
        id: 1,
        title: 'Test Event',
        description: 'This is a test description.',
        timestamp: now,
        customIcon: CustomEventIcon.checkmark,
      );

      // Assert that each property holds the expected value.
      expect(event.id, 1);
      expect(event.title, 'Test Event');
      expect(event.description, 'This is a test description.');
      expect(event.timestamp, now);
      expect(event.customIcon, CustomEventIcon.checkmark);
    });

    /// Checks that the equality operator (`==`) for [TimelineEvent] works as intended,
    /// primarily comparing events based on their unique `id`.
    ///
    /// Two events with the same ID should be considered equal, regardless of other data.
    test('TimelineEvent equality works based on ID', () {
      final now = DateTime.now();
      // Create two events with the same ID but different titles and timestamps.
      final event1 = TimelineEvent(id: 1, title: 'A', description: 'Desc', timestamp: now);
      final event2 = TimelineEvent(id: 1, title: 'B', description: 'Another Desc', timestamp: now.add(const Duration(hours: 1)));
      // Create a third event with a different ID.
      final event3 = TimelineEvent(id: 2, title: 'A', description: 'Desc', timestamp: now);

      // Expect `event1` and `event2` to be equal because their IDs match.
      expect(event1, event2);
      // Expect `event1` and `event3` to be unequal because their IDs differ.
      expect(event1 == event3, isFalse);
    });

    /// Tests the `copyWith` method to ensure it creates a new instance of
    /// [TimelineEvent] with specified properties updated, while retaining
    /// unchanged properties from the original.
    test('copyWith creates a new instance with updated values', () {
      final originalEvent = TimelineEvent(
        id: 1,
        title: 'Original Title',
        description: 'Original Description',
        timestamp: DateTime(2023, 1, 1),
        customIcon: CustomEventIcon.info,
      );

      // Create a new event by copying the original and changing the title and icon.
      final updatedEvent = originalEvent.copyWith(
        title: 'New Title',
        customIcon: CustomEventIcon.checkmark,
      );

      // Verify that `updatedEvent` is a distinct instance from `originalEvent`.
      expect(originalEvent, isNot(same(updatedEvent)));

      // Confirm that the specified properties were indeed updated.
      expect(updatedEvent.title, 'New Title');
      expect(updatedEvent.customIcon, CustomEventIcon.checkmark);

      // Confirm that properties not specified in `copyWith` remain the same as the original.
      expect(updatedEvent.id, originalEvent.id);
      expect(updatedEvent.description, originalEvent.description);
      expect(updatedEvent.timestamp, originalEvent.timestamp);
    });
  });

  /// A collection of tests for the [TimelineNotifier], which manages the
  /// state of our timeline events using Riverpod.
  group('TimelineNotifier', () {
    late ProviderContainer container; // Manages the Riverpod providers for testing.
    late TimelineNotifier notifier; // The instance of our state notifier.

    /// This setup function runs before each test within this group.
    /// It ensures a clean and isolated testing environment for each test case.
    setUp(() {
      // Create a fresh `ProviderContainer` to avoid state leakage between tests.
      container = ProviderContainer();
      // Obtain the `TimelineNotifier` instance from the container.
      notifier = container.read(timelineProvider.notifier);
    });

    /// This teardown function runs after each test within this group.
    /// It disposes of the `ProviderContainer` to free up resources.
    tearDown(() {
      container.dispose();
    });

    /// Verifies that the timeline notifier starts with an empty state,
    /// meaning no events and no expanded indexes initially.
    test('initial state is empty', () {
      expect(notifier.state.events, isEmpty);
      expect(notifier.state.expandedIndexes, isEmpty);
    });

    /// Tests that `addNewEvent` correctly adds a new event to the timeline
    /// and ensures the events are sorted by their timestamp in descending order
    /// (newest events first).
    test('addNewEvent adds a new event and sorts by timestamp', () {
      final event1 = TimelineEvent(id: 1, title: 'Event 1', description: 'Desc1', timestamp: DateTime(2023, 1, 3));
      final event2 = TimelineEvent(id: 2, title: 'Event 2', description: 'Desc2', timestamp: DateTime(2023, 1, 1));
      final event3 = TimelineEvent(id: 3, title: 'Event 3', description: 'Desc3', timestamp: DateTime(2023, 1, 2));

      // Add events in a mixed order to test the sorting logic.
      notifier.addNewEvent(event1);
      notifier.addNewEvent(event2);
      notifier.addNewEvent(event3);

      // Verify that all three events are present.
      expect(notifier.state.events.length, 3);
      // Assert that the events are now sorted by timestamp in descending order.
      expect(notifier.state.events[0].id, event1.id); // Event 1 (Jan 3) should be first (newest).
      expect(notifier.state.events[1].id, event3.id); // Event 3 (Jan 2) should be second.
      expect(notifier.state.events[2].id, event2.id); // Event 2 (Jan 1) should be last (oldest).
      // Confirm that no events are expanded by default after adding.
      expect(notifier.state.expandedIndexes, isEmpty);
    });

    /// Tests that `editEvent` successfully updates an existing event's details
    /// and ensures that the timeline remains correctly sorted after the edit,
    /// especially if the timestamp changes.
    test('editEvent updates an existing event and re-sorts', () {
      final initialEvent1 = TimelineEvent(id: 1, title: 'Event A', description: 'DescA', timestamp: DateTime(2023, 1, 1));
      final initialEvent2 = TimelineEvent(id: 2, title: 'Event B', description: 'DescB', timestamp: DateTime(2023, 1, 10));
      notifier.addNewEvent(initialEvent1);
      notifier.addNewEvent(initialEvent2);
      // After initial additions and sorting (descending): [initialEvent2 (Jan 10), initialEvent1 (Jan 1)]
      expect(notifier.state.events.map((e) => e.title), ['Event B', 'Event A']);

      // Create an updated version of `initialEvent1` with a later timestamp.
      final updatedEvent1 = initialEvent1.copyWith(title: 'Updated A', timestamp: DateTime(2023, 1, 15));
      // Find the current index of `initialEvent1` before we edit it.
      final int initialEvent1Index = notifier.state.events.indexOf(initialEvent1);
      // Perform the edit operation.
      notifier.editEvent(initialEvent1Index, updatedEvent1);

      // Verify that the event list is re-sorted correctly.
      expect(notifier.state.events.length, 2);
      expect(notifier.state.events[0].title, 'Updated A'); // 'Updated A' (Jan 15) should now be first.
      expect(notifier.state.events[1].title, 'Event B'); // 'Event B' (Jan 10) should now be second.
      // The updated event should also be expanded at its new position (index 0).
      expect(notifier.state.expandedIndexes, contains(0));
    });

    /// Tests that `deleteEvent` correctly removes an event from the timeline
    /// and that any expanded indexes are adjusted appropriately to reflect
    /// the new positions of the remaining events.
    test('deleteEvent removes an event and adjusts expandedIndexes', () {
      final event1 = TimelineEvent(id: 1, title: 'Event 1', description: 'Desc1', timestamp: DateTime(2023, 1, 1));
      final event2 = TimelineEvent(id: 2, title: 'Event 2', description: 'Desc2', timestamp: DateTime(2023, 1, 2));
      final event3 = TimelineEvent(id: 3, title: 'Event 3', description: 'Desc3', timestamp: DateTime(2023, 1, 3));

      // Add events, which will be sorted descending: [event3 (idx 0), event2 (idx 1), event1 (idx 2)]
      notifier.addNewEvent(event1);
      notifier.addNewEvent(event2);
      notifier.addNewEvent(event3);

      // Expand two events to test index adjustment after deletion.
      notifier.toggleExpand(0); // Expand Event 3 (at current index 0).
      notifier.toggleExpand(2); // Expand Event 1 (at current index 2).
      expect(notifier.state.expandedIndexes, containsAll([0, 2]));

      // Delete `event2`, which is currently at index 1.
      notifier.deleteEvent(1);

      // After deletion, the event list should contain `event3` and `event1`.
      expect(notifier.state.events.length, 2);
      expect(notifier.state.events[0].id, event3.id); // `event3` remains at index 0.
      expect(notifier.state.events[1].id, event1.id); // `event1` shifts from index 2 to index 1.
      // Verify that the expanded indexes have been correctly adjusted.
      expect(notifier.state.expandedIndexes, containsAll([0, 1]));
      expect(notifier.state.expandedIndexes.length, 2);
    });

    /// Tests that `toggleExpand` correctly changes the expanded state of an event,
    /// adding its index to `expandedIndexes` when expanding and removing it when collapsing.
    test('toggleExpand expands and collapses an event', () {
      final event = TimelineEvent(id: 1, title: 'Event', description: 'Desc', timestamp: DateTime.now());
      notifier.addNewEvent(event);

      // Initially, no events should be expanded.
      expect(notifier.state.expandedIndexes, isEmpty);
      notifier.toggleExpand(0); // Call to expand the event at index 0.
      expect(notifier.state.expandedIndexes, contains(0)); // Verify it's now expanded.
      notifier.toggleExpand(0); // Call again to collapse the event.
      expect(notifier.state.expandedIndexes, isEmpty); // Verify it's no longer expanded.
    });

    /// Tests that `addFrequencyChangeEvent` correctly creates and adds a new
    /// timeline event specifically for tracking changes in intervention frequencies.
    /// It also verifies the event's properties and its position in the sorted timeline.
    test('addFrequencyChangeEvent adds a frequency change event', () {
      // Add an older frequency change event.
      final olderTimestamp = DateTime.now().subtract(const Duration(seconds: 1));
      notifier.addFrequencyChangeEvent(
        type: 'Meeting Frequency',
        value: 5,
        increased: true,
        timestamp: olderTimestamp, // Explicitly provide an older timestamp.
      );

      // Verify the first event added.
      expect(notifier.state.events.length, 1);
      final event1 = notifier.state.events.first;
      expect(event1.title, 'Frequency Increased');
      expect(event1.description, 'Meeting Frequency changed to 5');
      expect(event1.customIcon, CustomEventIcon.checkmark);
      expect(event1.timestamp, olderTimestamp);

      // Add a newer frequency change event.
      final newerTimestamp = DateTime.now();
      notifier.addFrequencyChangeEvent(
        type: 'Reward Frequency',
        value: 2,
        increased: false,
        timestamp: newerTimestamp, // Explicitly provide a newer timestamp.
      );

      // Verify that two events are now present.
      expect(notifier.state.events.length, 2);
      // Since events are sorted in descending order by timestamp, the newest event
      // (Reward Frequency change) should be at index 0.
      final newestEvent = notifier.state.events.first;

      expect(newestEvent.title, 'Frequency Decreased');
      expect(newestEvent.description, 'Reward Frequency changed to 2');
      expect(newestEvent.customIcon, CustomEventIcon.minus);
      expect(newestEvent.timestamp, newerTimestamp);

      // Finally, confirm the overall order of events in the timeline.
      expect(notifier.state.events[0].title, 'Frequency Decreased'); // Newest event.
      expect(notifier.state.events[1].title, 'Frequency Increased'); // Older event.
    });
  });
}
