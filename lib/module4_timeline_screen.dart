import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';

void main() {
  runApp(MaterialApp(
    home: TimelineScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

// TimelineEvent model
class TimelineEvent {
  final int id;
  final String title;
  final String description;
  final DateTime timestamp;

  TimelineEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
  });
}

// Sample events
final sampleEvents = [
  TimelineEvent(
    id: 1,
    title: "Project Kickoff",
    description: "Initial project setup and team alignment.",
    timestamp: DateTime(2025, 6, 1, 9, 30),
  ),
  TimelineEvent(
    id: 2,
    title: "Module 1 Complete",
    description: "Dart fundamentals completed.",
    timestamp: DateTime(2025, 6, 2, 10, 15),
  ),
  TimelineEvent(
    id: 3,
    title: "Module 2 Complete",
    description: "Flutter UI basics implemented.",
    timestamp: DateTime(2025, 6, 3, 11, 00),
  ),
];

// Timeline UI
class TimelineScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Project Timeline')),
      body: Timeline.tileBuilder(
        theme: TimelineThemeData(
          nodePosition: 0.1,
          connectorTheme: ConnectorThemeData(
            color: Colors.blueAccent,
            thickness: 3.0,
          ),
          indicatorTheme: IndicatorThemeData(
            size: 30.0,
            color: Colors.blue,
          ),
        ),
        builder: TimelineTileBuilder.fromStyle(
          contentsAlign: ContentsAlign.basic,
          itemCount: sampleEvents.length,
          contentsBuilder: (context, index) {
            final event = sampleEvents[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 4,
                child: ListTile(
                  title: Text(event.title),
                  subtitle: Text(event.description),
                  trailing: Text(
                    "${event.timestamp.month}/${event.timestamp.day} ${event.timestamp.hour}:${event.timestamp.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            );
          },
          indicatorBuilder: (_, index) => DotIndicator(
            color: Colors.deepPurple,
            child: Icon(Icons.check, color: Colors.white, size: 16),
          ),
        ),
      ),
    );
  }
}
