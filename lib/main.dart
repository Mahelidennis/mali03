import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'main_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
    // Continue without Firebase for now
  }
  
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mali03',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFFFDF2F8), // Light pink background
        brightness: Brightness.light,
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF181114),
          elevation: 0,
          centerTitle: true,
        ),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFEE2B8D), // Hot pink
          secondary: Color(0xFFFDF2F8), // Light pink
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Color(0xFF181114),
          onSurface: Color(0xFF181114),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: Color(0xFF181114), fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: Color(0xFF181114), fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Color(0xFF181114)),
          bodyMedium: TextStyle(color: Color(0xFF575354)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEE2B8D),
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: const Color(0xFFEE2B8D).withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF4F0F2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEE2B8D), width: 2),
          ),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        brightness: Brightness.dark,
        cardColor: const Color(0xFF1A1A1A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0A0A),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFEE2B8D),
          secondary: Color(0xFF2A1A1F),
          surface: Color(0xFF1A1A1A),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Color(0xFF9CA3AF)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEE2B8D),
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: const Color(0xFFEE2B8D).withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const MainApp(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}

