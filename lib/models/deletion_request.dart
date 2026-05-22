import 'package:cloud_firestore/cloud_firestore.dart';

enum DeletionRequestStatus { pending, approved, rejected }

DeletionRequestStatus deletionRequestStatusFromName(String? name) {
  return DeletionRequestStatus.values.firstWhere(
    (status) => status.name == name,
    orElse: () => DeletionRequestStatus.pending,
  );
}

class DeletionRequest {
  final String id;
  final String clientId;
  final String clientName;
  final String clientEmail;
  final String coachId;
  final String reason;
  final DeletionRequestStatus status;
  final DateTime requestedAt;
  final DateTime? resolvedAt;

  const DeletionRequest({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientEmail,
    required this.coachId,
    this.reason = '',
    this.status = DeletionRequestStatus.pending,
    required this.requestedAt,
    this.resolvedAt,
  });

  bool get isPending => status == DeletionRequestStatus.pending;

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'coachId': coachId,
      'reason': reason,
      'status': status.name,
      'requestedAt': Timestamp.fromDate(requestedAt),
      if (resolvedAt != null) 'resolvedAt': Timestamp.fromDate(resolvedAt!),
    };
  }

  factory DeletionRequest.fromMap(Map<String, dynamic> map, String id) {
    return DeletionRequest(
      id: id,
      clientId: (map['clientId'] as String?)?.trim() ?? id,
      clientName: (map['clientName'] as String?)?.trim() ?? '',
      clientEmail: (map['clientEmail'] as String?)?.trim() ?? '',
      coachId: (map['coachId'] as String?)?.trim() ?? '',
      reason: (map['reason'] as String?)?.trim() ?? '',
      status: deletionRequestStatusFromName(map['status'] as String?),
      requestedAt: _readDate(map['requestedAt']) ?? DateTime.now(),
      resolvedAt: _readDate(map['resolvedAt']),
    );
  }
}

DateTime? _readDate(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value);
  return null;
}
