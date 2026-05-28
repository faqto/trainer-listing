import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/client_model.dart';
import '../models/deletion_request.dart';
import 'auth_repository.dart';

abstract class DeletionRequestRepository {
  static DeletionRequestRepository instance =
      FirestoreDeletionRequestRepository();

  Future<List<DeletionRequest>> get pendingRequests;

  Future<DeletionRequest?> getCurrentClientRequest({
    required String coachId,
    required String clientId,
  });

  Future<void> submitCurrentClientRequest({
    required String coachId,
    required Client client,
    required String reason,
  });

  Future<void> approveRequest(DeletionRequest request);

  Future<void> rejectRequest(DeletionRequest request);
}

class FirestoreDeletionRequestRepository implements DeletionRequestRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  String get _currentUserId {
    final userId = AuthRepository.instance.currentUserId;
    if (userId == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unauthenticated',
        message: 'Please sign in before managing deletion requests.',
      );
    }
    return userId;
  }

  CollectionReference<Map<String, dynamic>> _requestsForCoach(String coachId) {
    return _firestore
        .collection('users')
        .doc(coachId)
        .collection('deletionRequests');
  }

  @override
  Future<List<DeletionRequest>> get pendingRequests async {
    final snapshot = await _requestsForCoach(
      _currentUserId,
    ).where('status', isEqualTo: DeletionRequestStatus.pending.name).get();
    final requests = snapshot.docs
        .map((doc) => DeletionRequest.fromMap(doc.data(), doc.id))
        .toList();
    requests.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
    return requests;
  }

  @override
  Future<DeletionRequest?> getCurrentClientRequest({
    required String coachId,
    required String clientId,
  }) async {
    final snapshot = await _requestsForCoach(coachId).doc(clientId).get();
    if (!snapshot.exists || snapshot.data() == null) return null;
    return DeletionRequest.fromMap(snapshot.data()!, snapshot.id);
  }

  @override
  Future<void> submitCurrentClientRequest({
    required String coachId,
    required Client client,
    required String reason,
  }) async {
    final userId = _currentUserId;
    await _requestsForCoach(coachId)
        .doc(userId)
        .set(
          DeletionRequest(
            id: userId,
            clientId: userId,
            clientName: client.name,
            clientEmail: client.email,
            coachId: coachId,
            reason: reason,
            requestedAt: DateTime.now(),
          ).toMap(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> approveRequest(DeletionRequest request) async {
    final coachId = _currentUserId;
    final batch = _firestore.batch();
    final requestRef = _requestsForCoach(coachId).doc(request.id);
    final clientRef = _firestore
        .collection('users')
        .doc(coachId)
        .collection('clients')
        .doc(request.clientId);

    batch.update(requestRef, {
      'status': DeletionRequestStatus.approved.name,
      'resolvedAt': FieldValue.serverTimestamp(),
    });
    batch.delete(clientRef);
    await batch.commit();
  }

  @override
  Future<void> rejectRequest(DeletionRequest request) async {
    await _requestsForCoach(_currentUserId).doc(request.id).update({
      'status': DeletionRequestStatus.rejected.name,
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }
}
