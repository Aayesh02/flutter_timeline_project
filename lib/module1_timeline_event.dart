class TimelineEvent {
  final int id;
  final String title;
  final String description;
  final DateTime timestamp;

  // Constructor
  TimelineEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
  });

  // Method to display a summary of the event
  String display() {
    return '[$id] $title\n$description\nOccurred on: ${timestamp.toLocal()}';
  }
}
