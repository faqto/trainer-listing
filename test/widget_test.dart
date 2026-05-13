import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainer_listing/main.dart';
import 'package:trainer_listing/models/client_model.dart';
import 'package:trainer_listing/services/auth_repository.dart';
import 'package:trainer_listing/services/client_repository.dart';

void main() {
  setUp(() async {
    AuthRepository.instance = _FakeAuthRepository();
    ClientRepository.instance = _FakeClientRepository();
    await ClientRepository.instance.resetForTesting();
  });

  testWidgets('signs in and shows the dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'trainer@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Coach Trainer'), findsOneWidget);
    expect(find.text('Clients'), findsWidgets);
  });

  testWidgets('adds a client from the dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'trainer@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add'));
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
    await tester.tap(find.text('Training Goal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Muscle gain').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.people));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.scrollUntilVisible(
      find.text('Jordan Lee'),
      300,
      scrollable: find.byType(Scrollable).last,
    );

    expect(find.text('Jordan Lee'), findsOneWidget);
    final clients = await ClientRepository.instance.clients;
    expect(clients.length, 3);
  });

  testWidgets('edits a client fitness regime', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'trainer@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.assignment));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sarah Jenkins'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Edit'));
    await tester.pumpAndSettle();

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

    expect(
      find.text('Push, pull, legs with progressive overload.'),
      findsOneWidget,
    );
  });

  testWidgets('records progress history from body metrics', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'trainer@example.com',
    );
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

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'trainer@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);

    await tester.pump(const Duration(minutes: 5));
    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);
  });
}

class _FakeAuthRepository implements AuthRepository {
  bool _signedIn = false;
  String _name = 'Trainer';

  @override
  bool get hasCurrentUser => _signedIn;

  @override
  String? get currentUserId => _signedIn ? 'test-trainer' : null;

  @override
  String get currentUserName => _name;

  @override
  String get currentUserLastName => _name;

  @override
  Future<void> signIn({required String email, required String password}) async {
    _signedIn = true;
    _name = _formatUserName(email.split('@').first);
  }

  @override
  Future<void> register({
    required String name,
    required String lastName,
    required String email,
    required String password,
  }) async {
    _signedIn = true;
    _name = name.trim().isEmpty ? 'Trainer' : name.trim();
  }

  @override
  Future<void> signOut() async {
    _signedIn = false;
  }
}

String _formatUserName(String value) {
  final cleaned = value.trim().replaceAll(RegExp(r'[._-]+'), ' ');
  if (cleaned.isEmpty) return 'Trainer';

  return cleaned
      .split(RegExp(r'\s+'))
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}

class _FakeClientRepository implements ClientRepository {
  late List<Client> _clients;
  int _nextId = 1;

  @override
  Future<List<Client>> get clients async => List.unmodifiable(_clients);

  @override
  Future<void> resetForTesting() async {
    _nextId = 1;
    _clients = [
      Client(
        id: 'sarah-jenkins',
        name: 'Sarah Jenkins',
        email: 'sarah@example.com',
        phone: '555-0101',
        age: 31,
        sex: 'Female',
        goal: 'Muscle gain',
        trainingProgram: 'Strength foundation',
        schedule: 'Mon Wed Fri',
        fitnessRegime: 'Full-body strength training.',
        cardioPlan: 'Incline walk twice weekly.',
        joinDate: DateTime(2026, 5, 1),
        weightKg: 61,
        heightCm: 165,
        bodyFatPercent: 22,
        waistCm: 72,
        hipsCm: 96,
        chestCm: 88,
      ),
      Client(
        id: 'marcus-chen',
        name: 'Marcus Chen',
        email: 'marcus@example.com',
        phone: '555-0102',
        age: 38,
        sex: 'Male',
        goal: 'Fat loss',
        trainingProgram: 'Conditioning block',
        schedule: 'Tue Thu',
        fitnessRegime: 'Circuit training.',
        cardioPlan: 'Zone 2 rowing.',
        joinDate: DateTime(2026, 4, 24),
        weightKg: 84,
        heightCm: 178,
        bodyFatPercent: 24,
        waistCm: 91,
        hipsCm: 101,
        chestCm: 104,
      ),
    ];
  }

  @override
  Future<Client?> getById(String id) async {
    for (final client in _clients) {
      if (client.id == id) return client;
    }
    return null;
  }

  @override
  Future<void> addClient(Client client) async {
    _clients.add(client);
  }

  @override
  Future<void> updateClient(Client client) async {
    final index = _clients.indexWhere((entry) => entry.id == client.id);
    if (index == -1) return;
    _clients[index] = client;
  }

  @override
  Future<void> deleteClient(String id) async {
    _clients.removeWhere((client) => client.id == id);
  }

  @override
  String createClientId() {
    return 'client-${_nextId++}';
  }
}
