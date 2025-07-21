// lib/widgets/event_details_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/timeline_event.dart';
import '../notifiers/timeline_notifier.dart';
import 'new_event_dialog.dart'; // Import for showing NewEventDialog for editing

/// A dialog to display detailed information about a [TimelineEvent].
/// It also provides options to edit or delete the event.
class EventDetailsDialog extends ConsumerWidget {
  final TimelineEvent event;

  const EventDetailsDialog({
    super.key,
    required this.event,
  });

  /// Maps a [CustomEventIcon] enum value to an [IconData] for display.
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
  Color _getIconColor(CustomEventIcon icon) {
    switch (icon) {
      case CustomEventIcon.checkmark:
        return const Color(0xFF00897B); // Teal green
      case CustomEventIcon.warning:
        return const Color(0xFFFFB300); // Amber
      case CustomEventIcon.info:
        return const Color(0xFFE53935); // Red
      case CustomEventIcon.bell:
        return const Color(0xFFB0BEC5); // Grey-blue
      case CustomEventIcon.minus:
        return const Color(0xFFE53935); // Red
      case CustomEventIcon.none:
        return Colors.grey;
    }
  }

  /// Helper function to get a simplified time zone abbreviation.
  String _getSimplifiedTimeZoneAbbr(DateTime timestamp) {
    final String systemTimeZoneName = timestamp.timeZoneName;
    debugPrint('[DEBUG TIMEZONE] systemTimeZoneName: $systemTimeZoneName');

    // Return known short forms for common timezones
    if (systemTimeZoneName.contains('Central') && systemTimeZoneName.contains('Daylight')) return 'CDT';
    if (systemTimeZoneName.contains('Central') && systemTimeZoneName.contains('Standard')) return 'CST';
    if (systemTimeZoneName.contains('Eastern') && systemTimeZoneName.contains('Daylight')) return 'EDT';
    if (systemTimeZoneName.contains('Eastern') && systemTimeZoneName.contains('Standard')) return 'EST';
    if (systemTimeZoneName.contains('Pacific') && systemTimeZoneName.contains('Daylight')) return 'PDT';
    if (systemTimeZoneName.contains('Pacific') && systemTimeZoneName.contains('Standard')) return 'PST';
    if (systemTimeZoneName.contains('Mountain') && systemTimeZoneName.contains('Daylight')) return 'MDT';
    if (systemTimeZoneName.contains('Mountain') && systemTimeZoneName.contains('Standard')) return 'MST';
    if (systemTimeZoneName.contains('Greenwich')) return 'GMT';
    if (systemTimeZoneName.contains('Central European') && systemTimeZoneName.contains('Summer')) return 'CEST';
    if (systemTimeZoneName.contains('Central European') && systemTimeZoneName.contains('Standard')) return 'CET';
    if (systemTimeZoneName.contains('Japan')) return 'JST';
    if (systemTimeZoneName.contains('India')) return 'IST';
    if (systemTimeZoneName.contains('Coordinated Universal Time')) return 'UTC';

    // Fallback: try to format the zone abbreviation using intl
    final String zzzAbbr = DateFormat('zzz').format(timestamp);
    debugPrint('[DEBUG TIMEZONE] zzzAbbr from DateFormat: "$zzzAbbr"');

    if (zzzAbbr.isNotEmpty && !zzzAbbr.startsWith('+') && !zzzAbbr.startsWith('-')) {
      return zzzAbbr;
    }

    // Final fallback if the zone name is long
    if (systemTimeZoneName.length > 5) {
      return systemTimeZoneName.substring(0, 3).toUpperCase();
    }
    return systemTimeZoneName;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineNotifier = ref.read(timelineProvider.notifier);

    return AlertDialog(
      key: Key('details_dialog_${event.id}'), // Key for the dialog itself
      title: Text(event.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${event.id}'), // Display event ID
            const SizedBox(height: 8),
            // Format date/time and add time zone abbreviation
            Text('Date/Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(event.timestamp)} ${_getSimplifiedTimeZoneAbbr(event.timestamp)}'),
            const SizedBox(height: 8),
            Text(event.description), // Show event description
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Icon: '),
                Icon(_getIconData(event.customIcon), color: _getIconColor(event.customIcon), size: 20),
                Text(' (${event.customIcon.name})'), // Show enum name
              ],
            ),
          ],
        ),
      ),
      actions: [
        // Close Button
        TextButton(
          key: Key('details_dialog_close_button_${event.id}'), // Key for close button
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        // Edit Button
        TextButton(
          key: Key('details_dialog_edit_button_${event.id}'), // Key for edit button
          onPressed: () async {
            final currentContext = context;
            final currentNotifier = timelineNotifier;

            Navigator.pop(currentContext); // Close details dialog

            // Get index of the event in the list
            final int currentIndex = ref.watch(timelineProvider).events.indexWhere((e) => e.id == event.id);

            if (currentIndex != -1) {
              final TimelineEvent? updatedEvent = await showDialog<TimelineEvent>(
                context: currentContext,
                builder: (BuildContext dialogContext) {
                  // Calculate available height dynamically for dialog layout
                  final mediaQueryContext = MediaQuery.of(dialogContext);
                  final screenHeight = mediaQueryContext.size.height;
                  final safeAreaTop = mediaQueryContext.padding.top;
                  final safeAreaBottom = mediaQueryContext.padding.bottom;
                  final keyboardHeight = mediaQueryContext.viewInsets.bottom;
                  final double availableDialogHeight = screenHeight - safeAreaTop - safeAreaBottom - keyboardHeight - 230.0;
                  final double finalMaxHeight = availableDialogHeight > 200 ? availableDialogHeight : 200;

                  return SingleChildScrollView(
                    child: NewEventDialog(
                      maxHeight: finalMaxHeight,
                      initialEvent: event, // Provide current event for editing
                    ),
                  );
                },
              );

              if (!currentContext.mounted) return; // Prevent action if widget was disposed
              if (updatedEvent != null) {
                currentNotifier.editEvent(currentIndex, updatedEvent); // Apply changes
              }
            }
          },
          child: const Text('Edit'),
        ),
        // Delete Button
        TextButton(
          key: Key('details_dialog_delete_button_${event.id}'), // Key for delete button
          onPressed: () async {
            final currentContext = context;
            final currentNotifier = timelineNotifier;

            Navigator.pop(currentContext); // Close details dialog first

            // Show confirmation dialog before deleting
            final bool? confirmDelete = await showDialog<bool>(
              context: currentContext,
              builder: (BuildContext dialogContext) => SingleChildScrollView(
                child: AlertDialog(
                  key: Key('delete_confirmation_dialog_${event.id}'), // Key for confirmation dialog
                  title: const Text('Confirm Deletion'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Are you sure you want to delete "${event.title}"?',
                        softWrap: true,
                      ),
                    ],
                  ),
                  actions: [
                    // Cancel deletion
                    TextButton(
                      key: Key('delete_confirmation_cancel_button_${event.id}'),
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Cancel'),
                    ),
                    // Confirm deletion
                    TextButton(
                      key: Key('delete_confirmation_confirm_button_${event.id}'),
                      onPressed: () {
                        final int currentIndex = ref.watch(timelineProvider).events.indexWhere((e) => e.id == event.id);
                        if (currentIndex != -1) {
                          currentNotifier.deleteEvent(currentIndex);
                          ScaffoldMessenger.of(currentContext).showSnackBar(
                            SnackBar(content: Text('"${event.title}" deleted.')),
                          );
                        }
                        Navigator.pop(dialogContext, true); // Close confirmation dialog
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ),
            );

            if (!currentContext.mounted) return; // Ensure context is still valid
            if (confirmDelete == true) {
              // No further action needed — deletion is handled in the dialog above
            }
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
