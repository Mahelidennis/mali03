import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_app.dart';
import 'welcome_screen.dart';
import 'set_vibe_screen.dart';
import 'user_profile_setup_screen.dart';
import 'permissions_privacy_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        scaffoldBackgroundColor: const Color(0xFFFDF2F8),
        brightness: Brightness.light,
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF181114),
          elevation: 0,
          centerTitle: true,
        ),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFEE2B8D),
          secondary: Color(0xFFFDF2F8),
          surface: Colors.white,
          background: Color(0xFFFDF2F8),
          onPrimary: Colors.white,
          onSecondary: Color(0xFF181114),
          onSurface: Color(0xFF181114),
          onBackground: Color(0xFF181114),
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
            shadowColor: const Color(0xFFEE2B8D).withOpacity(0.3),
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
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEE2B8D), width: 2),
          ),
        ),
      ),
      home: const AppStartScreen(),
    );
  }
}

class AppStartScreen extends StatefulWidget {
  const AppStartScreen({super.key});

  @override
  State<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen> {
  bool _hasCompletedWelcome = false;
  bool _hasCompletedVibeSetup = false;
  bool _hasCompletedProfileSetup = false;
  bool _hasCompletedPermissions = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final welcomeCompleted = prefs.getBool('welcome_complete') ?? false;
      final vibeCompleted = prefs.getBool('vibe_setup_complete') ?? false;
      final profileCompleted = prefs.getBool('profile_setup_complete') ?? false;
      final permissionsCompleted = prefs.getBool('permissions_privacy_complete') ?? false;
      
      if (mounted) {
        setState(() {
          _hasCompletedWelcome = welcomeCompleted;
          _hasCompletedVibeSetup = vibeCompleted;
          _hasCompletedProfileSetup = profileCompleted;
          _hasCompletedPermissions = permissionsCompleted;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasCompletedWelcome) {
      return const WelcomeScreen();
    }

    if (!_hasCompletedVibeSetup) {
      return const SetVibeScreen();
    }

    if (!_hasCompletedProfileSetup) {
      return const UserProfileSetupScreen();
    }

    if (!_hasCompletedPermissions) {
      return const PermissionsPrivacyScreen();
    }

    return const MainApp();
  }
}
