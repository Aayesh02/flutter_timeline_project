import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart'; // Import the Timelines Plus package for visual timeline components

// Main screen for Module 4 that displays a fixed vertical timeline
class Module4TimelineScreen extends StatelessWidget {
  const Module4TimelineScreen({super.key});

  // A constant list of timeline events with title and date
  final List<TimelineEventData> events = const [
    TimelineEventData(title: 'Started Project', date: '2025-06-01'),
    TimelineEventData(title: 'Completed Module 1', date: '2025-06-02'),
    TimelineEventData(title: 'Completed Module 2', date: '2025-06-04'),
    TimelineEventData(title: 'Completed Module 3', date: '2025-06-06'),
    TimelineEventData(title: 'Now on Module 4', date: '2025-06-07'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline (Module 4)'), // App bar title
        backgroundColor: Colors.cyan,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the timeline
        child: FixedTimeline.tileBuilder(
          theme: TimelineThemeData(
            nodePosition: 0, // Position of the timeline node (leftmost)
            color: Colors.blue, // Default timeline color
            indicatorTheme: const IndicatorThemeData(
              position: 0.5, // Center the indicator vertically
              size: 30.0,     // Size of the indicator
            ),
            connectorTheme: const ConnectorThemeData(
              thickness: 3.0,  // Thickness of the line between indicators
              color: Colors.grey, // Color of connector lines
            ),
          ),

          // Build each timeline tile (event)
          builder: TimelineTileBuilder.connected(
            itemCount: events.length, // Number of events to show

            // Display each event's date and title
            contentsBuilder: (_, index) {
              final event = events[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${event.date}: ${event.title}'),
              );
            },

            // Use checkmark for all indicators EXCEPT the last one
            indicatorBuilder: (_, index) {
              final isLast = index == events.length - 1;
              return isLast
                  ? const DotIndicator(color: Colors.blue) // No icon
                  : const DotIndicator(
                      color: Colors.blue,
                      child: Icon(Icons.check, color: Colors.white, size: 16),
                    );
            },

            // Use dashed line only after second to last item
            connectorBuilder: (_, index, __) {
              final isBeforeLast = index == events.length - 2;
              return isBeforeLast
                  ? const DashedLineConnector()
                  : const SolidLineConnector();
            },

            itemExtentBuilder: (_, __) => 80.0, // Control vertical spacing
          ),
        ),
      ),
    );
  }
}

// Data model for a timeline event, containing a title and a date
class TimelineEventData {
  final String title;
  final String date;

  const TimelineEventData({
    required this.title,
    required this.date,
  });
}

