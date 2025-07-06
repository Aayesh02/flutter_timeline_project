// lib/models/timeline_event.dart

class TimelineEvent {
  final int id; // Unique identifier for the event
  final String title; // Title of the event
  final String description; // Detailed description of the event
  final DateTime timestamp; // Date and time when the event occurred

  TimelineEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
  });

  // Method to return a formatted summary of the event
  String display() {
    return '[$id] $title\n$description\nOccurred on: ${timestamp.toLocal()}';
  }

  // A copyWith method for immutability and easier updates (useful with Riverpod)
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