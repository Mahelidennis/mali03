import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'test_groq_connection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
ECHO is off.
  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
ECHO is off.
  runApp(const MaterialApp(home: TestGroqConnection()));
}
