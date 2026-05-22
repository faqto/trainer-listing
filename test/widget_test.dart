import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fit_ed/main.dart';
import 'package:fit_ed/models/activity_event.dart';
import 'package:fit_ed/models/client_model.dart';
import 'package:fit_ed/models/deletion_request.dart';
import 'package:fit_ed/models/user_role.dart';
import 'package:fit_ed/services/activity_repository.dart';
import 'package:fit_ed/services/auth_repository.dart';
import 'package:fit_ed/services/client_repository.dart';
import 'package:fit_ed/services/deletion_request_repository.dart';

void main() {
  setUp(() async {
    AuthRepository.instance = _FakeAuthRepository();
    ClientRepository.instance = _FakeClientRepository();
    ActivityRepository.instance = _FakeActivityRepository();
    DeletionRequestRepository.instance = _FakeDeletionRequestRepository();
    await ClientRepository.instance.resetForTesting();
    await DeletionRequestRepository.instance.resetForTesting();
  });

  testWidgets('signs in and shows the dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await _signInAsCoach(tester);

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Coach Trainer'), findsOneWidget);
    expect(find.text('Clients'), findsWidgets);
  });

  testWidgets('does not reveal a not found page after signed-in back', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await _signInAsCoach(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Page Not Found'), findsNothing);
    expect(find.text('Missing client information.'), findsNothing);
  });

  testWidgets('adds a client from the dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await _signInAsCoach(tester);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full Name'),
      'Jordan Lee',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Age'), '34');
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Female').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'jordan@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Phone'),
      '555-0103',
    );
    await tester.tap(find.text('Training Goal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Muscle gain').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Client'));
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

    await _signInAsCoach(tester);

    await tester.tap(find.byIcon(Icons.assignment));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sarah Jenkins'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Edit'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Workout regime'),
      'Push, pull, legs with progressive overload.',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Cardio plan'),
      'Zone 2 bike for 25 minutes twice weekly.',
    );

    final saveRegimeButton = find.widgetWithText(ElevatedButton, 'Save Regime');
    await tester.ensureVisible(saveRegimeButton);
    await tester.pumpAndSettle();
    await tester.tap(saveRegimeButton);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
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

    await _signInAsCoach(tester);

    await tester.tap(find.byIcon(Icons.people));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sarah Jenkins'));
    await tester.pumpAndSettle();

    final updateBodyMetricsButton = find.widgetWithText(
      OutlinedButton,
      'Update Body Metrics',
    );
    await tester.scrollUntilVisible(
      updateBodyMetricsButton,
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(updateBodyMetricsButton);
    await tester.pumpAndSettle();
    await tester.tap(updateBodyMetricsButton);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Weight (kg)'),
      '62',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Progress note'),
      'Improved consistency this week.',
    );

    final saveMetricsButton = find.widgetWithText(
      ElevatedButton,
      'Save Metrics',
    );
    await tester.scrollUntilVisible(
      saveMetricsButton,
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(saveMetricsButton);
    await tester.pumpAndSettle();
    await tester.tap(saveMetricsButton);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Metrics').last);
    await tester.pumpAndSettle();

    expect(find.text('Progress History'), findsOneWidget);
    expect(find.text('Improved consistency this week.'), findsOneWidget);
    expect(find.textContaining('Weight 62.0 kg'), findsOneWidget);
  });

  testWidgets('logs out after inactivity timeout', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await _signInAsCoach(tester);

    expect(find.text('Dashboard'), findsOneWidget);

    await tester.pump(const Duration(minutes: 5));
    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);
  });
}

Future<void> _signInAsCoach(WidgetTester tester) async {
  await tester.enterText(
    find.byType(TextFormField).at(0),
    'trainer@example.com',
  );
  await tester.enterText(find.byType(TextFormField).at(1), 'password');
  await tester.tap(find.text('Sign In'));
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

class _FakeAuthRepository implements AuthRepository {
  bool _signedIn = false;
  String _name = 'Trainer';
  String _email = '';
  UserRole _role = UserRole.coach;

  @override
  bool get hasCurrentUser => _signedIn;

  @override
  String? get currentUserId => _signedIn ? 'test-trainer' : null;

  @override
  String? get currentUserEmail => _signedIn ? _email : null;

  @override
  String get currentUserName => _name;

  @override
  String get currentUserLastName => _name;

  @override
  UserRole? get currentUserRole => _signedIn ? _role : null;

  @override
  Future<UserRole> loadCurrentUserRole() async => _role;

  @override
  Future<void> signIn({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _signedIn = true;
    _email = email;
    _role = role;
    _name = _formatUserName(email.split('@').first);
  }

  @override
  Future<void> register({
    required String name,
    required String lastName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _signedIn = true;
    _email = email;
    _role = role;
    _name = name.trim().isEmpty ? 'Trainer' : name.trim();
  }

  @override
  Future<void> signOut() async {
    _signedIn = false;
    _email = '';
  }

  @override
  // TODO: implement isEmailVerified
  bool get isEmailVerified => throw UnimplementedError();

  @override
  Future<void> reloadUser() {
    // TODO: implement reloadUser
    throw UnimplementedError();
  }

  @override
  Future<void> sendVerificationEmail() {
    // TODO: implement sendVerificationEmail
    throw UnimplementedError();
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
        schedule: 'Mon / Wed / Fri at 9:00 AM',
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
        schedule: 'Tue / Thu at 7:00 AM',
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

class _FakeActivityRepository extends ActivityRepository {
  @override
  Future<void> log(ActivityEvent event) async {}

  @override
  Future<List<ActivityEvent>> getRecent({int limit = 20}) async => [];

  @override
  Future<List<ActivityEvent>> getAll({ActivityType? filterType}) async => [];
}

class _FakeDeletionRequestRepository implements DeletionRequestRepository {
  final List<DeletionRequest> _requests = [];

  @override
  Future<List<DeletionRequest>> get pendingRequests async => _requests
      .where((request) => request.status == DeletionRequestStatus.pending)
      .toList();

  @override
  Future<DeletionRequest?> getCurrentClientRequest({
    required String coachId,
    required String clientId,
  }) async {
    for (final request in _requests) {
      if (request.coachId == coachId && request.clientId == clientId) {
        return request;
      }
    }
    return null;
  }

  @override
  Future<void> submitCurrentClientRequest({
    required String coachId,
    required Client client,
    required String reason,
  }) async {
    _requests.add(
      DeletionRequest(
        id: client.id,
        clientId: client.id,
        clientName: client.name,
        clientEmail: client.email,
        coachId: coachId,
        reason: reason,
        requestedAt: DateTime(2026, 5, 20),
      ),
    );
  }

  @override
  Future<void> approveRequest(DeletionRequest request) async {
    _requests.removeWhere((entry) => entry.id == request.id);
    await ClientRepository.instance.deleteClient(request.clientId);
  }

  @override
  Future<void> rejectRequest(DeletionRequest request) async {
    _requests.removeWhere((entry) => entry.id == request.id);
  }

  @override
  Future<void> resetForTesting() async {
    _requests.clear();
  }
}
