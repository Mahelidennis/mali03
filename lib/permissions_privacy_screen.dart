import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/mali_logo.dart';
import 'main_app.dart';
import 'privacy_policy_screen.dart';

class PermissionsPrivacyScreen extends StatefulWidget {
  const PermissionsPrivacyScreen({super.key});

  @override
  State<PermissionsPrivacyScreen> createState() => _PermissionsPrivacyScreenState();
}

class _PermissionsPrivacyScreenState extends State<PermissionsPrivacyScreen> {
  bool _notificationsEnabled = false;
  bool _dataAnalyticsEnabled = true;
  bool _personalizedAdsEnabled = false;
  bool _locationEnabled = false;
  bool _biometricEnabled = false;
  bool _hasCompletedSetup = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        title: Text(
          'Permissions & Privacy',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            const Center(
              child: MaliLogo(
                width: 100,
                height: 50,
              ),
            ),
            const SizedBox(height: 40),
            // Padlock icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFEE2B8D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.lock,
                  size: 40,
                  color: Color(0xFFEE2B8D),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Header
            Text(
              'Your Privacy is Our Priority',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            // Body text
            Text(
              'Mali needs access to your transaction history to work her magic. This lets us automatically track your spending, spot trends, and give you personalized advice to boss up your finances.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'We use bank-level encryption to keep your data safe. Think of it as a digital fortress. Your trust means everything to us. Read our full ',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                  );
                },
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFFEE2B8D),
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // Agree & Continue button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _hasCompletedSetup ? null : _completeSetup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEE2B8D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _hasCompletedSetup
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Agree & Continue',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Manage Permissions Later button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: _hasCompletedSetup ? null : _completeSetup,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Manage Permissions Later',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }


  Future<void> _completeSetup() async {
    setState(() {
      _hasCompletedSetup = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save all preferences
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
      await prefs.setBool('data_analytics_enabled', _dataAnalyticsEnabled);
      await prefs.setBool('personalized_ads_enabled', _personalizedAdsEnabled);
      await prefs.setBool('location_enabled', _locationEnabled);
      await prefs.setBool('biometric_enabled', _biometricEnabled);
      await prefs.setBool('permissions_privacy_complete', true);
      
      // Mark onboarding as complete
      await prefs.setBool('onboarding_complete', true);
      await prefs.setBool('user_onboarding_complete', true);
      await prefs.setBool('welcome_complete', true);
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainApp()),
        );
      }
    } catch (e) {
      setState(() {
        _hasCompletedSetup = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
