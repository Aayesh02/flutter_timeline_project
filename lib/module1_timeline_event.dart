// Define a class to represent a timeline event
class TimelineEvent {
  // Unique identifier for the event
  final int id;

  // Title of the event
  final String title;

  // Detailed description of the event
  final String description;

  // Date and time when the event occurred
  final DateTime timestamp;

  // Constructor for initializing a TimelineEvent object
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
}
