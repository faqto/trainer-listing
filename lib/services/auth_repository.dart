import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_role.dart';
import 'package:http/http.dart' as http;

abstract class AuthRepository {
  static AuthRepository instance = FirebaseAuthRepository();

  bool get hasCurrentUser;
  bool get isEmailVerified;
  String? get currentUserId;
  String? get currentUserEmail;
  String get currentUserName;
  String get currentUserLastName;
  UserRole? get currentUserRole;

  Future<UserRole> loadCurrentUserRole();

  Future<void> signIn({
    required String email,
    required String password,
    required UserRole role,
  });

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String lastName,
    required UserRole role,
  });

  Future<void> sendVerificationEmail();

  Future<void> reloadUser();

  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  static const String _separator = '|';
  UserRole? _cachedRole;
  String? _cachedName;
  String? _cachedLastName;
  String? _cachedEmail;
  static const String _serverUrl = 'https://fited-email-server.onrender.com';

  @override
  bool get hasCurrentUser {
    final signedIn = _auth.currentUser != null;
    if (!signedIn) _clearCache();
    return signedIn;
  }

  @override
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  String? get currentUserEmail =>
      _cachedEmail ?? _auth.currentUser?.email?.trim();

  @override
  String get currentUserName {
    if (_cachedName != null && _cachedName!.trim().isNotEmpty) {
      return _cachedName!.trim();
    }

    final user = _auth.currentUser;
    final name = _nameFromDisplayName(user?.displayName);
    if (name.isNotEmpty) return name;

    final email = currentUserEmail;
    if (email != null && email.isNotEmpty) {
      return _formatUserName(email.split('@').first);
    }

    return _cachedRole == UserRole.client ? 'Client' : 'Trainer';
  }

  @override
  String get currentUserLastName {
    if (_cachedLastName != null && _cachedLastName!.trim().isNotEmpty) {
      return _cachedLastName!.trim();
    }

    final displayName = _auth.currentUser?.displayName?.trim();
    if (displayName != null &&
        displayName.isNotEmpty &&
        displayName.contains(_separator)) {
      return displayName.split(_separator).first.trim().replaceAll(',', '');
    }

    final parts = currentUserName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    return parts.isEmpty ? currentUserName : parts.last;
  }

  @override
  UserRole? get currentUserRole => _cachedRole;

  @override
  Future<UserRole> loadCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Please sign in before loading your profile.',
      );
    }

    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    if (!snapshot.exists || snapshot.data() == null) {
      final role = UserRole.coach;
      await _saveUserProfile(
        user: user,
        name: currentUserName,
        lastName: currentUserLastName,
        role: role,
        isNew: true,
      );
      return role;
    }

    final data = snapshot.data()!;
    final role = userRoleFromName(data['role'] as String?);
    _cacheProfile(data, user, role);
    return role;
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
    required UserRole role,
  }) async {
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
    await _syncSignedInUser(credential.user, role);
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String lastName,
    required UserRole role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final displayName = name.trim();
    await credential.user?.updateDisplayName(displayName);

    await _saveUserProfile(
      user: credential.user,
      name: name,
      lastName: lastName,
      role: role,
      isNew: true,
    );

    await _sendVerificationViaServer(credential.user!.email!);

    await _auth.signOut();
  }

  Future<void> _syncSignedInUser(User? user, UserRole selectedRole) async {
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists || snapshot.data() == null) {
      await _saveUserProfile(
        user: user,
        name: _nameFromDisplayName(user.displayName),
        lastName: _lastNameFromDisplayName(user.displayName),
        role: selectedRole,
        isNew: true,
      );
      return;
    }

    final data = snapshot.data()!;
    final actualRole = userRoleFromName(data['role'] as String?);
    if (actualRole != selectedRole) {
      await _auth.signOut();
      _clearCache();
      throw FirebaseAuthException(
        code: 'role-mismatch',
        message:
            'This account is registered as a ${actualRole.label.toLowerCase()}. Select ${actualRole.label} to sign in.',
      );
    }

    _cacheProfile(data, user, actualRole);
  }

  Future<void> _saveUserProfile({
    required User? user,
    required String name,
    required String lastName,
    required UserRole role,
    required bool isNew,
  }) async {
    if (user == null) return;

    final cleanName = name.trim().isNotEmpty
        ? name.trim()
        : _formatUserName(user.email?.split('@').first ?? '');
    final cleanLastName = lastName.trim();
    final data = <String, dynamic>{
      'name': cleanName.isEmpty ? role.label : cleanName,
      'lastName': cleanLastName,
      'email': user.email?.trim() ?? '',
      'role': role.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (isNew) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(data, SetOptions(merge: true));
    _cacheProfile(data, user, role);
  }

  void _cacheProfile(Map<String, dynamic> data, User user, UserRole role) {
    _cachedRole = role;
    _cachedName = (data['name'] as String?)?.trim();
    _cachedLastName = (data['lastName'] as String?)?.trim();
    _cachedEmail = (data['email'] as String?)?.trim() ?? user.email?.trim();
  }

  void _clearCache() {
    _cachedRole = null;
    _cachedName = null;
    _cachedLastName = null;
    _cachedEmail = null;
  }

  Future<void> _sendVerificationViaServer(String email) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await user.sendEmailVerification();

    try {
      await http.post(
        Uri.parse('$_serverUrl/send-verification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
    } catch (_) {
    }
  }

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
    _clearCache();
    await _auth.signOut();
  }
}

String _nameFromDisplayName(String? value) {
  final displayName = value?.trim() ?? '';
  if (displayName.isEmpty) return '';
  if (!displayName.contains(FirebaseAuthRepository._separator)) {
    return displayName;
  }

  final parts = displayName.split(FirebaseAuthRepository._separator);
  if (parts.length < 2) return parts.first.trim();
  return parts.sublist(1).join(FirebaseAuthRepository._separator).trim();
}

String _lastNameFromDisplayName(String? value) {
  final displayName = value?.trim() ?? '';
  if (displayName.isEmpty) return '';
  if (displayName.contains(FirebaseAuthRepository._separator)) {
    return displayName
        .split(FirebaseAuthRepository._separator)
        .first
        .trim()
        .replaceAll(',', '');
  }

  final parts = displayName
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  return parts.isEmpty ? '' : parts.last;
}

String _formatUserName(String value) {
  final cleaned = value.trim().replaceAll(RegExp(r'[._-]+'), ' ');
  if (cleaned.isEmpty) return '';
  return cleaned
      .split(RegExp(r'\s+'))
      .map((part) {
        if (part.isEmpty) return part;
        return part[0].toUpperCase() + part.substring(1);
      })
      .join(' ');
}