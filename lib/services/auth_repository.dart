import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

abstract class AuthRepository {
  static AuthRepository instance = FirebaseAuthRepository();

  bool get hasCurrentUser;
  bool get isEmailVerified;
  String? get currentUserId;
  String get currentUserName;

  Future<void> signIn({required String email, required String password});

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String lastName,
  });

  Future<void> sendVerificationEmail();

  Future<void> reloadUser();

  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  static const String _separator = '|';
  static const String _serverUrl = 'https://fited-email-server.onrender.com';

  @override
  bool get hasCurrentUser => _auth.currentUser != null;

  @override
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  String get currentUserName {
    final user = _auth.currentUser;
    final displayName = user?.displayName?.trim();

    if (displayName != null && displayName.isNotEmpty) {
      if (displayName.contains(_separator)) {
        return displayName.split(_separator).first.trim().replaceAll(',', '');
      }
      return displayName.split(RegExp(r'\s+')).first.replaceAll(',', '');
    }

    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) {
      return _formatUserName(email.split('@').first).split(' ').first;
    }

    return 'Trainer';
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user?.emailVerified == false) {
      await _sendVerificationViaServer(credential.user!.email!);
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'email-not-verified',
        message:
            'Your email isn\'t verified yet. We\'ve sent a new verification link to $email — check your inbox.',
      );
    }
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

    // Send verification email via Resend (better inbox delivery)
    await _sendVerificationViaServer(credential.user!.email!);

    // Sign out immediately — Firestore write happens only after verification.
    await _auth.signOut();
  }

  // Calls Firebase to send the verification email directly.
  // Falls back cleanly if anything goes wrong.
  Future<void> _sendVerificationViaServer(String email) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Firebase sends the verification link — we trigger it here
    // and separately notify via Resend with a heads-up email.
    await user.sendEmailVerification();

    // Send a companion email via Resend so it lands in inbox
    // instead of spam. The actual verify button comes from Firebase.
    try {
      await http.post(
        Uri.parse('$_serverUrl/send-verification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
    } catch (_) {
      // Non-fatal — Firebase already sent the link above
    }
  }

  // Temporarily stored so we can re-authenticate on the verification page
  // without asking the user to type their password again.
  String? _pendingEmail;
  String? _pendingPassword;

  void storePendingCredentials(String email, String password) {
    _pendingEmail = email;
    _pendingPassword = password;
  }

  void clearPendingCredentials() {
    _pendingEmail = null;
    _pendingPassword = null;
  }

  @override
  Future<void> sendVerificationEmail() async {
    if (_auth.currentUser == null &&
        _pendingEmail != null &&
        _pendingPassword != null) {
      final credential = await _auth.signInWithEmailAndPassword(
        email: _pendingEmail!,
        password: _pendingPassword!,
      );
      await _sendVerificationViaServer(credential.user!.email!);
      await _auth.signOut();
    } else if (_auth.currentUser != null) {
      await _sendVerificationViaServer(_auth.currentUser!.email!);
    }
  }

  @override
  Future<void> reloadUser() async {
    if (_auth.currentUser == null &&
        _pendingEmail != null &&
        _pendingPassword != null) {
      final credential = await _auth.signInWithEmailAndPassword(
        email: _pendingEmail!,
        password: _pendingPassword!,
      );
      await credential.user?.reload();
      // Stay signed in only if verified so isEmailVerified returns true
      if (credential.user?.emailVerified == false) {
        await _auth.signOut();
      } else {
        clearPendingCredentials();
      }
    } else {
      await _auth.currentUser?.reload();
    }
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
