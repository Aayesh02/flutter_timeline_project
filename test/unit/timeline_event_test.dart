import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timeline_project/module1_timeline_event.dart'; // Import the model to test

/// Entry point for the test suite for TimelineEvent
void main() {
  // Grouping related tests together for better organization and readability
  group('TimelineEvent', () {
    
    /// Test that a TimelineEvent is correctly instantiated and its display output is valid
    test('should correctly instantiate and return display text', () {
      // Create a sample event
      final event = TimelineEvent(
        id: 1,
        title: 'Project Started',
        description: 'Initial project planning and setup',
        timestamp: DateTime(2024, 1, 15, 10, 30),
      );

      // Verify each property was assigned correctly
      expect(event.id, 1);
      expect(event.title, 'Project Started');
      expect(event.description, 'Initial project planning and setup');

      // Check the formatted display output of the event
      final display = event.display();
      expect(display.contains('[1] Project Started'), isTrue); // ID and title format
      expect(display.contains('Initial project planning and setup'), isTrue); // Description included
      expect(display.contains('Occurred on:'), isTrue); // Date formatting prefix present
    });

    /// Test the display() method for an event with a future timestamp
    test('display() handles future timestamp', () {
      // Create a future event dated 30 days from now
      final futureEvent = TimelineEvent(
        id: 2,
        title: 'Future Event',
        description: 'Something upcoming',
        timestamp: DateTime.now().add(Duration(days: 30)),
      );

      // Call display() and validate that the title appears correctly
      final display = futureEvent.display();
      expect(display.contains('Future Event'), isTrue);
    });
  });
}
