import 'package:flutter/material.dart';

/// Model class representing a timeline event
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

/// Sample static data for the timeline events
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
  TimelineEvent(
    id: 4,
    title: "Module 3 Complete",
    description: "Riverpod counter implemented.",
    timestamp: DateTime(2025, 6, 4, 8, 0),
  ),
  TimelineEvent(
    id: 5,
    title: "Module 4 Complete",
    description: "Timeline UI implemented.",
    timestamp: DateTime(2025, 6, 5, 10, 10),
  ),
  TimelineEvent(
    id: 6,
    title: "Module 5 Complete",
    description: "Responsive layout implemented.",
    timestamp: DateTime(2025, 6, 6, 6, 45),
  ),
  TimelineEvent(
    id: 7,
    title: "Module 6 Complete",
    description: "Animated implemented.",
    timestamp: DateTime(2025, 6, 7, 4, 0),
  ),
];

/// The main screen that displays the animated timeline
class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

/// State class for TimelineScreen
/// Handles animation controllers and expanded state tracking
class _TimelineScreenState extends State<TimelineScreen> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers; // Controls fade/size animations for each card
  late final List<Animation<double>> _animations;     // Holds the animations derived from controllers
  final Set<int> _expandedEvents = {};               // Tracks which events are expanded

  @override
  void initState() {
    super.initState();

    // Initialize one animation controller per timeline event
    _controllers = List.generate(
      sampleEvents.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    // Create curved animations from the controllers
    _animations = _controllers
        .map((controller) => CurvedAnimation(
              parent: controller,
              curve: Curves.easeInOut,
            ))
        .toList();

    // Stagger the animations so each card fades in one after another
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 300), () {
        if (mounted) _controllers[i].forward(); // Start animation
      });
    }
  }

  @override
  void dispose() {
    // Dispose of all controllers to free resources
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Toggles whether an event card is expanded or collapsed
  void _toggleExpanded(int id) {
    setState(() {
      if (_expandedEvents.contains(id)) {
        _expandedEvents.remove(id); // Collapse
      } else {
        _expandedEvents.add(id); // Expand
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animated Timeline'),
        backgroundColor: Colors.cyan,
      ),

      // Display the timeline events in a scrolling list
      body: ListView.builder(
        itemCount: sampleEvents.length,
        itemBuilder: (context, index) {
          final event = sampleEvents[index];
          final isExpanded = _expandedEvents.contains(event.id);

          return FadeTransition(
            opacity: _animations[index], // Fade animation
            child: SizeTransition(
              sizeFactor: _animations[index], // Grow animation
              axisAlignment: 0.0,
              child: GestureDetector(
                onTap: () => _toggleExpanded(event.id), // Toggle expand/collapse on tap
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event title (always visible)
                        Text(
                          event.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),

                        // Expanded content
                        if (isExpanded) ...[
                          const SizedBox(height: 8),

                          // Event description
                          Text(event.description),

                          const SizedBox(height: 8),

                          // Formatted timestamp
                          Text(
                            "Date: ${event.timestamp.month}/${event.timestamp.day}/${event.timestamp.year} "
                            "${event.timestamp.hour}:${event.timestamp.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),

                          const SizedBox(height: 8),

                          // Info button shows snackbar with event title
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
