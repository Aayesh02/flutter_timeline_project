class TimelineEvent {
  // Fields
  int id;
  String title;
  String description;
  DateTime timestamp;

  // Constructor
  TimelineEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
  });

  // Method to display event summary
  String display() {
    return 'Event: $title\nDescription: $description\nDate: ${timestamp.toLocal()}';
  }
}

// Example usage
void main() {
  // Creating a sample event
  TimelineEvent event = TimelineEvent(
    id: 1,
    title: 'Module 1 Completed',
    description: 'Finished the Dart fundamentals module.',
    timestamp: DateTime.now(),
  );

  // Displaying the event summary
  print(event.display());
}
