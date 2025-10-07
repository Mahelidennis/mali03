import 'package:flutter/material.dart';
import '../../services/onboarding_service.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const WelcomeScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;

  Future<void> _handleGetStarted() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await OnboardingService.instance.completeWelcome();
      widget.onComplete();
    } catch (e) {
      // Handle error - could show a snackbar
      print('Error completing welcome: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Top spacing
              const SizedBox(height: 60),
              
              // Welcome content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Waving hand emoji
                    const Text(
                      '👋',
                      style: TextStyle(fontSize: 80),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Main heading
                    const Text(
                      'Hey there, future boss babe! 💅',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF181114),
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Description text
                    const Text(
                      'Meet Mali, your financial big sister. I\'m here to help you slay your money goals and build the empire you deserve. Let\'s get started! 🚀',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF181114),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Get Started button
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleGetStarted,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEE2B8D),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
