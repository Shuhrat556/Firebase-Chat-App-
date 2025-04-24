import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chat/firebase_options.dart';
import 'package:chat/service/auth/auth_gate.dart';
import 'package:chat/service/auth/auth_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Endi ishlashi kerak
  );
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
