import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:rojgaar/screens/auth_screen.dart';
import 'package:rojgaar/screens/home_page.dart'; // Import HomePage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const RojgaarApp());
}


class RojgaarApp extends StatelessWidget {
  const RojgaarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rojgaar App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthScreen(), // Start with authentication
    );
  }
}
