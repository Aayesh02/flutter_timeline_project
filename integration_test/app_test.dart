import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_timeline_project/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full app smoke test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Check if the app loaded the welcome message
    expect(find.text('Welcome to the Responsive Timeline Project'), findsOneWidget);

    // Simulate tapping on timeline event (adjust selector to your app)
    // await tester.tap(find.text('Project Kickoff'));
    // await tester.pumpAndSettle();

    // Verify new content or UI changes after tap
  });
}
