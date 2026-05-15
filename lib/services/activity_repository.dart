import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activity_event.dart';
import '../models/client_model.dart';
import '../helpers/client_metrics.dart';
import 'auth_repository.dart';

class ActivityRepository {
  static final ActivityRepository instance = ActivityRepository._();
  ActivityRepository._();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _activityCollection {
    final userId = AuthRepository.instance.currentUserId;
    if (userId == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unauthenticated',
        message: 'Please sign in.',
      );
    }
    return _firestore.collection('users').doc(userId).collection('activity');
  }

  Future<void> log(ActivityEvent event) async {
    final docRef = _activityCollection.doc();
    await docRef.set(event.toMap());
  }

  Future<void> checkAndLogMissedSessions(List<Client> clients) async {
    final now = DateTime.now();

    for (final client in clients) {
      if (!hasSessionToday(client)) continue;
      final endTime = client.scheduledEndTime;
      if (endTime == null || now.isBefore(endTime)) continue;

      final todayStart = DateTime(now.year, now.month, now.day);
      final snapshot = await _activityCollection
          .where('clientId', isEqualTo: client.id)
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: todayStart.toIso8601String(),
          )
          .get();

      final alreadyLogged = snapshot.docs.any((doc) {
        final type = doc.data()['type'] as String?;
        return type == ActivityType.sessionCompleted.name ||
            type == ActivityType.sessionMissed.name;
      });

      if (!alreadyLogged) {
        await log(
          ActivityEvent(
            id: '',
            type: ActivityType.sessionMissed,
            clientId: client.id,
            clientName: client.name,
            description:
                'Session window passed — did you forget to mark, or did ${client.name} not make it?',
            timestamp: endTime,
            missedResolved: false,
          ),
        );
      }
    }
  }

  Future<void> resolveMissedSession(ActivityEvent event, String outcome) async {
    await _activityCollection.doc(event.id).update({'missedResolved': true});

    final isCompleted = outcome == 'completed';
    await log(
      ActivityEvent(
        id: '',
        type: isCompleted
            ? ActivityType.sessionCompleted
            : ActivityType.sessionMissed,
        clientId: event.clientId,
        clientName: event.clientName,
        description: isCompleted
            ? 'Session marked as completed (late)'
            : '${event.clientName} missed the session',
        timestamp: DateTime.now(),
        missedResolved: isCompleted ? null : true,
      ),
    );
  }

  Future<List<ActivityEvent>> getRecent({int limit = 20}) async {
    final snapshot = await _activityCollection
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ActivityEvent.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<ActivityEvent>> getAll({ActivityType? filterType}) async {
    Query<Map<String, dynamic>> query = _activityCollection.orderBy(
      'timestamp',
      descending: true,
    );

    if (filterType != null) {
      query = query.where('type', isEqualTo: filterType.name);
    }

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => ActivityEvent.fromMap(doc.data(), doc.id))
        .toList();
  }
}
