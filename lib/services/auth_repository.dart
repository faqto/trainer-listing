import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  static AuthRepository instance = FirebaseAuthRepository();

  bool get hasCurrentUser;
  String? get currentUserId;
  String get currentUserName;

  Future<void> signIn({required String email, required String password});

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String lastName,
  });

  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  static const String _separator = '|';

  @override
  bool get hasCurrentUser => _auth.currentUser != null;

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  String get currentUserName {
    final user = _auth.currentUser;
    final displayName = user?.displayName?.trim();

    if (displayName != null && displayName.isNotEmpty) {
      // New format: "lastName|fullName" → extract lastName before the separator
      if (displayName.contains(_separator)) {
        return displayName.split(_separator).first.trim();
      }
      // Legacy format fallback: grab first word
      return displayName.split(RegExp(r'\s+')).first;
    }

    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) {
      return _formatUserName(email.split('@').first).split(' ').first;
    }

    return 'Trainer';
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String lastName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final displayName = '${lastName.trim()}$_separator${name.trim()}';
    await credential.user?.updateDisplayName(displayName);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

String _formatUserName(String value) {
  final cleaned = value.trim().replaceAll(RegExp(r'[._-]+'), ' ');
  if (cleaned.isEmpty) return 'Trainer';
  return cleaned
      .split(RegExp(r'\s+'))
      .map((part) {
        if (part.isEmpty) return part;
        return part[0].toUpperCase() + part.substring(1);
      })
      .join(' ');
}
