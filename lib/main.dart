import 'package:flutter/material.dart';
import 'onboarding_page.dart';
import 'main_app.dart';
import 'user_onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

void _logOnboardingComplete() {
  // Replace this with your analytics logic (e.g., FirebaseAnalytics.instance.logEvent(...))
  debugPrint('Onboarding completed!');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mali03',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF2D3250), // Lighter navy background
        brightness: Brightness.light,
        cardColor: const Color(0xFF424769), // Lighter card background
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF7077A1),
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E), // Lighter dark mode background
        brightness: Brightness.dark,
        cardColor: const Color(0xFF2D3250), // Lighter dark card background
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF424769),
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
          bodyLarge: TextStyle(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const AppStartScreen(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}

class AppStartScreen extends StatefulWidget {
  const AppStartScreen({super.key});

  @override
  State<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen> {
  bool _hasCompletedOnboarding = false;
  bool _hasCompletedUserOnboarding = false;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      debugPrint('Checking onboarding status...');
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool('onboarding_complete') ?? false;
      final userCompleted = prefs.getBool('user_onboarding_complete') ?? false;
      
      debugPrint('Onboarding complete: $completed');
      debugPrint('User onboarding complete: $userCompleted');
      
      if (mounted) {
        setState(() {
          _hasCompletedOnboarding = completed;
          _hasCompletedUserOnboarding = userCompleted;
          _isLoading = false;
        });
        debugPrint('Loading state set to false');
      }
    } catch (e) {
      debugPrint('Error checking onboarding status: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building AppStartScreen - Loading: $_isLoading, Onboarding: $_hasCompletedOnboarding, UserOnboarding: $_hasCompletedUserOnboarding, Error: $_hasError');
    
    if (_hasError) {
      debugPrint('Showing error screen');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Please refresh the page'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                  });
                  _checkOnboardingStatus();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_isLoading) {
      debugPrint('Showing loading screen');
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasCompletedOnboarding) {
      debugPrint('Showing onboarding screen');
      return OnboardingScreen(onComplete: _logOnboardingComplete);
    }

    if (!_hasCompletedUserOnboarding) {
      debugPrint('Showing user onboarding screen');
      return const UserOnboardingScreen();
    }

    debugPrint('Showing main app');
    return const MainApp();
  }
}
