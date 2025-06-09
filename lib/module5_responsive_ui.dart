import 'package:flutter/material.dart';

class ResponsiveHomeScreen extends StatelessWidget {
  const ResponsiveHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Timeline Project'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Using LayoutBuilder constraints to decide layout
          if (constraints.maxWidth > 600) {
            // Tablet/Desktop layout: Two panels side-by-side
            return Row(
              children: const [
                Expanded(
                  child: Center(
                    child: Text(
                      'Left Panel - Timeline List',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                VerticalDivider(),
                Expanded(
                  child: Center(
                    child: Text(
                      'Right Panel - Timeline Details',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Mobile layout: Single column
            return const Center(
              child: Text(
                'Mobile Layout - Timeline Summary',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
        },
      ),
    );
  }
}
