import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/onboarding_service.dart';

class PermissionsScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const PermissionsScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _isLoading = false;

  Future<void> _launchPrivacyPolicy() async {
    const privacyUrl = 'https://mali-prod.web.app/privacy-policy';
    try {
      final Uri url = Uri.parse(privacyUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error launching privacy policy: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open privacy policy'),
            backgroundColor: Color(0xFFEE2B8D),
          ),
        );
      }
    }
  }

  Future<void> _handleAgreeAndContinue() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await OnboardingService.instance.acceptPermissions();
      await OnboardingService.instance.completeOnboarding();
      widget.onComplete();
    } catch (e) {
      print('Error accepting permissions: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleManageLater() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await OnboardingService.instance.completeOnboarding();
      widget.onComplete();
    } catch (e) {
      print('Error skipping permissions: $e');
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.close,
              color: Color(0xFF181114),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Top spacing
              const SizedBox(height: 40),
              
              // Lock icon
              const Text(
                '🔒',
                style: TextStyle(fontSize: 80),
              ),
              
              const SizedBox(height: 32),
              
              // Main heading
              const Text(
                'Your Privacy is Our Priority',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF181114),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Description text
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Mali needs access to your transaction history to work her magic. This lets us automatically track your spending, spot trends, and give you personalized advice to boss up your finances.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF181114),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF181114),
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(
                            text: 'We use bank-level encryption to keep your data safe. Think of it as a digital fortress. Your trust means everything to us. Read our full ',
                          ),
                          TextSpan(
                            text: 'Privacy Policy.',
                            style: TextStyle(
                              color: Color(0xFFEE2B8D),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Buttons
              Column(
                children: [
                  // Agree & Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleAgreeAndContinue,
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
                              'Agree & Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Manage Permissions Later button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _handleManageLater,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF181114),
                        side: const BorderSide(
                          color: Color(0xFFE5E7EB),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Manage Permissions Later',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
