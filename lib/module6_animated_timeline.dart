import 'package:flutter/material.dart';

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
    timestamp: DateTime(2025, 6, 3, 11, 0),
  ),
];

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  final Set<int> _expandedEvents = {};

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      sampleEvents.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    _animations = _controllers
        .map((controller) => CurvedAnimation(
              parent: controller,
              curve: Curves.easeInOut,
            ))
        .toList();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 300), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleExpanded(int id) {
    setState(() {
      if (_expandedEvents.contains(id)) {
        _expandedEvents.remove(id);
      } else {
        _expandedEvents.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animated Timeline')),
      body: ListView.builder(
        itemCount: sampleEvents.length,
        itemBuilder: (context, index) {
          final event = sampleEvents[index];
          final isExpanded = _expandedEvents.contains(event.id);

          return FadeTransition(
            opacity: _animations[index],
            child: SizeTransition(
              sizeFactor: _animations[index],
              axisAlignment: 0.0,
              child: GestureDetector(
                onTap: () => _toggleExpanded(event.id),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (isExpanded) ...[
                          const SizedBox(height: 8),
                          Text(event.description),
                          const SizedBox(height: 8),
                          Text(
                            "Date: ${event.timestamp.month}/${event.timestamp.day}/${event.timestamp.year} ${event.timestamp.hour}:${event.timestamp.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Details for "${event.title}" tapped!')),
                              );
                            },
                            child: const Text('More Info'),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

