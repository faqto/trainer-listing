class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  final Map<String, ActiveSession> _activeSessions = {};

  void startSession(String clientId, String clientName) {
    _activeSessions[clientId] = ActiveSession(
      clientId: clientId,
      clientName: clientName,
      startedAt: DateTime.now(),
    );
  }

  void endSession(String clientId) {
    _activeSessions.remove(clientId);
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
