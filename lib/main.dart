import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Module screen imports
import 'module2_home_screen.dart';
import 'module3_counter_riverpod.dart';
import 'module4_timeline_screen.dart';
import 'module5_responsive_ui.dart';
import 'module6_animated_timeline.dart';

/// The entry point of the app.
/// ProviderScope is required to use Riverpod throughout the app.
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

/// Root widget of the app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Timeline Project', // App title shown in app switcher, etc.
      debugShowCheckedModeBanner: false, // Removes the debug banner in the corner
      initialRoute: '/', // The default route when app launches
      routes: {
        '/': (context) => const AppHomeScreen(),             // Home screen with module buttons
        '/module2': (context) => const Module2HomeScreen(),  // Module 2: Flutter basics
        '/module3': (context) => const CounterHomeScreen(),  // Module 3: Riverpod counter
        '/module4': (context) => const Module4TimelineScreen(), // Module 4: Timeline UI
        '/module5': (context) => const ResponsiveHomeScreen(), // Module 5: Responsive layout
        '/module6': (context) => TimelineScreen(),              // Module 6: Animated timeline
      },
    );
  }
}

/// Home screen that lists buttons to navigate to each module
class AppHomeScreen extends StatelessWidget {
  const AppHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Training Modules'), // App bar title
        backgroundColor: Colors.cyan, // App bar background color
      ),
      body: ListView(
        padding: const EdgeInsets.all(16), // Adds padding around the list
        children: [
          // Each button navigates to its corresponding module screen
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/module2'),
            child: const Text('Module 2 - Flutter Basics'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/module3'),
            child: const Text('Module 3 - Riverpod Counter'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/module4'),
            child: const Text('Module 4 - Timeline UI'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/module5'),
            child: const Text('Module 5 - Responsive Layout'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/module6'),
            child: const Text('Module 6 - Animated Timeline'),
          ),
        ],
      ),
    );
  }
}
// Adding Triggering CI test