import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
import 'edit_profile_screen.dart';
import 'vibe_settings_screen.dart';
import 'privacy_policy_screen.dart';
import 'services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userName = 'User';
  String _userEmail = 'user@example.com';
  String? _userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Try to load from Firebase Auth first
      final user = AuthService.currentUser;
      if (user != null) {
        print('👤 Loading user data from Firebase Auth: ${user.email}');
        setState(() {
          _userName = user.displayName ?? user.email?.split('@').first ?? 'User';
          _userEmail = user.email ?? 'user@example.com';
          _userPhotoUrl = user.photoURL;
        });
        print('✅ User data loaded: $_userName ($_userEmail)');
        return;
      }

      // Fallback to SharedPreferences
      print('⚠️ No Firebase user, loading from SharedPreferences');
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name') ?? 'User';
      final email = prefs.getString('user_email') ?? 'user@example.com';
      
      setState(() {
        _userName = name;
        _userEmail = email;
      });
    } catch (e) {
      print('❌ Error loading user data: $e');
      // Keep default values
    }
  }

  Future<void> _logOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Log Out',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performLogOut();
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogOut() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Clear all user data
    await prefs.remove('welcome_complete');
    await prefs.remove('vibe_setup_complete');
    await prefs.remove('profile_setup_complete');
    await prefs.remove('permissions_privacy_complete');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('selected_vibe');
    await prefs.remove('user_incomes');
    await prefs.remove('user_expenses');
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MyApp()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile & Settings header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: const Text(
                'Profile & Settings',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // User Profile Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Row(
                children: [
                  // Profile Picture
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEE2B8D).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFFEE2B8D),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFFEE2B8D),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userEmail,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Account Section
            _buildSection(
              title: 'ACCOUNT',
              items: [
                _buildSettingItem(
                  icon: Icons.edit,
                  title: 'Edit Profile',
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                    if (result == true) {
                      _loadUserData(); // Refresh user data
                    }
                  },
                ),
                _buildSettingItem(
                  icon: Icons.auto_awesome,
                  title: 'Change Mali\'s Vibe',
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VibeSettingsScreen()),
                    );
                    if (result == true) {
                      // Vibe updated successfully
                    }
                  },
                ),
                _buildSettingItem(
                  icon: Icons.link,
                  title: 'Linked Accounts',
                  onTap: () {
                    // TODO: Navigate to linked accounts
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Linked Accounts coming soon')),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Preferences Section
            _buildSection(
              title: 'PREFERENCES',
              items: [
                _buildSettingItem(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  onTap: () {
                    // TODO: Navigate to notifications settings
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notifications Settings coming soon')),
                    );
                  },
                ),
                _buildSettingItem(
                  icon: Icons.shield,
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Support Section
            _buildSection(
              title: 'SUPPORT',
              items: [
                _buildSettingItem(
                  icon: Icons.help_outline,
                  title: 'Help & FAQs',
                  onTap: () {
                    // TODO: Navigate to help
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help & FAQs coming soon')),
                    );
                  },
                ),
                _buildSettingItem(
                  icon: Icons.description,
                  title: 'Terms of Service',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Terms of Service coming soon')),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Log Out Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _logOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 16,
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

  Widget _buildSection({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFFEE2B8D),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: Column(
              children: items,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
