import 'package:flutter/material.dart';
import '../services/sms_service_factory.dart';
import '../widgets/mali_logo.dart';

class SmsPermissionScreen extends StatefulWidget {
  const SmsPermissionScreen({super.key});

  @override
  State<SmsPermissionScreen> createState() => _SmsPermissionScreenState();
}

class _SmsPermissionScreenState extends State<SmsPermissionScreen> {
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              
              // Mali Logo
              const MaliLogo(
                width: 120,
                height: 60,
                textSize: 24,
              ),
              
              const SizedBox(height: 32),
              
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
        // Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFEE2B8D).withOpacity(0.1),
            borderRadius: BorderRadius.circular(60),
          ),
          child: const Icon(
            Icons.sms,
            size: 60,
            color: Color(0xFFEE2B8D),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Title
        Text(
          'Enable Automatic Tracking',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF181114),
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        // Description
        Text(
          'Mali can automatically track your M-PESA transactions by reading SMS messages. This helps us provide better insights and recommendations.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF575354),
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 24),
        
        // Benefits
        _buildBenefitsList(),
        
        const SizedBox(height: 24),
        
        // Privacy note
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.security,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your SMS messages are processed locally on your device and never stored in their original form.',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        if (_statusMessage.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _statusMessage.contains('Error') 
                  ? Colors.red.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _statusMessage.contains('Error')
                    ? Colors.red.withOpacity(0.3)
                    : Colors.green.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _statusMessage.contains('Error') 
                      ? Icons.error_outline
                      : Icons.check_circle_outline,
                  color: _statusMessage.contains('Error') 
                      ? Colors.red
                      : Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      color: _statusMessage.contains('Error') 
                          ? Colors.red
                          : Colors.green,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBenefitsList() {
    final benefits = [
      'Automatic transaction tracking',
      'Real-time spending insights',
      'Better financial recommendations',
      'No manual data entry needed',
    ];

    return Column(
      children: benefits.map((benefit) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Color(0xFFEE2B8D),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                benefit,
                style: const TextStyle(
                  color: Color(0xFF575354),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Enable tracking button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _enableTracking,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEE2B8D),
              foregroundColor: Colors.white,
              elevation: 8,
              shadowColor: const Color(0xFFEE2B8D).withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Enable Automatic Tracking',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Skip button
        TextButton(
          onPressed: _isLoading ? null : _skipTracking,
          child: const Text(
            'Skip for Now',
            style: TextStyle(
              color: Color(0xFF575354),
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _enableTracking() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      // Request SMS permission
      final granted = await SmsServiceFactory.requestSmsPermission();
      
      if (granted) {
        setState(() {
          _statusMessage = 'SMS tracking enabled successfully!';
        });
        
        // Wait a moment to show success message
        await Future.delayed(const Duration(seconds: 2));
        
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } else {
        setState(() {
          _statusMessage = 'Error: SMS permission denied. You can enable it later in settings.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: Failed to enable SMS tracking. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _skipTracking() {
    Navigator.of(context).pop(false); // Return false to indicate skip
  }
}
