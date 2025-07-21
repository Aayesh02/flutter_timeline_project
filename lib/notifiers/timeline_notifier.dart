// lib/notifiers/timeline_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/timeline_event.dart'; // Imports TimelineEvent and CustomEventIcon

/// Represents the state of the timeline, holding a list of events and their expanded status.
class TimelineState {
  /// The list of TimelineEvent objects currently in the timeline.
  final List<TimelineEvent> events;

  /// A set of indexes indicating which events are currently expanded in the UI.
  final Set<int> expandedIndexes;

  /// Creates a TimelineState with the given events and expanded indexes.
  TimelineState({
    required this.events,
    required this.expandedIndexes,
  });

  /// Creates a copy of this TimelineState with updated values.
  TimelineState copyWith({
    List<TimelineEvent>? events,
    Set<int>? expandedIndexes,
  }) {
    return TimelineState(
      events: events ?? this.events,
      expandedIndexes: expandedIndexes ?? this.expandedIndexes,
    );
  }
}

/// A StateNotifier that manages the state of the timeline.
class TimelineNotifier extends StateNotifier<TimelineState> {
  /// Initializes the notifier with an empty list of events and no expanded indexes.
  TimelineNotifier() : super(TimelineState(events: [], expandedIndexes: {}));

  /// Toggles the expanded state of an event at the given index.
  void toggleExpand(int index) {
    final newExpanded = Set<int>.from(state.expandedIndexes);
    if (newExpanded.contains(index)) {
      newExpanded.remove(index);
    } else {
      newExpanded.add(index);
    }
    state = state.copyWith(expandedIndexes: newExpanded);
  }

  /// Adds a new event to the timeline.
  /// The list of events is then sorted by their timestamp in DESCENDING order (newest first).
  /// Expanded indexes are cleared as sorting changes positions.
  void addNewEvent(TimelineEvent newEvent) {
    final eventWithId = newEvent.id == 0 // Assuming 0 is a placeholder for new event IDs
        ? newEvent.copyWith(id: DateTime.now().microsecondsSinceEpoch)
        : newEvent;
    final newEvents = List<TimelineEvent>.from(state.events)..add(eventWithId);
    newEvents.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // DESCENDING ORDER (newest first)
    state = state.copyWith(events: newEvents, expandedIndexes: {});
  }

  /// Deletes an event at the specified index from the timeline.
  void deleteEvent(int index) {
    if (index >= 0 && index < state.events.length) {
      final newEvents = List<TimelineEvent>.from(state.events)..removeAt(index);
      final newExpandedIndexes = Set<int>.from(state.expandedIndexes)..remove(index);

      final adjustedExpandedIndexes = <int>{};
      for (var expIndex in newExpandedIndexes) {
        if (expIndex > index) {
          adjustedExpandedIndexes.add(expIndex - 1);
        } else {
          adjustedExpandedIndexes.add(expIndex);
        }
      }
      state = state.copyWith(events: newEvents, expandedIndexes: adjustedExpandedIndexes);
    }
  }

  /// Edits an event at the specified index with updated event data.
  void editEvent(int index, TimelineEvent updatedEvent) {
    if (index >= 0 && index < state.events.length) {
      final newEvents = List<TimelineEvent>.from(state.events);
      newEvents[index] = updatedEvent;
      newEvents.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // DESCENDING ORDER (newest first)

      final newExpandedIndexes = <int>{};
      final newIndex = newEvents.indexOf(updatedEvent);
      if (newIndex != -1) {
        newExpandedIndexes.add(newIndex);
      }
      state = state.copyWith(events: newEvents, expandedIndexes: newExpandedIndexes);
    }
  }

  /// Adds a timeline event to reflect frequency changes (increase or decrease).
  void addFrequencyChangeEvent({
    required String type,
    required int value,
    required bool increased,
    DateTime? timestamp, // Added optional timestamp parameter for testing
  }) {
    final now = timestamp ?? DateTime.now(); // Use provided timestamp or current time

    final title = 'Frequency ${increased ? "Increased" : "Decreased"}';
    final description = '$type changed to $value';

    final newEvent = TimelineEvent(
      id: now.microsecondsSinceEpoch, // Generates int ID
      title: title,
      description: description,
      timestamp: now,
      customIcon: increased ? CustomEventIcon.checkmark : CustomEventIcon.minus,
    );

    // Add new event at the top of the list (not sorted here, but addNewEvent will sort)
    // It's better to use addNewEvent for consistency in sorting.
    addNewEvent(newEvent); // Call addNewEvent to ensure sorting
  }
}

/// A StateNotifierProvider for TimelineNotifier.
final timelineProvider =
    StateNotifierProvider<TimelineNotifier, TimelineState>((ref) => TimelineNotifier());
