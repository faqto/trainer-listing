import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainer_listing/main.dart';
import 'package:trainer_listing/services/client_repository.dart';

void main() {
  setUp(() {
    ClientRepository.instance.resetForTesting();
  });

  testWidgets('signs in and shows the dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextFormField).at(0), 'trainer');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Coach Ed'), findsOneWidget);
    expect(find.text('Active Clients'), findsOneWidget);
  });

  testWidgets('adds a client from the dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextFormField).at(0), 'trainer');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Client'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full Name'),
      'Jordan Lee',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Age'), '34');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Gender'),
      'Nonbinary',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'jordan@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Goal'),
      'Improve mobility',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Program'),
      'Mobility',
    );

    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.people));
    await tester.pumpAndSettle();

    expect(find.text('Jordan Lee'), findsOneWidget);
    expect(ClientRepository.instance.clients.length, 3);
  });

  testWidgets('edits a client fitness regime', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextFormField).at(0), 'trainer');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.assignment));
    await tester.pumpAndSettle();
    await tester.tap(find.text('General Fitness'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Edit'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Program name'),
      'Hypertrophy Base',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Strength / workout regime'),
      'Push, pull, legs with progressive overload.',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Cardio / conditioning plan'),
      'Zone 2 bike for 25 minutes twice weekly.',
    );

    await tester.tap(find.text('Save Regime'));
    await tester.pumpAndSettle();

    expect(find.text('Hypertrophy Base'), findsAtLeastNWidgets(1));
    expect(
      find.text('Push, pull, legs with progressive overload.'),
      findsOneWidget,
    );
  });

  testWidgets('records progress history from body metrics', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextFormField).at(0), 'trainer');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.people));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sarah Jenkins'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Update Body Metrics'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Update Body Metrics'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Weight (kg)'),
      '62',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Progress note'),
      'Improved consistency this week.',
    );

    await tester.scrollUntilVisible(
      find.text('Save Metrics'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Save Metrics'));
    await tester.pumpAndSettle();

    expect(find.text('Progress History'), findsOneWidget);
    expect(find.text('Improved consistency this week.'), findsOneWidget);
    expect(find.textContaining('Weight 62.0 kg'), findsOneWidget);
  });

  testWidgets('logs out after inactivity timeout', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextFormField).at(0), 'trainer');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);

    await tester.pump(const Duration(minutes: 5));
    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);
  });
}
