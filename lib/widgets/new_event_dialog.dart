// lib/widgets/new_event_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/timeline_event.dart'; // Import TimelineEvent and CustomEventIcon enum

/// A dialog for adding or editing a timeline event.
///
/// It allows users to input a title, description, date, time, and select a custom icon.
/// It can be used for adding a new event or pre-filled for editing an existing one.
class NewEventDialog extends StatefulWidget {
  final TimelineEvent? initialEvent; // Optional: Event to pre-fill for editing
  final double maxHeight; // Maximum height for the dialog content - now less critical for overflow

  const NewEventDialog({
    super.key,
    this.initialEvent,
    required this.maxHeight,
  });

  @override
  State<NewEventDialog> createState() => _NewEventDialogState();
}

class _NewEventDialogState extends State<NewEventDialog> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  CustomEventIcon? _selectedIcon; // Stores the custom icon selected by the user.


  @override
  void initState() {
    super.initState();
    // Initialize controllers and selected values based on whether it's a new event or an edit.
    if (widget.initialEvent != null) {
      _titleController = TextEditingController(text: widget.initialEvent!.title);
      _descriptionController = TextEditingController(text: widget.initialEvent!.description);
      _selectedDate = widget.initialEvent!.timestamp;
      _selectedTime = TimeOfDay.fromDateTime(widget.initialEvent!.timestamp);
      _selectedIcon = widget.initialEvent!.customIcon;
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedDate = DateTime.now(); // Default to current date for new events
      _selectedTime = TimeOfDay.now(); // Default to current time for new events
      _selectedIcon = CustomEventIcon.none; // Default to no specific icon
    }
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks.
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Shows a date picker and updates [_selectedDate].
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate, // Use _selectedDate directly, it's always initialized
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
      initialTime: _selectedTime, // Use _selectedTime directly, it's always initialized
    );
    // If a time was picked and it's different from the current selected time, update the state.
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  /// Maps a [CustomEventIcon] enum value to an [IconData] for display.
  /// Adjusted to match the specific icons from the provided screenshot.
  IconData _getIconData(CustomEventIcon icon) {
    switch (icon) {
      case CustomEventIcon.checkmark:
        return Icons.check;
      case CustomEventIcon.warning:
        return Icons.loop;
      case CustomEventIcon.info:
        return Icons.error_outline;
      case CustomEventIcon.bell:
        return Icons.notifications_none;
      case CustomEventIcon.minus:
        return Icons.remove;
      case CustomEventIcon.none:
        return Icons.circle_outlined;
    }
  }

  /// Maps a [CustomEventIcon] enum value to a color.
  /// Adjusted to match the specific colors from the provided screenshot.
  Color _getIconColor(CustomEventIcon icon) {
    switch (icon) {
      case CustomEventIcon.checkmark:
        return const Color(0xFF00897B);
      case CustomEventIcon.warning:
        return const Color(0xFFFFB300);
      case CustomEventIcon.info:
        return const Color(0xFFE53935);
      case CustomEventIcon.bell:
        return const Color(0xFFB0BEC5);
      case CustomEventIcon.minus:
        return const Color(0xFFE53935);
      case CustomEventIcon.none:
        return Colors.grey;
    }
  }

  /// Returns the custom label for each icon.
  String _getIconLabel(CustomEventIcon icon) {
    switch (icon) {
      case CustomEventIcon.checkmark:
        return 'Completed';
      case CustomEventIcon.warning:
        return 'In Progress';
      case CustomEventIcon.info:
        return 'Incomplete';
      case CustomEventIcon.bell:
        return 'Notify';
      case CustomEventIcon.minus:
        return 'Remove';
      case CustomEventIcon.none:
        return 'None';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the dialog is in editing mode based on initialEvent.
    final isEditing = widget.initialEvent != null;

    return SingleChildScrollView( // Allows the content of the AlertDialog to be scrollable if it exceeds screen height.
      child: AlertDialog(
        title: Text(isEditing ? 'Edit Timeline Event' : 'Add New Timeline Event'),
        content: Form( // Removed ConstrainedBox and SingleChildScrollView from here
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Column takes minimum space
            children: [
              TextFormField(
                key: const Key('new_event_title_field'), // Added Key
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Event Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                key: const Key('new_event_description_field'), // Added Key
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Event Description (Optional)'), // Added (Optional)
                maxLines: 3,
                // The description field is now optional, so no validator is needed here
              ),
              const SizedBox(height: 16), // Provides vertical spacing.
              // Text field for displaying and selecting the date.
              TextField(
                key: const Key('new_event_date_field'), // Added Key
                readOnly: true, // Prevents direct text input; user must tap to open date picker.
                controller: TextEditingController(
                  text: DateFormat('yyyy-MM-dd').format(_selectedDate), // _selectedDate is always non-null
                ),
                decoration: InputDecoration(
                  labelText: 'Date',
                  suffixIcon: IconButton(
                    key: const Key('new_event_date_picker_icon'), // Added Key
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context), // Opens date picker on icon tap.
                  ),
                ),
                onTap: () => _selectDate(context), // Opens date picker on text field tap.
              ),
              const SizedBox(height: 16), // Provides vertical spacing.
              Row(
                children: [
                  Expanded( // Ensures the Text takes available space.
                    child: Text(
                      'Time: ${_selectedTime.format(context)}', // _selectedTime is always non-null
                      softWrap: false, // Prevents text from wrapping to a new line.
                      overflow: TextOverflow.ellipsis, // Truncates text with "..." if too long.
                    ),
                  ),
                  Flexible( // Allows the TextButton to take flexible space, preventing overflow.
                    child: TextButton(
                      key: const Key('new_event_time_picker_button'), // Added Key
                      onPressed: () => _selectTime(context), // Opens time picker.
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0), // Smaller padding.
                      ),
                      child: const Text('Choose Time'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16), // Provides vertical spacing.
              // Section for custom icon selection.
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Choose Icon:', style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0, // Horizontal space between icons.
                runSpacing: 8.0, // Vertical space between rows of icons.
                children: CustomEventIcon.values.map((icon) {
                  return GestureDetector(
                    key: Key('new_event_icon_${icon.name}'), // Added Key
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _selectedIcon == icon ? _getIconColor(icon).withAlpha((255 * 0.2).round()) : Colors.transparent, // Replaced withAlpha
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedIcon == icon ? _getIconColor(icon) : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _getIconData(icon),
                            color: _getIconColor(icon),
                            size: 30,
                          ),
                          if (icon != CustomEventIcon.none) // Only show text for specific icons
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                _getIconLabel(icon),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getIconColor(icon),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('new_event_cancel_button'), // Added Key
            onPressed: () {
              Navigator.pop(context); // Closes the dialog without saving any changes.
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            key: const Key('new_event_save_button'), // Added Key
            onPressed: () {
              // Validate only the title. Description is optional.
              if (_titleController.text.isEmpty) {
                // Show a snackbar if validation fails.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a title')),
                );
                return; // Stop execution if validation fails.
              }

              // Combine selected date and time into a single DateTime object.
              final DateTime combinedDateTime = DateTime(
                _selectedDate.year, // _selectedDate is always non-null
                _selectedDate.month, // _selectedDate is always non-null
                _selectedDate.day, // _selectedDate is always non-null
                _selectedTime.hour, // _selectedTime is always non-null
                _selectedTime.minute, // _selectedTime is always non-null
              );

              // Create a new TimelineEvent object with the collected data, including the selected icon.
              final newEvent = TimelineEvent(
                id: isEditing ? widget.initialEvent!.id : DateTime.now().microsecondsSinceEpoch, // Use existing ID if editing, otherwise generate a new one.
                title: _titleController.text,
                description: _descriptionController.text, // Description is now optional
                timestamp: combinedDateTime,
                customIcon: _selectedIcon ?? CustomEventIcon.none, // Use selected icon or default to none
              );
              Navigator.pop(context, newEvent); // Closes the dialog and passes the new/updated event back.
            },
            child: Text(isEditing ? 'Save Changes' : 'Add Event'),
          ),
        ],
      ),
    );
  }
}