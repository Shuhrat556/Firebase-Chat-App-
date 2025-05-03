import 'package:chat/service/auth/auth_gate.dart';
import 'package:chat/service/my_firebase_messaging_service.dart';
import 'package:chat/service/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chat/service/auth/auth_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set up notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  await MyFirebaseMessagingService.setupInteractedMessage();
  runApp(
    ChangeNotifierProvider(create: (context) => AuthService(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AuthGate(),
    );
  }
}
