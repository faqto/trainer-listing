import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError('Firebase is not configured for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyADyvYaPZmw2C4L8z4VR23kZXgjW9H30nA',
    appId: '1:493199183081:android:3989ae065f100f2d057478',
    messagingSenderId: '493199183081',
    projectId: 'fited-501bc',
    authDomain: 'fited-501bc.firebaseapp.com',
    storageBucket: 'fited-501bc.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyADyvYaPZmw2C4L8z4VR23kZXgjW9H30nA',
    appId: '1:493199183081:android:3989ae065f100f2d057478',
    messagingSenderId: '493199183081',
    projectId: 'fited-501bc',
    storageBucket: 'fited-501bc.firebasestorage.app',
  );
}
