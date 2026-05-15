import 'dart:async';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();
  final Map<String, ActiveSession> _activeSessions = {};
  final _sessionController = StreamController<SessionEvent>.broadcast();
  Stream<SessionEvent> get onSessionChanged => _sessionController.stream;

  void startSession(String clientId, String clientName) {
    _activeSessions[clientId] = ActiveSession(
      clientId: clientId,
      clientName: clientName,
      startedAt: DateTime.now(),
    );

    _sessionController.add(
      SessionEvent(
        type: SessionEventType.started,
        clientId: clientId,
        clientName: clientName,
      ),
    );
  }

  void endSession(String clientId) {
    final session = _activeSessions[clientId];
    if (session != null) {
      _activeSessions.remove(clientId);

      _sessionController.add(
        SessionEvent(
          type: SessionEventType.ended,
          clientId: clientId,
          clientName: session.clientName,
          duration: DateTime.now().difference(session.startedAt),
        ),
      );
    }
  }

  bool isSessionActive(String clientId) {
    return _activeSessions.containsKey(clientId);
  }

  ActiveSession? getActiveSession(String clientId) {
    return _activeSessions[clientId];
  }

  List<ActiveSession> getAllActiveSessions() {
    return _activeSessions.values.toList();
  }

  void endAllSessions() {
    _activeSessions.clear();
  }
}

class ActiveSession {
  final String clientId;
  final String clientName;
  final DateTime startedAt;

  ActiveSession({
    required this.clientId,
    required this.clientName,
    required this.startedAt,
  });

  Duration get duration => DateTime.now().difference(startedAt);
}

enum SessionEventType { started, ended }

class SessionEvent {
  final SessionEventType type;
  final String clientId;
  final String clientName;
  final Duration? duration;

  SessionEvent({
    required this.type,
    required this.clientId,
    required this.clientName,
    this.duration,
  });
}
