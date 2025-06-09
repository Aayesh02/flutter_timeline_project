import 'package:flutter/material.dart';
import 'module6_animated_timeline.dart'; // import your module 6 timeline screen here

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animated Timeline Project',
      debugShowCheckedModeBanner: false,
      home: TimelineScreen(), // from module6_animated_timeline.dart
    );
  }
}


