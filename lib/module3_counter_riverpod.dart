import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Create a StateProvider to hold and manage an integer counter state
final counterProvider = StateProvider<int>((ref) => 0);

// 2. Build the UI using ConsumerWidget to access Riverpod's state management
class CounterHomeScreen extends ConsumerWidget {
  const CounterHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current value of the counterProvider
    final count = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod Counter Example'),
        backgroundColor: Colors.cyan,
      ),
      body: Center(
        // Display the current counter value in a styled Text widget
        child: Text(
          'Counter: $count',
          style: const TextStyle(fontSize: 24),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // When pressed, increment the counter by accessing the provider's notifier
        onPressed: () => ref.read(counterProvider.notifier).state++,
        child: const Icon(Icons.add), // Plus icon for the FAB
      ),
    );
  }
}

