// lib/widgets/timeline_event_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:auto_size_text/auto_size_text.dart'; // Import AutoSizeText

import '../models/timeline_event.dart';
import '../notifiers/timeline_notifier.dart';
import 'new_event_dialog.dart'; // For the NewEventDialog
import 'event_details_dialog.dart'; // Explicitly importing EventDetailsDialog

/// A widget representing a single timeline event card with hover effects.
/// It manages its own hover state to show/hide interactive elements and apply visual feedback.
class TimelineEventCard extends ConsumerStatefulWidget {
  final TimelineEvent event;
  final int index;
  final bool showFullButtonText; // Passed from parent for responsive button text

  const TimelineEventCard({
    super.key,
    required this.event,
    required this.index,
    required this.showFullButtonText,
  });

  @override
  ConsumerState<TimelineEventCard> createState() => _TimelineEventCardState();
}

class _TimelineEventCardState extends ConsumerState<TimelineEventCard> {
  bool _isHovering = false; // State to track if the mouse is hovering over the card

  // Removed _getIconData and _getIconColor as they are unused directly in this widget
  // and should be defined within EventDetailsDialog or passed to it.

  /// Helper function to get a simplified time zone abbreviation.
  String _getSimplifiedTimeZoneAbbr(DateTime timestamp) {
    final String systemTimeZoneName = timestamp.timeZoneName;
    debugPrint('[DEBUG TIMEZONE] systemTimeZoneName: $systemTimeZoneName');

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

    final String zzzAbbr = DateFormat('zzz').format(timestamp);
    debugPrint('[DEBUG TIMEZONE] zzzAbbr from DateFormat: "$zzzAbbr"');

    if (zzzAbbr.isNotEmpty && !zzzAbbr.startsWith('+') && !zzzAbbr.startsWith('-')) {
      return zzzAbbr;
    }

    if (systemTimeZoneName.length > 5) {
      return systemTimeZoneName.substring(0, 3).toUpperCase();
    }
    return systemTimeZoneName;
  }

  @override
  Widget build(BuildContext context) {
    final timelineNotifier = ref.read(timelineProvider.notifier);
    final isExpanded = ref.watch(timelineProvider.select((state) => state.expandedIndexes.contains(widget.index)));

    final String formattedDate = DateFormat('M/d/yyyy, h:mm a').format(widget.event.timestamp);
    final String simplifiedTimeZone = _getSimplifiedTimeZoneAbbr(widget.event.timestamp);
    final String displayDateWithTimeZone = '$formattedDate $simplifiedTimeZone';

    debugPrint('[DEBUG TIMEZONE] Final display string: $displayDateWithTimeZone');

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () => timelineNotifier.toggleExpand(widget.index),
        onLongPress: () {
          // Use the dedicated EventDetailsDialog
          showDialog(
            context: context,
            builder: (dialogContext) => EventDetailsDialog(event: widget.event), // Use dialogContext here
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isHovering
                ? [
                    BoxShadow(
                      color: Colors.grey.withAlpha(128),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    AutoSizeText(
                      displayDateWithTimeZone,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      minFontSize: 10,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Description is only visible when expanded
                    if (isExpanded)
                      Text(
                        widget.event.description,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 4,
                      ),
                  ],
                ),
              ),
              if (_isHovering || isExpanded) // Show buttons on hover or when expanded
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Corrected from MainAxisSize.size.min
                      children: [
                        // Edit Button
                        widget.showFullButtonText
                            ? ElevatedButton.icon(
                                key: Key('edit_event_button_${widget.event.id}'),
                                onPressed: () async {
                                  // Capture context and notifier before async gap
                                  final currentContext = context;
                                  final currentNotifier = timelineNotifier;

                                  final TimelineEvent? updatedEvent = await showDialog<TimelineEvent>(
                                    context: currentContext, // Use captured context
                                    builder: (BuildContext dialogContext) {
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
                                          initialEvent: widget.event,
                                        ),
                                      );
                                    },
                                  );
                                  if (!mounted) return; // Check mounted status after async operation
                                  if (updatedEvent != null) {
                                    currentNotifier.editEvent(widget.index, updatedEvent);
                                  }
                                },
                                icon: const Icon(Icons.edit, size: 18),
                                label: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text('Edit'),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                                  textStyle: const TextStyle(fontSize: 14),
                                ),
                              )
                            : IconButton(
                                key: Key('edit_event_icon_button_${widget.event.id}'),
                                onPressed: () async {
                                  // Capture context and notifier before async gap
                                  final currentContext = context;
                                  final currentNotifier = timelineNotifier;

                                  final TimelineEvent? updatedEvent = await showDialog<TimelineEvent>(
                                    context: currentContext, // Use captured context
                                    builder: (BuildContext dialogContext) {
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
                                          initialEvent: widget.event,
                                        ),
                                      );
                                    },
                                  );
                                  if (!mounted) return; // Check mounted status after async operation
                                  if (updatedEvent != null) {
                                    currentNotifier.editEvent(widget.index, updatedEvent);
                                  }
                                },
                                icon: const Icon(Icons.edit, size: 24, color: Colors.blueGrey),
                                tooltip: 'Edit Event',
                              ),
                        const SizedBox(height: 8),
                        // Delete Button
                        widget.showFullButtonText
                            ? ElevatedButton.icon(
                                key: Key('delete_event_button_${widget.event.id}'),
                                onPressed: () async {
                                  // Capture context and notifier before async gap
                                  final currentContext = context;
                                  final currentNotifier = timelineNotifier;

                                  final bool? confirmDelete = await showDialog<bool>(
                                    context: currentContext, // Use captured context
                                    builder: (BuildContext dialogContext) => SingleChildScrollView(
                                      child: AlertDialog(
                                        key: Key('delete_confirmation_dialog_${widget.event.id}'), // Added key for testability
                                        title: const Text('Confirm Deletion'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Are you sure you want to delete "${widget.event.title}"?',
                                              softWrap: true,
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            key: Key('delete_confirmation_cancel_button_${widget.event.id}'), // Added key
                                            onPressed: () => Navigator.pop(dialogContext, false), // Use dialogContext
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            key: Key('delete_confirmation_confirm_button_${widget.event.id}'), // Added key
                                            onPressed: () {
                                              currentNotifier.deleteEvent(widget.index);
                                              ScaffoldMessenger.of(currentContext).showSnackBar( // Use captured context
                                                SnackBar(content: Text('"${widget.event.title}" deleted.')),
                                              );
                                              Navigator.pop(dialogContext, true); // Use dialogContext
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                  if (!mounted) return; // Check mounted status after async operation
                                  if (confirmDelete == true) { // Correctly using confirmDelete
                                    // Actions already performed in the dialog's onPressed, no need to duplicate
                                  }
                                },
                                icon: const Icon(Icons.delete, size: 18),
                                label: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text('Delete'),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                                  textStyle: const TextStyle(fontSize: 14),
                                ),
                              )
                            : IconButton(
                                key: Key('delete_event_icon_button_${widget.event.id}'),
                                onPressed: () async {
                                  // Capture context and notifier before async gap
                                  final currentContext = context;
                                  final currentNotifier = timelineNotifier;

                                  final bool? confirmDelete = await showDialog<bool>(
                                    context: currentContext, // Use captured context
                                    builder: (BuildContext dialogContext) => SingleChildScrollView(
                                      child: AlertDialog(
                                        key: Key('delete_confirmation_dialog_${widget.event.id}'), // Added key
                                        title: const Text('Confirm Deletion'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Are you sure you want to delete "${widget.event.title}"?',
                                              softWrap: true,
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            key: Key('delete_confirmation_cancel_button_${widget.event.id}'), // Added key
                                            onPressed: () => Navigator.pop(dialogContext, false), // Use dialogContext
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            key: Key('delete_confirmation_confirm_button_${widget.event.id}'), // Added key
                                            onPressed: () {
                                              currentNotifier.deleteEvent(widget.index);
                                              ScaffoldMessenger.of(currentContext).showSnackBar( // Use captured context
                                                SnackBar(content: Text('"${widget.event.title}" deleted.')),
                                              );
                                              Navigator.pop(dialogContext, true); // Use dialogContext
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                  if (!mounted) return; // Check mounted status after async operation
                                  if (confirmDelete == true) { // Correctly using confirmDelete
                                    // Actions already performed in the dialog's onPressed, no need to duplicate
                                  }
                                },
                                icon: const Icon(Icons.delete, size: 24, color: Colors.red),
                                tooltip: 'Delete Event',
                              ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}