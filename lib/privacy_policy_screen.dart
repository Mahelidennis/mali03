import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy Policy',
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
            // Header
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Introduction
            _buildSection(
              'Introduction',
              'Welcome to Mali, your personal financial management assistant. We are committed to protecting your privacy and ensuring the security of your personal and financial information. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
            ),
            
            const SizedBox(height: 24),
            
            // Information We Collect
            _buildSection(
              'Information We Collect',
              'We collect information you provide directly to us, such as when you create an account, use our services, or contact us for support.',
            ),
            
            _buildSubSection(
              'Personal Information',
              '• Name and contact information\n• Age and demographic information\n• Occupation and income range\n• Financial goals and preferences\n• Profile pictures (if provided)',
            ),
            
            _buildSubSection(
              'Financial Information',
              '• Income sources and amounts\n• Expense transactions and categories\n• Budget allocations and spending limits\n• Financial goals and target amounts\n• Investment and savings data',
            ),
            
            _buildSubSection(
              'Usage Information',
              '• App usage patterns and preferences\n• Feature interactions and navigation\n• Chat conversations with Mali AI\n• Notification preferences and settings\n• Device information and technical data',
            ),
            
            const SizedBox(height: 24),
            
            // How We Use Information
            _buildSection(
              'How We Use Your Information',
              'We use the information we collect to provide, maintain, and improve our services, including:',
            ),
            
            _buildSubSection(
              'Service Provision',
              '• Providing personalized financial insights and recommendations\n• Generating financial reports and analytics\n• Delivering AI-powered financial advice through Mali\n• Tracking your financial goals and progress\n• Sending relevant notifications and reminders',
            ),
            
            _buildSubSection(
              'Service Improvement',
              '• Analyzing usage patterns to improve our services\n• Developing new features and functionality\n• Personalizing your experience\n• Conducting research and analytics\n• Ensuring app security and preventing fraud',
            ),
            
            const SizedBox(height: 24),
            
            // Data Security
            _buildSection(
              'Data Security',
              'We implement industry-standard security measures to protect your information:',
            ),
            
            _buildSubSection(
              'Security Measures',
              '• End-to-end encryption for sensitive data\n• Secure data transmission protocols\n• Regular security audits and updates\n• Access controls and authentication\n• Data backup and recovery systems',
            ),
            
            _buildSubSection(
              'Local Storage',
              '• Your data is primarily stored locally on your device\n• We use secure local storage mechanisms\n• Data is encrypted before storage\n• You have full control over your data\n• No unauthorized access to your information',
            ),
            
            const SizedBox(height: 24),
            
            // Data Sharing
            _buildSection(
              'Information Sharing',
              'We do not sell, trade, or otherwise transfer your personal information to third parties, except in the following limited circumstances:',
            ),
            
            _buildSubSection(
              'Service Providers',
              '• Trusted third-party service providers who assist in app functionality\n• Cloud storage providers (with your consent)\n• Analytics services (anonymized data only)\n• Customer support platforms\n• All service providers are bound by strict confidentiality agreements',
            ),
            
            _buildSubSection(
              'Legal Requirements',
              '• When required by law or legal process\n• To protect our rights and property\n• To prevent fraud or illegal activities\n• In case of emergency or safety concerns\n• With your explicit consent',
            ),
            
            const SizedBox(height: 24),
            
            // Your Rights
            _buildSection(
              'Your Rights and Choices',
              'You have the following rights regarding your personal information:',
            ),
            
            _buildSubSection(
              'Access and Control',
              '• Access your personal information at any time\n• Update or correct your information\n• Delete your account and data\n• Export your data in a portable format\n• Opt-out of certain data processing activities',
            ),
            
            _buildSubSection(
              'Communication Preferences',
              '• Control notification settings\n• Manage email and push notification preferences\n• Opt-out of marketing communications\n• Choose your privacy settings\n• Control data sharing preferences',
            ),
            
            const SizedBox(height: 24),
            
            // Data Retention
            _buildSection(
              'Data Retention',
              'We retain your information for as long as necessary to provide our services and fulfill the purposes outlined in this Privacy Policy. Specifically:',
            ),
            
            _buildSubSection(
              'Retention Periods',
              '• Account information: Until you delete your account\n• Financial data: As long as you use our services\n• Usage data: Up to 2 years for analytics\n• Support communications: Up to 3 years\n• Legal compliance: As required by applicable laws',
            ),
            
            const SizedBox(height: 24),
            
            // Children's Privacy
            _buildSection(
              'Children\'s Privacy',
              'Our services are not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and believe your child has provided us with personal information, please contact us immediately.',
            ),
            
            const SizedBox(height: 24),
            
            // International Users
            _buildSection(
              'International Users',
              'If you are accessing our services from outside Kenya, please note that your information may be transferred to, stored, and processed in Kenya where our servers are located. By using our services, you consent to the transfer of your information to Kenya.',
            ),
            
            const SizedBox(height: 24),
            
            // Changes to Policy
            _buildSection(
              'Changes to This Privacy Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date. We encourage you to review this Privacy Policy periodically for any changes.',
            ),
            
            const SizedBox(height: 24),
            
            // Contact Information
            _buildSection(
              'Contact Us',
              'If you have any questions about this Privacy Policy or our privacy practices, please contact us:',
            ),
            
            _buildSubSection(
              'Contact Details',
              '• Email: privacy@mali-app.com\n• Phone: +254 XXX XXX XXX\n• Address: Nairobi, Kenya\n• Website: www.mali-app.com\n• Support: Available 24/7 through the app',
            ),
            
            const SizedBox(height: 32),
            
            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEE2B8D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEE2B8D).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.security,
                    color: Color(0xFFEE2B8D),
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your Privacy Matters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEE2B8D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We are committed to protecting your privacy and ensuring the security of your financial information. Your trust is our priority.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSubSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
