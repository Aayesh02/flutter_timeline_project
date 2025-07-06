// lib/notifiers/timeline_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/timeline_event.dart'; // Imports the TimelineEvent data model.

/// Represents the state of the timeline, holding a list of events and their expanded status.
class TimelineState {
  /// The list of [TimelineEvent] objects currently in the timeline.
  final List<TimelineEvent> events;

  /// A set of indexes indicating which events are currently expanded in the UI.
  final Set<int> expandedIndexes;

  /// Creates a [TimelineState] with the given events and expanded indexes.
  TimelineState({
    required this.events,
    required this.expandedIndexes,
  });

  /// Creates a copy of this [TimelineState] with updated values.
  ///
  /// If [events] or [expandedIndexes] are null, the existing values are retained.
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

/// A [StateNotifier] that manages the state of the timeline.
///
/// It provides methods to add, edit, delete, and toggle the expansion of timeline events.
class TimelineNotifier extends StateNotifier<TimelineState> {
  /// Initializes the notifier with an empty list of events and no expanded indexes.
  TimelineNotifier()
      : super(TimelineState(events: [], expandedIndexes: {}));

  /// Toggles the expanded state of an event at the given [index].
  ///
  /// If the event is currently expanded, it will be collapsed; otherwise, it will be expanded.
  void toggleExpand(int index) {
    final newExpanded = Set<int>.from(state.expandedIndexes);
    newExpanded.contains(index) ? newExpanded.remove(index) : newExpanded.add(index);
    state = state.copyWith(expandedIndexes: newExpanded);
  }

  /// Adds a [newEvent] to the timeline.
  ///
  /// If the new event does not have an ID, a unique ID is generated.
  /// The list of events is then sorted by their timestamp.
  void addNewEvent(TimelineEvent newEvent) {
    // Generate an ID if the new event's ID is 0 (indicating it's not set).
    final eventWithId = newEvent.id == 0 ? newEvent.copyWith(id: DateTime.now().microsecondsSinceEpoch) : newEvent;
    final newEvents = List<TimelineEvent>.from(state.events)..add(eventWithId);
    newEvents.sort((a, b) => a.timestamp.compareTo(b.timestamp)); // Sorts events chronologically.
    state = state.copyWith(events: newEvents);
  }

  /// Deletes an event at the specified [index] from the timeline.
  ///
  /// Also adjusts the [expandedIndexes] to account for the removed event,
  /// ensuring that expanded events at higher indexes remain correctly tracked.
  void deleteEvent(int index) {
    if (index >= 0 && index < state.events.length) {
      final newEvents = List<TimelineEvent>.from(state.events)..removeAt(index);
      final newExpandedIndexes = Set<int>.from(state.expandedIndexes)
        ..remove(index); // Remove the deleted index if present.

      // Adjust indexes of expanded events that were after the deleted event.
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

  /// Edits an event at the specified [index] with [updatedEvent] data.
  ///
  /// The list of events is re-sorted by timestamp after the edit.
  /// The edited event is automatically expanded after the update.
  void editEvent(int index, TimelineEvent updatedEvent) {
    if (index >= 0 && index < state.events.length) {
      final newEvents = List<TimelineEvent>.from(state.events);
      newEvents[index] = updatedEvent; // Replace the event at the given index.
      newEvents.sort((a, b) => a.timestamp.compareTo(b.timestamp)); // Re-sorts events chronologically.

      // Adjust expanded indexes to ensure the edited item remains expanded
      // even if its position changed due to sorting.
      final newExpandedIndexes = <int>{};
      final newIndex = newEvents.indexOf(updatedEvent); // Find the new index of the updated event.
      if (newIndex != -1) {
        newExpandedIndexes.add(newIndex); // Add the new index to expanded set.
      }
      state = state.copyWith(events: newEvents, expandedIndexes: newExpandedIndexes);
    }
  }
}

/// A [StateNotifierProvider] for [TimelineNotifier].
///
/// This allows widgets to listen to and interact with the timeline state.
final timelineProvider = StateNotifierProvider<TimelineNotifier, TimelineState>((ref) => TimelineNotifier());
