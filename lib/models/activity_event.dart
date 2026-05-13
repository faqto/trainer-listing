import 'package:flutter/material.dart';

enum ActivityType {
  bodyUpdated,
  regimeChanged,
  sessionCompleted,
  sessionMissed,
}

class ActivityEvent {
  final String id;
  final ActivityType type;
  final String clientId;
  final String clientName;
  final String description;
  final DateTime timestamp;

  //For missed sessions: whether the trainer has already resolved it
  //null = not a missed session event
  //false = unresolved (needs trainer action)
  //true = resolved
  final bool? missedResolved;

  ActivityEvent({
    required this.id,
    required this.type,
    required this.clientId,
    required this.clientName,
    required this.description,
    required this.timestamp,
    this.missedResolved,
  });

  bool get isMissedUnresolved =>
      type == ActivityType.sessionMissed && missedResolved == false;

  IconData get icon {
    switch (type) {
      case ActivityType.bodyUpdated:
        return Icons.monitor_weight_outlined;
      case ActivityType.regimeChanged:
        return Icons.fitness_center_rounded;
      case ActivityType.sessionCompleted:
        return Icons.check_circle_outline_rounded;
      case ActivityType.sessionMissed:
        return Icons.help_outline_rounded;
    }
  }

  Color get color {
    switch (type) {
      case ActivityType.bodyUpdated:
        return const Color(0xFF0EA5E9);
      case ActivityType.regimeChanged:
        return const Color(0xFF8B5CF6);
      case ActivityType.sessionCompleted:
        return const Color(0xFF10B981);
      case ActivityType.sessionMissed:
        return const Color(0xFFF59E0B);
    }
  }

  String get timeAgoLabel {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'clientId': clientId,
      'clientName': clientName,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      if (missedResolved != null) 'missedResolved': missedResolved,
    };
  }

  ActivityEvent copyWith({bool? missedResolved}) {
    return ActivityEvent(
      id: id,
      type: type,
      clientId: clientId,
      clientName: clientName,
      description: description,
      timestamp: timestamp,
      missedResolved: missedResolved ?? this.missedResolved,
    );
  }

  factory ActivityEvent.fromMap(Map<String, dynamic> map, String id) {
    return ActivityEvent(
      id: id,
      type: ActivityType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ActivityType.bodyUpdated,
      ),
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? '',
      description: map['description'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      missedResolved: map['missedResolved'] as bool?,
    );
  }
}
