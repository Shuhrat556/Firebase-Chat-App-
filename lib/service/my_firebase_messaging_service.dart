import 'package:firebase_messaging/firebase_messaging.dart';

class MyFirebaseMessagingService {
  static Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from a terminated state
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  static void _handleMessage(RemoteMessage message) {
    // Handle the notification when app is closed or in background
    // You can navigate to specific screen based on the message
  }
}