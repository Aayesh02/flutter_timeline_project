import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:intl/intl.dart';

import 'models/timeline_event.dart';
import 'notifiers/timeline_notifier.dart';
import 'widgets/new_event_dialog.dart';

/// The main entry point of the Flutter application.
///
/// Wraps the entire app in a [ProviderScope] to enable Riverpod for state management.
void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false, // Disables the debug banner in release mode.
        home: Module4TimelineScreen(), // Sets the main screen of the application.
      ),
    ),
  );
}

/// A [ConsumerWidget] that displays an interactive timeline of events.
///
/// It uses Riverpod to watch and interact with the [TimelineNotifier].
class Module4TimelineScreen extends ConsumerWidget {
  /// Constructor for [Module4TimelineScreen].
  const Module4TimelineScreen({super.key});

  /// Displays an [AlertDialog] with detailed information about a [TimelineEvent].
  ///
  /// [context] is the current build context.
  /// [event] is the [TimelineEvent] whose details are to be displayed.
  void _showEventDetailsDialog(BuildContext context, TimelineEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title), // Displays the event's title.
        content: Column(
          mainAxisSize: MainAxisSize.min, // Makes the column take minimum vertical space.
          crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start horizontally.
          children: [
            Text('ID: ${event.id}'), // Displays the event's unique ID.
            const SizedBox(height: 8), // Provides vertical spacing.
            Text('Date/Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(event.timestamp)}'), // Displays formatted date and time.
            const SizedBox(height: 8), // Provides vertical spacing.
            Text(event.description), // Displays the event's description.
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Closes the dialog when pressed.
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the timeline state from the TimelineNotifier.
    final timelineState = ref.watch(timelineProvider);
    // Read the timeline notifier to access its methods.
    final timelineNotifier = ref.read(timelineProvider.notifier);

    // Get MediaQuery data for responsive adjustments.
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Timeline'), // App bar title.
        backgroundColor: const Color(0xFFD6006E), // Custom background color for the app bar.
      ),
      floatingActionButton: null, // No FloatingActionButton for this screen.

      body: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          // Adjust padding based on device screen type.
          double padding = 16.0;
          if (sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
            padding = 32.0;
          } else if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
            padding = 64.0;
          }

          // Determine whether to show full button text or just icons based on screen width and device type.
          final bool showFullButtonText = screenWidth > 350 && sizingInformation.deviceScreenType != DeviceScreenType.mobile;

          // Adjust title font size based on orientation and screen dimensions.
          double titleFontSize = isPortrait ? screenWidth * 0.05 : screenHeight * 0.05;
          if (titleFontSize > 24) titleFontSize = 24; // Cap max font size.
          if (titleFontSize < 16) titleFontSize = 16; // Set min font size.

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView( // Allows the content to scroll if it overflows vertically.
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight), // Ensures the content takes at least the full height available.
                  child: Padding(
                    padding: EdgeInsets.all(padding), // Apply responsive padding.
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Aligns content to the start horizontally.
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0), // Padding below the welcome text.
                            child: Text(
                              'Welcome to the Responsive Timeline Project',
                              style: TextStyle(
                                fontSize: titleFontSize, // Apply responsive font size.
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center, // Center aligns the text.
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0), // Padding below the action buttons.
                          child: Wrap(
                            alignment: WrapAlignment.start, // Aligns children to the start in the wrap layout.
                            spacing: 8.0, // Horizontal spacing between children.
                            runSpacing: 8.0, // Vertical spacing between lines of children.
                            children: [
                              ElevatedButton.icon(
                                key: const Key('add_event_button'), // Key for integration testing.
                                onPressed: () async {
                                  // Show the NewEventDialog to add a new event.
                                  final TimelineEvent? newEvent = await showDialog<TimelineEvent>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      // Calculate available height for the dialog, considering keyboard and safe areas.
                                      final mediaQueryContext = MediaQuery.of(context);
                                      final screenHeight = mediaQueryContext.size.height;
                                      final safeAreaTop = mediaQueryContext.padding.top;
                                      final safeAreaBottom = mediaQueryContext.padding.bottom;
                                      final keyboardHeight = mediaQueryContext.viewInsets.bottom;
                                      final double availableDialogHeight = screenHeight - safeAreaTop - safeAreaBottom - keyboardHeight - 230.0;
                                      final double finalMaxHeight = availableDialogHeight > 200 ? availableDialogHeight : 200;

                                      return SingleChildScrollView( // Allows dialog content to scroll.
                                        child: NewEventDialog(
                                          maxHeight: finalMaxHeight, // Pass calculated max height to the dialog.
                                        ),
                                      );
                                    },
                                  );
                                  // If a new event was created, add it to the timeline notifier.
                                  if (newEvent != null) {
                                    timelineNotifier.addNewEvent(newEvent);
                                  }
                                },
                                icon: const Icon(Icons.add), // Add icon.
                                label: const Text('Add Event'), // Button text.
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD6006E), // Custom button background color.
                                  foregroundColor: Colors.white, // Custom button text/icon color.
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Button padding.
                                  textStyle: const TextStyle(fontSize: 16), // Button text style.
                                ),
                              ),
                              SizedBox(
                                width: constraints.maxWidth - 100, // Provides width for the instructional text.
                                child: Text(
                                  timelineState.events.isEmpty
                                      ? 'Start your timeline by adding an event!' // Message when timeline is empty.
                                      : 'Click "Add Event" to update the timeline', // Message when timeline has events.
                                  style: TextStyle(
                                    fontSize: sizingInformation.isMobile ? 14 : 16, // Responsive font size.
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey[700],
                                  ),
                                  softWrap: true, // Allows text to wrap.
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Display the timeline using TimelinesPlus package.
                        FixedTimeline.tileBuilder(
                          theme: TimelineThemeData(
                            nodePosition: 0, // Position of the indicator node.
                            indicatorTheme: const IndicatorThemeData(
                              position: 0.5, // Indicator position relative to the line.
                              size: 30.0, // Size of the indicator.
                            ),
                            connectorTheme: const ConnectorThemeData(
                              thickness: 3.0, // Thickness of the connector line.
                              color: Colors.grey, // Color of the connector line.
                            ),
                          ),
                          builder: TimelineTileBuilder.connected(
                            itemCount: timelineState.events.length, // Number of items in the timeline.
                            contentsBuilder: (_, index) {
                              final event = timelineState.events[index];
                              final expanded = timelineState.expandedIndexes.contains(index);

                              final displayDate = DateFormat('yyyy-MM-dd').format(event.timestamp);
                              final displayTime = DateFormat('HH:mm').format(event.timestamp);

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0), // Vertical padding for each timeline item.
                                child: GestureDetector(
                                  onTap: () => timelineNotifier.toggleExpand(index), // Toggles event expansion on tap.
                                  onLongPress: () => _showEventDetailsDialog(context, event), // Shows detailed dialog on long press.
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300), // Animation duration for expansion.
                                    padding: const EdgeInsets.all(12), // Padding inside the event container.
                                    decoration: BoxDecoration(
                                      color: expanded ? Colors.pink[50] : Colors.transparent, // Background color changes when expanded.
                                      borderRadius: BorderRadius.circular(8), // Rounded corners.
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start, // Aligns content to the start.
                                      children: [
                                        Text(
                                          '$displayDate $displayTime: ${event.title}', // Displays date, time, and title.
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                          softWrap: true, // Allows text to wrap.
                                          overflow: TextOverflow.ellipsis, // Truncates with "..." if text overflows.
                                          maxLines: 2, // Max lines for title.
                                        ),
                                        if (expanded) ...[ // Shows description and buttons only if expanded.
                                          const SizedBox(height: 8), // Spacing.
                                          Text(
                                            event.description,
                                            overflow: TextOverflow.ellipsis, // Truncates description.
                                            maxLines: 4, // Max lines for description.
                                          ),
                                          const SizedBox(height: 8), // Spacing.
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end, // Aligns buttons to the end.
                                            children: [
                                              Expanded( // Ensures the button takes available space.
                                                child: showFullButtonText
                                                    ? ElevatedButton.icon(
                                                        key: Key('edit_event_button_$index'), // Key for integration testing.
                                                        onPressed: () async {
                                                          // Show dialog to edit event.
                                                          final TimelineEvent? updatedEvent = await showDialog<TimelineEvent>(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              // Calculate available height for the dialog.
                                                              final mediaQueryContext = MediaQuery.of(context);
                                                              final screenHeight = mediaQueryContext.size.height;
                                                              final safeAreaTop = mediaQueryContext.padding.top;
                                                              final safeAreaBottom = mediaQueryContext.padding.bottom;
                                                              final keyboardHeight = mediaQueryContext.viewInsets.bottom;
                                                              final double availableDialogHeight = screenHeight - safeAreaTop - safeAreaBottom - keyboardHeight - 230.0;
                                                              final double finalMaxHeight = availableDialogHeight > 200 ? availableDialogHeight : 200;

                                                              return SingleChildScrollView(
                                                                child: NewEventDialog(
                                                                  initialEvent: event, // Pass current event for editing.
                                                                  maxHeight: finalMaxHeight,
                                                                ),
                                                              );
                                                            },
                                                          );

                                                          // If event was updated, apply changes via notifier.
                                                          if (updatedEvent != null) {
                                                            timelineNotifier.editEvent(index, updatedEvent);
                                                          }
                                                        },
                                                        icon: const Icon(Icons.edit, size: 18), // Edit icon.
                                                        label: const FittedBox( // Ensures text fits within button.
                                                          fit: BoxFit.scaleDown,
                                                          alignment: Alignment.centerLeft,
                                                          child: Text('Edit'),
                                                        ),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.blueGrey, // Custom button background color.
                                                          foregroundColor: Colors.white, // Custom button text/icon color.
                                                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6), // Button padding.
                                                          textStyle: const TextStyle(fontSize: 14), // Button text style.
                                                        ),
                                                      )
                                                    : IconButton( // Icon-only button for smaller screens.
                                                        key: Key('edit_event_icon_button_$index'), // Key for integration testing.
                                                        onPressed: () async {
                                                          // Show dialog to edit event.
                                                          final TimelineEvent? updatedEvent = await showDialog<TimelineEvent>(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              // Calculate available height for the dialog.
                                                              final mediaQueryContext = MediaQuery.of(context);
                                                              final screenHeight = mediaQueryContext.size.height;
                                                              final safeAreaTop = mediaQueryContext.padding.top;
                                                              final safeAreaBottom = mediaQueryContext.padding.bottom;
                                                              final keyboardHeight = mediaQueryContext.viewInsets.bottom;
                                                              final double availableDialogHeight = screenHeight - safeAreaTop - safeAreaBottom - keyboardHeight - 230.0;
                                                              final double finalMaxHeight = availableDialogHeight > 200 ? availableDialogHeight : 200;

                                                              return SingleChildScrollView(
                                                                child: NewEventDialog(
                                                                  initialEvent: event, // Pass current event for editing.
                                                                  maxHeight: finalMaxHeight,
                                                                ),
                                                              );
                                                            },
                                                          );

                                                          // If event was updated, apply changes via notifier.
                                                          if (updatedEvent != null) {
                                                            timelineNotifier.editEvent(index, updatedEvent);
                                                          }
                                                        },
                                                        icon: const Icon(Icons.edit, size: 24, color: Colors.blueGrey), // Edit icon.
                                                        tooltip: 'Edit Event', // Tooltip for icon-only button.
                                                      ),
                                              ),
                                              Expanded(
                                                child: showFullButtonText
                                                    ? ElevatedButton.icon(
                                                        key: Key('delete_event_button_$index'), // Key for integration testing.
                                                        onPressed: () async {
                                                          // Show confirmation dialog before deleting.
                                                          final bool? confirmDelete = await showDialog<bool>(
                                                            context: context,
                                                            builder: (context) => AlertDialog(
                                                              title: const Text('Confirm Deletion'),
                                                              content: Text('Are you sure you want to delete "${event.title}"?'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () => Navigator.pop(context, false), // Cancel deletion.
                                                                  child: const Text('Cancel'),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () => Navigator.pop(context, true), // Confirm deletion.
                                                                  child: const Text('Delete'),
                                                                ),
                                                              ],
                                                            ),
                                                          );

                                                          // If deletion is confirmed, delete the event and show a snackbar.
                                                          if (confirmDelete == true) {
                                                            timelineNotifier.deleteEvent(index);
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(content: Text('"${event.title}" deleted.')),
                                                            );
                                                          }
                                                        },
                                                        icon: const Icon(Icons.delete, size: 18), // Delete icon.
                                                        label: const FittedBox( // Ensures text fits within button.
                                                          fit: BoxFit.scaleDown,
                                                          alignment: Alignment.centerLeft,
                                                          child: Text('Delete'),
                                                        ),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.red, // Custom button background color.
                                                          foregroundColor: Colors.white, // Custom button text/icon color.
                                                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6), // Button padding.
                                                          textStyle: const TextStyle(fontSize: 14), // Button text style.
                                                        ),
                                                      )
                                                    : IconButton( // Icon-only button for smaller screens.
                                                        key: Key('delete_event_icon_button_$index'), // Key for integration testing.
                                                        onPressed: () async {
                                                          // Show confirmation dialog before deleting.
                                                          final bool? confirmDelete = await showDialog<bool>(
                                                            context: context,
                                                            builder: (context) => AlertDialog(
                                                              title: const Text('Confirm Deletion'),
                                                              content: Text('Are you sure you want to delete "${event.title}"?'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () => Navigator.pop(context, false), // Cancel deletion.
                                                                  child: const Text('Cancel'),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () => Navigator.pop(context, true), // Confirm deletion.
                                                                  child: const Text('Delete'),
                                                                ),
                                                              ],
                                                            ),
                                                          );

                                                          // If deletion is confirmed, delete the event and show a snackbar.
                                                          if (confirmDelete == true) {
                                                            timelineNotifier.deleteEvent(index);
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(content: Text('"${event.title}" deleted.')),
                                                            );
                                                          }
                                                        },
                                                        icon: const Icon(Icons.delete, size: 24, color: Colors.red), // Delete icon.
                                                        tooltip: 'Delete Event', // Tooltip for icon-only button.
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            indicatorBuilder: (_, index) {
                              final isLast = index == timelineState.events.length - 1;
                              return isLast
                                  ? const DotIndicator(color: Color.fromARGB(255, 213, 217, 219)) // Last event indicator.
                                  : const DotIndicator(
                                      color: Color.fromARGB(255, 213, 217, 219),
                                      child: Icon(Icons.check, color: Color(0xFFD6006E), size: 16), // Checkmark for completed events.
                                    );
                            },
                            connectorBuilder: (_, index, __) {
                              final isBeforeLast = index == timelineState.events.length - 2;
                              return isBeforeLast
                                  ? const DashedLineConnector() // Dashed connector for the second to last event.
                                  : const SolidLineConnector(); // Solid connector for other events.
                            },
                            itemExtentBuilder: (_, index) {
                              // Dynamically adjust item height based on expansion and screen size.
                              if (timelineState.expandedIndexes.contains(index)) {
                                if (sizingInformation.isMobile && isPortrait) {
                                  return 350.0;
                                } else if (sizingInformation.isMobile && !isPortrait) {
                                  return 250.0;
                                } else if (sizingInformation.isTablet) {
                                  return 400.0;
                                } else {
                                  return 450.0;
                                }
                              } else {
                                return sizingInformation.isMobile ? 100.0 : 120.0; // Compact height when not expanded.
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
