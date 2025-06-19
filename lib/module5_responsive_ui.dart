import 'package:flutter/material.dart';

// A stateless widget representing a responsive home screen
class ResponsiveHomeScreen extends StatelessWidget {
  const ResponsiveHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top app bar with a title
      appBar: AppBar(
        title: const Text('Responsive Timeline Project'),
        backgroundColor: Colors.cyan,
      ),

      // Body uses LayoutBuilder to create responsive layouts
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Use the available width to decide which layout to display
          if (constraints.maxWidth > 600) {
            // If the width is more than 600 pixels, show tablet/desktop layout
            // Two panels side-by-side using Row and Expanded
            return Row(
              children: const [
                Expanded(
                  child: Center(
                    child: Text(
                      'Left Panel - Timeline List', // Placeholder for timeline list
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                VerticalDivider(), // Divider between the two panels
                Expanded(
                  child: Center(
                    child: Text(
                      'Right Panel - Timeline Details', // Placeholder for details view
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // If the width is 600 pixels or less, use mobile layout
            // Show a single column with summary text
            return const Center(
              child: Text(
                'Mobile Layout - Timeline Summary', // Placeholder for mobile summary
                style: TextStyle(fontSize: 18),
              ),
            );
          }
        },
      ),
    );
  }
}
