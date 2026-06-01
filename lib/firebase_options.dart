import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return const FirebaseOptions(
          apiKey: String.fromEnvironment('FIREBASE_API_KEY', defaultValue: 'replace-me'),
          appId: String.fromEnvironment('FIREBASE_APP_ID', defaultValue: 'replace-me'),
          messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: 'replace-me'),
          projectId: String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: 'replace-me'),
        );
    }
  }
}
