import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activity_event.dart';
import 'auth_repository.dart';

class ActivityRepository {
  static ActivityRepository instance = ActivityRepository();
  ActivityRepository();

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
