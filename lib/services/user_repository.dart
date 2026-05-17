import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user_profile.dart';
import '../models/client_model.dart';
import '../models/user_role.dart';
import 'auth_repository.dart';

class UserRepository {
  static final UserRepository instance = UserRepository._();
  UserRepository._();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  Future<AppUserProfile?> getCurrentProfile() async {
    final userId = AuthRepository.instance.currentUserId;
    if (userId == null) return null;

    final snapshot = await _usersCollection.doc(userId).get();
    if (!snapshot.exists || snapshot.data() == null) return null;
    return AppUserProfile.fromMap(snapshot.data()!, snapshot.id);
  }

  Future<List<AppUserProfile>> getCoaches() async {
    final snapshot = await _usersCollection
        .where('role', isEqualTo: UserRole.coach.name)
        .get();
    final coaches = snapshot.docs
        .map((doc) => AppUserProfile.fromMap(doc.data(), doc.id))
        .toList();
    coaches.sort((a, b) => a.name.compareTo(b.name));
    return coaches;
  }

  Future<ClientDashboardData> getCurrentClientDashboardData() async {
    final userId = AuthRepository.instance.currentUserId;
    if (userId == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unauthenticated',
        message: 'Please sign in before loading your fitness dashboard.',
      );
    }

    final profile = await getCurrentProfile();
    if (profile == null) {
      return const ClientDashboardData(profile: null, client: null);
    }

    final assignedCoachId = profile.assignedCoachId;
    if (assignedCoachId == null || assignedCoachId.isEmpty) {
      return ClientDashboardData(profile: profile, client: null);
    }

    final client =
        await _getAssignedClient(assignedCoachId, userId) ??
        _clientFromProfile(profile, userId);
    return ClientDashboardData(profile: profile, client: client);
  }

  Future<void> updateCurrentClientMetrics(ProgressEntry progressEntry) async {
    final userId = AuthRepository.instance.currentUserId;
    if (userId == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unauthenticated',
        message: 'Please sign in before updating your metrics.',
      );
    }

    final profile = await getCurrentProfile();
    if (profile == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: 'Your client profile could not be found.',
      );
    }

    final assignedCoachId = profile.assignedCoachId;
    final existingClient = await _getAssignedClient(assignedCoachId, userId);
    final baseClient = existingClient ?? _clientFromProfile(profile, userId);
    final updatedClient = baseClient.copyWith(
      weightKg: progressEntry.weightKg,
      heightCm: progressEntry.heightCm,
      bodyFatPercent: progressEntry.bodyFatPercent,
      waistCm: progressEntry.waistCm,
      hipsCm: progressEntry.hipsCm,
      chestCm: progressEntry.chestCm,
      progressEntries: [...baseClient.progressEntries, progressEntry],
    );

    final batch = _firestore.batch();
    batch.set(_usersCollection.doc(userId), {
      'weightKg': progressEntry.weightKg,
      'heightCm': progressEntry.heightCm,
      'bodyFatPercent': progressEntry.bodyFatPercent,
      'waistCm': progressEntry.waistCm,
      'hipsCm': progressEntry.hipsCm,
      'chestCm': progressEntry.chestCm,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (assignedCoachId != null && assignedCoachId.isNotEmpty) {
      batch.set(
        _usersCollection.doc(assignedCoachId).collection('clients').doc(userId),
        {
          ...updatedClient.toMap(),
          'source': 'client_choice',
          'coachName': profile.assignedCoachName ?? '',
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  Future<void> assignCurrentClientToCoach({
    required AppUserProfile coach,
    required Client client,
  }) async {
    final userId = AuthRepository.instance.currentUserId;
    if (userId == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unauthenticated',
        message: 'Please sign in before choosing a coach.',
      );
    }

    final profile = await getCurrentProfile();
    final previousCoachId = profile?.assignedCoachId;
    final existingClient = previousCoachId == coach.id
        ? await _getAssignedClient(previousCoachId, userId)
        : null;
    final clientForCoach = (existingClient ?? client).copyWith(
      id: userId,
      clientUserId: userId,
      coachId: coach.id,
      name: client.name,
      email: client.email,
      phone: client.phone,
      age: client.age,
      sex: client.sex,
      goal: client.goal,
      schedule: client.schedule,
      weightKg: client.weightKg,
      heightCm: client.heightCm,
      bodyFatPercent: client.bodyFatPercent,
      waistCm: client.waistCm,
      hipsCm: client.hipsCm,
      chestCm: client.chestCm,
    );

    final batch = _firestore.batch();
    final userRef = _usersCollection.doc(userId);

    if (previousCoachId != null &&
        previousCoachId.isNotEmpty &&
        previousCoachId != coach.id) {
      batch.delete(
        _usersCollection.doc(previousCoachId).collection('clients').doc(userId),
      );
    }

    batch.set(userRef, {
      'name': clientForCoach.name,
      'email': clientForCoach.email,
      'role': UserRole.client.name,
      'phone': clientForCoach.phone,
      'age': clientForCoach.age,
      'sex': clientForCoach.sex,
      'goal': clientForCoach.goal,
      'schedule': clientForCoach.schedule,
      'weightKg': clientForCoach.weightKg,
      'heightCm': clientForCoach.heightCm,
      'bodyFatPercent': clientForCoach.bodyFatPercent,
      'waistCm': clientForCoach.waistCm,
      'hipsCm': clientForCoach.hipsCm,
      'chestCm': clientForCoach.chestCm,
      'assignedCoachId': coach.id,
      'assignedCoachName': coach.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final coachClientData = <String, dynamic>{
      ...clientForCoach.toMap(),
      'source': 'client_choice',
      'coachName': coach.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (existingClient == null || previousCoachId != coach.id) {
      coachClientData['assignedAt'] = FieldValue.serverTimestamp();
    }

    batch.set(
      _usersCollection.doc(coach.id).collection('clients').doc(userId),
      coachClientData,
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  Future<Client?> _getAssignedClient(String? coachId, String clientId) async {
    if (coachId == null || coachId.isEmpty) return null;

    final snapshot = await _usersCollection
        .doc(coachId)
        .collection('clients')
        .doc(clientId)
        .get();
    if (!snapshot.exists || snapshot.data() == null) return null;
    return Client.fromMap(snapshot.data()!, snapshot.id);
  }

  Client _clientFromProfile(AppUserProfile profile, String userId) {
    return Client(
      id: userId,
      clientUserId: userId,
      coachId: profile.assignedCoachId,
      name: profile.name,
      email: profile.email,
      phone: profile.phone,
      age: profile.age,
      sex: profile.sex,
      goal: profile.goal,
      schedule: profile.schedule,
      weightKg: profile.weightKg,
      heightCm: profile.heightCm,
      bodyFatPercent: profile.bodyFatPercent,
      waistCm: profile.waistCm,
      hipsCm: profile.hipsCm,
      chestCm: profile.chestCm,
      notes: '',
    );
  }
}

class ClientDashboardData {
  final AppUserProfile? profile;
  final Client? client;

  const ClientDashboardData({required this.profile, required this.client});

  bool get hasAssignedCoach =>
      profile?.assignedCoachId != null && profile!.assignedCoachId!.isNotEmpty;
}
