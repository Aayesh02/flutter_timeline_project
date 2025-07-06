// lib/widgets/new_event_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/timeline_event.dart';

/// A dialog widget for adding new timeline events or editing existing ones.
class NewEventDialog extends StatefulWidget {
  /// The initial event data if editing an existing event. Null if adding a new event.
  final TimelineEvent? initialEvent;

  /// Maximum height constraint for the dialog content.
  /// Note: This property is currently not directly used for content sizing
  /// due to the specific handling of the DatePickerDialog, but is kept
  /// as part of the constructor's contract.
  final double maxHeight;

  /// Constructor for NewEventDialog.
  const NewEventDialog({
    super.key,
    this.initialEvent,
    required this.maxHeight,
  });

  @override
  State<NewEventDialog> createState() => _NewEventDialogState();
}

/// The state class for NewEventDialog.
class _NewEventDialogState extends State<NewEventDialog> {
  /// Controller for the event title text field.
  final _titleController = TextEditingController();

  /// Controller for the event description text field.
  final _descriptionController = TextEditingController();

  /// Stores the date selected by the user.
  DateTime? _selectedDate;

  /// Stores the time selected by the user.
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    // Initialize controllers and selected date/time with initial event data if provided,
    // otherwise, set them to current date/time.
    if (widget.initialEvent != null) {
      _titleController.text = widget.initialEvent!.title;
      _descriptionController.text = widget.initialEvent!.description;
      final initialDateTime = widget.initialEvent!.timestamp;
      _selectedDate = initialDateTime;
      _selectedTime = TimeOfDay.fromDateTime(initialDateTime);
    } else {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources.
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Displays a date picker dialog and updates the selected date.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      // The builder is used here to ensure the DatePickerDialog renders at its natural size
      // without internal content squeezing, and then clips any parts that extend beyond the screen.
      builder: (BuildContext context, Widget? child) {
        return Center( // Centers the dialog content on the screen.
          child: ClipRect( // Clips any content that overflows its bounds.
            child: OverflowBox( // Allows its child (the DatePickerDialog) to be larger than its parent.
              minWidth: 0.0, // Allows the child to be as small as it naturally wants.
              maxWidth: double.infinity, // Allows the child to be as wide as it naturally wants.
              minHeight: 0.0, // Allows the child to be as small as it naturally wants.
              maxHeight: double.infinity, // Allows the child to be as tall as it naturally wants.
              alignment: Alignment.center, // Centers the child within the OverflowBox.
              child: child, // The actual DatePickerDialog widget provided by showDatePicker.
            ),
          ),
        );
      },
    );
    // If a date was picked and it's different from the current selected date, update the state.
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Displays a time picker dialog and updates the selected time.
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    // If a time was picked and it's different from the current selected time, update the state.
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the dialog is in editing mode based on initialEvent.
    final isEditing = widget.initialEvent != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Timeline Event' : 'Add New Timeline Event'),
      content: SingleChildScrollView( // Allows the content of the AlertDialog to be scrollable if it exceeds screen height.
        child: Column(
          mainAxisSize: MainAxisSize.min, // Makes the column take minimum vertical space.
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Event Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Event Description'),
              maxLines: 3, // Allows up to 3 lines for the description.
            ),
            const SizedBox(height: 16), // Provides vertical spacing.
            // Text field for displaying and selecting the date.
            TextField(
              readOnly: true, // Prevents direct text input; user must tap to open date picker.
              controller: TextEditingController(
                text: _selectedDate == null
                    ? ''
                    : DateFormat('yyyy-MM-dd').format(_selectedDate!),
              ),
              decoration: InputDecoration(
                labelText: 'Date',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context), // Opens date picker on icon tap.
                ),
              ),
              onTap: () => _selectDate(context), // Opens date picker on text field tap.
            ),
            const SizedBox(height: 16), // Provides vertical spacing.
            Row(
              children: [
                Expanded( // Ensures the Text widget takes available horizontal space.
                  child: Text(
                    _selectedTime == null
                        ? 'No time chosen!'
                        : 'Time: ${_selectedTime!.format(context)}',
                    softWrap: false, // Prevents text from wrapping to a new line.
                    overflow: TextOverflow.ellipsis, // Truncates text with "..." if it overflows.
                  ),
                ),
                Flexible( // Allows the TextButton to take flexible space, preventing overflow.
                  child: TextButton(
                    onPressed: () => _selectTime(context), // Opens time picker.
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0), // Smaller horizontal padding for the button.
                    ),
                    child: const Text('Choose Time'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Closes the dialog without saving any changes.
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Validate if title and description are not empty.
            if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
              // Show a snackbar if validation fails.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter title and description')),
              );
              return; // Stop execution if validation fails.
            }

            // Combine selected date and time into a single DateTime object.
            final DateTime combinedDateTime = DateTime(
              _selectedDate!.year,
              _selectedDate!.month,
              _selectedDate!.day,
              _selectedTime!.hour,
              _selectedTime!.minute,
            );

            // Create a new TimelineEvent object with the collected data.
            final newEvent = TimelineEvent(
              id: isEditing ? widget.initialEvent!.id : DateTime.now().microsecondsSinceEpoch, // Use existing ID if editing, otherwise generate a new one.
              title: _titleController.text,
              description: _descriptionController.text,
              timestamp: combinedDateTime,
            );
            Navigator.pop(context, newEvent); // Closes the dialog and passes the new/updated event back.
          },
          child: Text(isEditing ? 'Save Changes' : 'Add Event'),
        ),
      ],
    );
  }
}
