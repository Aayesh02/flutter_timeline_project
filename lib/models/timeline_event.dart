// lib/models/timeline_event.dart

import 'package:flutter/material.dart'; // Required for IconData

/// Enum to define custom icons for timeline events.
enum CustomEventIcon {
  none,
  checkmark,
  warning,
  info,
  bell,
  minus,
}

/// Represents a single event in the timeline.
///
/// This class is immutable, and its instances are considered equal if their [id]s match.
@immutable
class TimelineEvent {
  final int id;
  final String title;
  final String description;
  final DateTime timestamp;
  final CustomEventIcon customIcon;

  /// Constructor for [TimelineEvent].
  const TimelineEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    this.customIcon = CustomEventIcon.none, // Default icon
  });

  /// Creates a new [TimelineEvent] instance with updated properties.
  ///
  /// If a parameter is not provided, the corresponding property from the original
  /// instance is used.
  TimelineEvent copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? timestamp,
    CustomEventIcon? customIcon,
  }) {
    return TimelineEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      customIcon: customIcon ?? this.customIcon,
    );
  }

  /// Overrides the equality operator to compare [TimelineEvent] instances based on their [id].
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TimelineEvent &&
        other.id == id; // Events are equal if their IDs match
  }

  /// Overrides the hashCode getter to be consistent with the overridden `==` operator.
  @override
  int get hashCode => id.hashCode;

  /// Provides a string representation of the [TimelineEvent] for debugging purposes.
  @override
  String toString() {
    return 'TimelineEvent(id: $id, title: $title, timestamp: $timestamp, icon: ${customIcon.name})';
  }
}
