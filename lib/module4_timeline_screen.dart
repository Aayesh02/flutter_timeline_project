import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';

class Module4TimelineScreen extends StatelessWidget {
  const Module4TimelineScreen({super.key});

  final List<TimelineEventData> events = const [
    TimelineEventData(title: 'Started Project', date: '2024-01-01'),
    TimelineEventData(title: 'Completed Module 1', date: '2024-01-10'),
    TimelineEventData(title: 'Completed Module 2', date: '2024-01-15'),
    TimelineEventData(title: 'Now on Module 4', date: '2024-01-20'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timeline (Module 4)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FixedTimeline.tileBuilder(
          theme: TimelineThemeData(
            nodePosition: 0,
            color: Colors.blue,
            indicatorTheme: const IndicatorThemeData(
              position: 0.5,
              size: 30.0,
            ),
            connectorTheme: const ConnectorThemeData(
              thickness: 3.0,
              color: Colors.grey,
            ),
          ),
          builder: TimelineTileBuilder.connected(
            itemCount: events.length,
            contentsBuilder: (_, index) {
              final event = events[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${event.date}: ${event.title}'),
              );
            },
            indicatorBuilder: (_, index) => const DotIndicator(
              color: Colors.blue,
              child: Icon(Icons.check, color: Colors.white, size: 16),
            ),
            connectorBuilder: (_, index, ___) => const SolidLineConnector(),
          ),
        ),
      ),
    );
  }
}

class TimelineEventData {
  final String title;
  final String date;

  const TimelineEventData({
    required this.title,
    required this.date,
  });
}
