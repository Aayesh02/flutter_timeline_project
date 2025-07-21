// lib/widgets/add_intervention_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/timeline_notifier.dart'; // Import the Riverpod notifier

// Dialog widget for adjusting intervention frequencies
class AddInterventionDialog extends ConsumerStatefulWidget {
  const AddInterventionDialog({super.key});

  @override
  ConsumerState<AddInterventionDialog> createState() => _AddInterventionDialogState();
}

class _AddInterventionDialogState extends ConsumerState<AddInterventionDialog> {
  // Controllers to handle user input for frequency values
  final TextEditingController _rewardFrequencyController = TextEditingController(text: '0');
  final TextEditingController _meetingFrequencyController = TextEditingController(text: '0');

  // Increment frequency value and trigger a timeline event
  void _increment(TextEditingController controller, String frequencyType) {
    int currentValue = int.tryParse(controller.text) ?? 0;
    final newValue = currentValue + 1;
    setState(() {
      controller.text = newValue.toString(); // Update UI
    });

    // Notify the timeline of the frequency increase
    ref.read(timelineProvider.notifier).addFrequencyChangeEvent(
      type: frequencyType,
      value: newValue,
      increased: true,
    );
  }

  // Decrement frequency value and trigger a timeline event
  void _decrement(TextEditingController controller, String frequencyType) {
    int currentValue = int.tryParse(controller.text) ?? 0;
    if (currentValue > 0) {
      final newValue = currentValue - 1;
      setState(() {
        controller.text = newValue.toString(); // Update UI
      });

      // Notify the timeline of the frequency decrease
      ref.read(timelineProvider.notifier).addFrequencyChangeEvent(
        type: frequencyType,
        value: newValue,
        increased: false,
      );
    }
  }

  // Builds a labeled number input with increment and decrement buttons
  Widget _buildNumberInput(String label, TextEditingController controller) {
    // Generate unique keys for testability
    final String incrementKeyString = '${label.toLowerCase().replaceAll(' ', '_')}_increment';
    final String decrementKeyString = '${label.toLowerCase().replaceAll(' ', '_')}_decrement';
    final String textFieldKeyString = '${label.toLowerCase().replaceAll(' ', '_')}_field';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: IntrinsicWidth(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Decrement button
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: IconButton(
                      key: Key(decrementKeyString),
                      icon: const Icon(Icons.remove),
                      onPressed: () => _decrement(controller, label),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  // Numeric input field
                  SizedBox(
                    width: 90,
                    child: TextField(
                      key: Key(textFieldKeyString),
                      controller: controller,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // Only digits allowed
                      ],
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  // Increment button
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: IconButton(
                      key: Key(incrementKeyString),
                      icon: const Icon(Icons.add),
                      onPressed: () => _increment(controller, label),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _rewardFrequencyController.dispose();
    _meetingFrequencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: SingleChildScrollView(
        child: AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
          title: const Text(
            'Add Intervention',
            key: Key('add_intervention_dialog_title'), // <-- Added key here for testing
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.7,
              maxWidth: screenWidth * 0.9,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Input for meeting frequency
                  _buildNumberInput('Meeting Frequency', _meetingFrequencyController),
                  const SizedBox(height: 20),
                  // Input for reward frequency
                  _buildNumberInput('Reward Frequency', _rewardFrequencyController),
                ],
              ),
            ),
          ),
          actions: [
            // Cancel button: closes dialog without saving
            TextButton(
              key: const Key('add_intervention_dialog_cancel_button'),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            // Save button: closes dialog (event already added by buttons)
            ElevatedButton(
              key: const Key('add_intervention_dialog_save_button'),
              onPressed: () {
                // You could add a summary event here if needed
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
