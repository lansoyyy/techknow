import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:techknow/firebase_options.dart';
import 'package:techknow/screens/auth/login_screen.dart';
import 'package:techknow/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'techknows-e208d',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginScreen(),
    );
  }
}
