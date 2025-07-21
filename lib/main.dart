// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'models/timeline_event.dart'; // Imports the core data model for timeline events, including the CustomEventIcon enum.
import 'notifiers/timeline_notifier.dart'; // Imports the Riverpod StateNotifier managing the timeline's state.
import 'widgets/new_event_dialog.dart'; // Imports the dialog used for adding or editing timeline events.
import 'widgets/timeline_event_card.dart'; // Imports the widget responsible for displaying individual timeline events.
import 'widgets/add_intervention_dialog.dart'; // Imports the dialog for adjusting intervention frequencies.

/// The entry point of the application.
///
/// This function sets up the Flutter application, wrapping it with a [ProviderScope]
/// from Riverpod. This allows all widgets within the app to access and manage
/// application-wide state using Riverpod providers. The [MaterialApp] configures
/// the basic visual structure and navigation, starting with the [Module4TimelineScreen].
void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false, // Hides the debug banner in the top-right corner.
        home: Module4TimelineScreen(), // Sets Module4TimelineScreen as the initial screen.
      ),
    ),
  );
}

/// A [ConsumerWidget] that serves as the main screen for the interactive timeline.
///
/// It leverages Riverpod to react to changes in the [TimelineNotifier]'s state,
/// displaying a dynamic list of timeline events. The layout is designed to be
/// responsive across different screen sizes and orientations using `ResponsiveBuilder`.
class Module4TimelineScreen extends ConsumerWidget {
  /// Creates a [Module4TimelineScreen] instance.
  const Module4TimelineScreen({super.key});

  /// Determines the appropriate [IconData] for a given [CustomEventIcon] enum value.
  ///
  /// The icons are chosen to visually represent the event type, aligning with
  /// the design specified in the project's mockups or requirements.
  IconData _getIconData(CustomEventIcon icon) {
    switch (icon) {
      case CustomEventIcon.checkmark:
        return Icons.check; // A simple checkmark icon.
      case CustomEventIcon.warning:
        return Icons.loop; // Represents a circular arrow or refresh action.
      case CustomEventIcon.info:
        return Icons.error_outline; // An outlined exclamation mark, typically for important info.
      case CustomEventIcon.bell:
        return Icons.notifications_none; // A simple outlined bell.
      case CustomEventIcon.minus:
        return Icons.remove; // A minus sign.
      case CustomEventIcon.none:
        return Icons.circle; // A filled circle for events without a specific icon.
    }
  }

  /// Provides a color for a given [CustomEventIcon] enum value.
  ///
  /// These colors are selected to match the visual theme and enhance the
  /// distinction between different event types on the timeline.
  Color _getIconColor(CustomEventIcon icon) {
    switch (icon) {
      case CustomEventIcon.checkmark:
        return const Color(0xFF00897B); // A teal-green shade.
      case CustomEventIcon.warning:
        return const Color(0xFFFFB300); // A vibrant orange/amber.
      case CustomEventIcon.info:
        return const Color(0xFFE53935); // A strong red.
      case CustomEventIcon.bell:
        return const Color(0xFFB0BEC5); // A light blue-grey.
      case CustomEventIcon.minus:
        return const Color(0xFFE53935); // Reusing the red for consistency with 'info'.
      case CustomEventIcon.none:
        return Colors.grey; // A neutral grey for default icons.
    }
  }

  /// Displays the [AddInterventionDialog].
  ///
  /// This function is called when the "Add Intervention" button is pressed,
  /// presenting a modal dialog for users to adjust intervention frequencies.
  void _showAddInterventionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddInterventionDialog(); // Returns the dialog widget.
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the current state of the timeline from the timelineProvider.
    // `ref.watch` ensures the widget rebuilds when the timeline state changes.
    final timelineState = ref.watch(timelineProvider);
    // Access the methods of the TimelineNotifier to perform state updates.
    // `ref.read` is used here because we only need to call methods, not react to state changes.
    final timelineNotifier = ref.read(timelineProvider.notifier);

    // Retrieve media query data for responsive layout calculations.
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Timeline'), // The title displayed in the app bar.
        backgroundColor: const Color(0xFFD6006E), // A custom deep pink color for the app bar.
        // No actions (buttons) are placed directly in the AppBar for this design.
        actions: const [],
      ),
      // The FloatingActionButton is explicitly set to null as it's not used on this screen.
      floatingActionButton: null,

      // `ResponsiveBuilder` helps adapt the UI based on the device's screen type (mobile, tablet, desktop).
      body: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          // Determine horizontal padding based on the device screen type.
          double padding = 16.0;
          if (sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
            padding = 32.0; // Larger padding for tablets.
          } else if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
            padding = 64.0; // Even larger padding for desktops.
          }

          // Decide whether to display full button text or just icons.
          // Full text is shown on wider screens (non-mobile or wider than 350px).
          final bool showFullButtonText = screenWidth > 350 && sizingInformation.deviceScreenType != DeviceScreenType.mobile;

          // Calculate a responsive font size for the welcome message.
          double titleFontSize = isPortrait ? screenWidth * 0.05 : screenHeight * 0.05;
          if (titleFontSize > 24) titleFontSize = 24; // Cap the maximum font size.
          if (titleFontSize < 16) titleFontSize = 16; // Set a minimum font size.

          // `LayoutBuilder` provides constraints of the parent widget, useful for dynamic sizing.
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                // Allows the entire content of the timeline to be scrollable if it exceeds screen height.
                child: ConstrainedBox(
                  // Ensures the content column takes at least the full available height,
                  // preventing it from collapsing if content is sparse.
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.all(padding), // Apply the calculated responsive padding.
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the left.
                      children: [
                        Center(
                          // Centers the welcome text horizontally.
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0), // Space below the welcome text.
                            child: Text(
                              'Welcome to the Responsive Timeline Project',
                              style: TextStyle(
                                fontSize: titleFontSize, // Apply the responsive font size.
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center, // Centers the text within its own bounds.
                            ),
                          ),
                        ),
                        // Container for the action buttons and the initial instruction text.
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0), // Space below the button row.
                          child: Wrap(
                            alignment: WrapAlignment.start, // Aligns buttons to the left, wrapping as needed.
                            spacing: 8.0, // Horizontal space between buttons.
                            runSpacing: 8.0, // Vertical space between rows of wrapped buttons.
                            children: [
                              // "Add Intervention" Button
                              ElevatedButton.icon(
                                key: const Key('add_intervention_button'), // Unique key for testing.
                                onPressed: () => _showAddInterventionDialog(context), // Calls the function to show the intervention dialog.
                                icon: const Icon(Icons.add), // Plus icon.
                                label: const Text('Add Intervention'), // Text label for the button.
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD6006E), // Custom background color.
                                  foregroundColor: Colors.white, // Text and icon color.
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Internal padding.
                                  textStyle: const TextStyle(fontSize: 16), // Font size for the label.
                                ),
                              ),
                              // "Add Event" Button
                              ElevatedButton.icon(
                                key: const Key('add_event_button'), // Unique key for testing.
                                onPressed: () async {
                                  // Shows the NewEventDialog, waiting for a returned TimelineEvent.
                                  final TimelineEvent? newEvent = await showDialog<TimelineEvent>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      // Calculate available height for the dialog, accounting for keyboard and safe areas.
                                      final mediaQueryContext = MediaQuery.of(context);
                                      final screenHeight = mediaQueryContext.size.height;
                                      final safeAreaTop = mediaQueryContext.padding.top;
                                      final safeAreaBottom = mediaQueryContext.padding.bottom;
                                      final keyboardHeight = mediaQueryContext.viewInsets.bottom;
                                      // Subtract a fixed value (e.g., 230.0) for other UI elements or general padding.
                                      final double availableDialogHeight = screenHeight - safeAreaTop - safeAreaBottom - keyboardHeight - 230.0;
                                      // Ensure a minimum height for the dialog.
                                      final double finalMaxHeight = availableDialogHeight > 200 ? availableDialogHeight : 200;

                                      return SingleChildScrollView(
                                        // Makes the dialog content scrollable.
                                        child: NewEventDialog(
                                          maxHeight: finalMaxHeight, // Passes the calculated max height.
                                        ),
                                      );
                                    },
                                  );
                                  // If a new event was successfully created and returned, add it to the timeline.
                                  if (newEvent != null) {
                                    timelineNotifier.addNewEvent(newEvent);
                                  }
                                },
                                icon: const Icon(Icons.add), // Plus icon.
                                label: const Text('Add Event'), // Text label for the button.
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD6006E), // Custom background color.
                                  foregroundColor: Colors.white, // Text and icon color.
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Internal padding.
                                  textStyle: const TextStyle(fontSize: 16), // Font size for the label.
                                ),
                              ),
                              // Conditional text displayed based on whether events exist in the timeline.
                              Text(
                                timelineState.events.isEmpty
                                    ? 'Start your timeline by adding an event!' // Message when timeline is empty.
                                    : 'Click "Add Event" to update the timeline', // Message when events exist.
                                style: TextStyle(
                                  fontSize: sizingInformation.isMobile ? 14 : 16, // Responsive font size.
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[700],
                                ),
                                softWrap: true, // Allows the text to wrap to the next line.
                                overflow: TextOverflow.ellipsis, // Truncates text with an ellipsis if it still overflows.
                              ),
                            ],
                          ),
                        ),
                        // The main timeline display area.
                        // Wrapped in a `Row` with `Expanded` to ensure it takes full available horizontal space.
                        Row(
                          children: [
                            Expanded(
                              child: FixedTimeline.tileBuilder(
                                // Configures the visual theme of the timeline.
                                theme: TimelineThemeData(
                                  nodePosition: 0, // Aligns the timeline nodes to the start.
                                  indicatorTheme: const IndicatorThemeData(
                                    position: 0.5, // Centers the indicator within its space.
                                    size: 30.0, // Size of the circular indicator.
                                  ),
                                  connectorTheme: const ConnectorThemeData(
                                    thickness: 3.0, // Thickness of the connecting lines.
                                    color: Colors.grey, // Color of the connecting lines.
                                  ),
                                ),
                                // Builds the timeline tiles dynamically based on the events.
                                builder: TimelineTileBuilder.connected(
                                  itemCount: timelineState.events.length, // Number of events in the timeline.
                                  contentsBuilder: (_, index) {
                                    final event = timelineState.events[index];
                                    // Renders each event as a `TimelineEventCard`.
                                    return TimelineEventCard(
                                      key: ValueKey(event.id), // Unique key for efficient list updates.
                                      event: event,
                                      index: index,
                                      showFullButtonText: showFullButtonText, // Passes responsive button text preference.
                                    );
                                  },
                                  indicatorBuilder: (_, index) {
                                    final event = timelineState.events[index];
                                    // Builds the circular dot indicator for each event.
                                    return DotIndicator(
                                      color: _getIconColor(event.customIcon), // Color based on event type.
                                      child: Icon(
                                        _getIconData(event.customIcon), // Icon based on event type.
                                        color: Colors.white, // White icon for contrast.
                                        size: 20, // Size of the icon within the dot.
                                      ),
                                    );
                                  },
                                  connectorBuilder: (_, index, __) {
                                    // Connectors are solid lines, except before the last event, where it's dashed.
                                    final isBeforeLast = index == timelineState.events.length - 2;
                                    return isBeforeLast
                                        ? const DashedLineConnector() // Dashed line for the second-to-last event.
                                        : const SolidLineConnector(); // Solid line for others.
                                  },
                                  itemExtentBuilder: (_, index) {
                                    // Dynamically adjusts the height of each timeline item based on its expanded state.
                                    if (timelineState.expandedIndexes.contains(index)) {
                                      // Expanded height, adjusted for different screen types and orientations.
                                      if (sizingInformation.isMobile && isPortrait) {
                                        return 300.0; // Mobile portrait expanded height.
                                      } else if (sizingInformation.isMobile && !isPortrait) {
                                        return 200.0; // Mobile landscape expanded height.
                                      } else if (sizingInformation.isTablet) {
                                        return 350.0; // Tablet expanded height.
                                      } else {
                                        return 400.0; // Desktop expanded height.
                                      }
                                    } else {
                                      // Compact height when not expanded.
                                      return sizingInformation.isMobile ? 120.0 : 140.0; // Mobile vs. larger screens compact height.
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
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
