import 'package:firebase_core/firebase_core.dart';

String clientLoadErrorMessage(Object? error) {
  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return 'Firestore blocked client access. Update your Firestore rules for signed-in users.';
      case 'unauthenticated':
        return 'Please sign in again before loading clients.';
      case 'not-found':
        return 'Firestore database was not found for this Firebase project.';
      default:
        return error.message ?? 'Unable to load clients.';
    }
  }

  return 'Unable to load clients: $error';
}

String clientSaveErrorMessage(FirebaseException error) {
  switch (error.code) {
    case 'permission-denied':
      return 'Firestore blocked this save. Check your database rules.';
    case 'unavailable':
      return 'Firestore is unavailable right now. Check your connection.';
    case 'not-found':
      return 'Firestore database was not found for this Firebase project.';
    default:
      return error.message ?? 'Unable to save client. Please try again.';
  }
}
