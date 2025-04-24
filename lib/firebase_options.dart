import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError("Web platform not supported.");
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        case TargetPlatform.macOS:
        case TargetPlatform.windows:
        case TargetPlatform.linux:
        throw UnsupportedError("This platform is not supported.");
      default:
        throw UnsupportedError("DefaultFirebaseOptions not configured for this platform.");
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDe8_VaVprM4tYiCgy6h-MkkhDkWzTtq5w", // google-services.json -> apiKey
    appId: "1:667535026971:android:46579ab2c90c37548a81be", // mobilesdk_app_id
    messagingSenderId: "667535026971", // project_number
    projectId: "flutterchatapp-55b65", // project_id
    storageBucket: "flutterchatapp-55b65.firebasestorage.app", // storage_bucket
  );
}