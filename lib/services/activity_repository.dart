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

  /// Logs a new activity event to Firestore.
  Future<void> log(ActivityEvent event) async {
    final docRef = _activityCollection.doc();
    await docRef.set(event.toMap());
  }

  /// Marks a session as ended for [client], logs a sessionCompleted event.
  Future<void> logSessionCompleted(Client client, DateTime endTime) async {
    final durationMin = _durationMinutes(client);
    String duration = '';
    if (durationMin > 0) {
      final start = client.scheduledEndTime!.subtract(
        Duration(minutes: durationMin),
      );
      final diff = endTime.difference(start);
      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      duration = h > 0 ? '${h}h ${m}m' : '${m}m';
    }
    await log(
      ActivityEvent(
        id: '',
        type: ActivityType.sessionCompleted,
        clientId: client.id,
        clientName: client.name,
        description: duration.isNotEmpty
            ? 'Session completed — $duration'
            : 'Session completed',
        timestamp: endTime,
      ),
    );
  }

  /// Checks all clients for sessions whose scheduled end time has passed
  /// without a completion event, and logs a missed session for each.
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

  /// Resolves a missed session event with the trainer's chosen outcome.
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

  /// Fetches the most recent [limit] activity events, newest first.
  Future<List<ActivityEvent>> getRecent({int limit = 20}) async {
    final snapshot = await _activityCollection
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ActivityEvent.fromMap(doc.data(), doc.id))
        .toList();
  }

  int _durationMinutes(Client client) {
    final forMatch = RegExp(r'for (.+)$').firstMatch(client.schedule);
    if (forMatch == null) return 0;
    final durStr = forMatch.group(1)!.trim();
    final hMatch = RegExp(r'(\d+)h').firstMatch(durStr);
    final mMatch = RegExp(r'(\d+)m').firstMatch(durStr);
    final hours = hMatch != null ? int.tryParse(hMatch.group(1)!) ?? 0 : 0;
    final minutes = mMatch != null ? int.tryParse(mMatch.group(1)!) ?? 0 : 0;
    return hours * 60 + minutes;
  }
}
