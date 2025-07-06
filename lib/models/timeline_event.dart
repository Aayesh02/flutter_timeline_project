// lib/models/timeline_event.dart

import 'package:flutter/foundation.dart'; // Provides utilities like @immutable annotation.

/// Represents a single event in the timeline.
///
/// This class is immutable, meaning its properties cannot be changed after it's created.
@immutable
class TimelineEvent {
  /// A unique identifier for the timeline event.
  final int id;

  /// The title or name of the event.
  final String title;

  /// A detailed description of the event.
  final String description;

  /// The date and time when the event occurred.
  final DateTime timestamp;

  /// Creates a [TimelineEvent] with the specified properties.
  const TimelineEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
  });

  /// Overrides the equality operator to compare [TimelineEvent] objects by their [id].
  ///
  /// Two [TimelineEvent] objects are considered equal if they have the same [id].
  @override
  bool operator ==(Object other) {
    // Check if the objects are the same instance.
    if (identical(this, other)) return true;
    // Check if 'other' is a TimelineEvent and compare based on the 'id' property.
    return other is TimelineEvent && id == other.id;
  }

  /// Overrides the [hashCode] to be consistent with the overridden [==] operator.
  ///
  /// Objects that are equal must have the same hash code.
  @override
  int get hashCode => id.hashCode;

  /// Creates a new [TimelineEvent] instance with updated properties.
  ///
  /// If a parameter is not provided (is null), its value is copied from the current instance.
  TimelineEvent copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? timestamp,
  }) {
    return TimelineEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}