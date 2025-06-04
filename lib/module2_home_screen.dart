import 'package:flutter/material.dart';

void main() {
  runApp(TimelineApp());
}

class TimelineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsive Timeline',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TimelineHomePage(),
    );
  }
}

class TimelineHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timeline Project'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timeline, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Welcome to the Responsive Timeline Project',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
