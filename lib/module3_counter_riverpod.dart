import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Step 2: Create a StateProvider
final counterProvider = StateProvider<int>((ref) => 0);

void main() {
  // Step 1: Wrap app in ProviderScope
  runApp(ProviderScope(child: TimelineApp()));
}

class TimelineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsive Timeline',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TimelineHomePage(),
    );
  }
}

// Step 3 & 4: Use ConsumerWidget to access and display the provider state
class TimelineHomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Timeline Project')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timeline, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Welcome to the Responsive Timeline Project',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Text('Counter: $counter', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                ref.read(counterProvider.notifier).state++;
              },
              child: Text('Increment Counter'),
            ),
          ],
        ),
      ),
    );
  }
}
