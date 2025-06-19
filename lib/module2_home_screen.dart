import 'package:flutter/material.dart';

// A stateless widget representing the home screen for Module 2
class Module2HomeScreen extends StatelessWidget {
  // Constructor with an optional key
  const Module2HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar at the top of the screen with a title
      appBar: AppBar(
        title: const Text('Module 2: Flutter Basics'),
        backgroundColor: Colors.cyan,
      ),

      // Main body of the screen, centered content
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center column vertically
          children: const [
            // Display a welcome message with custom styling
            Text(
              'Welcome to the Responsive Timeline Project',
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
