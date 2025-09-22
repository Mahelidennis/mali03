import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../main_app.dart';
import 'login_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  String? _successMessage;
  int _resendCount = 0;
  int _maxResends = 3;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  Future<void> _checkEmailVerification() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if email is verified
      await Future.delayed(const Duration(seconds: 2)); // Simulate check delay
      
      if (AuthService.isEmailVerified) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainApp()),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error checking verification status: ${e.toString()}';
      });
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_resendCount >= _maxResends) {
      _showErrorSnackBar('Maximum resend attempts reached. Please try again later.');
      return;
    }

    setState(() {
      _isResending = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await AuthService.resendEmailVerification();

      if (result.success) {
        setState(() {
          _successMessage = 'Verification email sent! Check your inbox.';
          _resendCount++;
        });
      } else {
        setState(() {
          _errorMessage = result.message ?? result.error?.message ?? 'Failed to send verification email';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error sending verification email: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  Future<void> _refreshVerificationStatus() async {
    await _checkEmailVerification();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              
              // Main content
              _buildMainContent(),
              
              const Spacer(),
              
              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // Email icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFEE2B8D).withOpacity(0.1),
            borderRadius: BorderRadius.circular(60),
          ),
          child: const Icon(
            Icons.email_outlined,
            size: 60,
            color: Color(0xFFEE2B8D),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Title
        Text(
          'Verify Your Email',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF181114),
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        // Description
        Text(
          'We\'ve sent a verification link to',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF575354),
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        // Email address
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFEE2B8D).withOpacity(0.3)),
          ),
          child: Text(
            widget.email,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFEE2B8D),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Instructions
        Text(
          'Please check your email and click the verification link to activate your account.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF575354),
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 32),
        
        // Loading indicator or messages
        if (_isLoading) ...[
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEE2B8D)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Checking verification status...',
            style: TextStyle(color: Color(0xFF575354)),
          ),
        ] else if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ] else if (_successMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _successMessage!,
                    style: const TextStyle(color: Colors.green, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        if (_resendCount > 0) ...[
          const SizedBox(height: 16),
          Text(
            'Resend attempts: $_resendCount/$_maxResends',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Resend email button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _isResending || _resendCount >= _maxResends ? null : _resendVerificationEmail,
            icon: _isResending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh),
            label: Text(
              _isResending ? 'Sending...' : 'Resend Verification Email',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEE2B8D),
              foregroundColor: Colors.white,
              elevation: 8,
              shadowColor: const Color(0xFFEE2B8D).withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Refresh status button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _refreshVerificationStatus,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('I\'ve Verified My Email'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEE2B8D),
              side: const BorderSide(color: Color(0xFFEE2B8D)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Back to login button
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          },
          child: const Text(
            'Back to Sign In',
            style: TextStyle(
              color: Color(0xFF575354),
            ),
          ),
        ),
      ],
    );
  }
}
