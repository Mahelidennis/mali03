import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/auth_models.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'profile_management_screen.dart';

class AuthTestScreen extends StatefulWidget {
  const AuthTestScreen({super.key});

  @override
  State<AuthTestScreen> createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends State<AuthTestScreen> {
  bool _isLoading = false;
  String _status = 'Ready to test';
  List<String> _testResults = [];
  AuthState? _currentAuthState;

  @override
  void initState() {
    super.initState();
    _loadAuthState();
  }

  void _loadAuthState() {
    setState(() {
      _currentAuthState = AuthService.currentState;
    });
  }

  void _addResult(String result) {
    setState(() {
      _testResults.add('${DateTime.now().toString().substring(11, 19)} - $result');
    });
  }

  void _setStatus(String status) {
    setState(() {
      _status = status;
    });
  }

  Future<void> _testAnonymousSignIn() async {
    setState(() {
      _isLoading = true;
      _setStatus('Testing anonymous sign in...');
    });

    try {
      final result = await AuthService.signInAnonymously();
      if (result.success) {
        _addResult('✅ Anonymous sign in successful');
        _loadAuthState();
      } else {
        _addResult('❌ Anonymous sign in failed: ${result.message}');
      }
    } catch (e) {
      _addResult('❌ Anonymous sign in error: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _setStatus('Anonymous sign in test completed');
      });
    }
  }

  Future<void> _testSignOut() async {
    setState(() {
      _isLoading = true;
      _setStatus('Testing sign out...');
    });

    try {
      final result = await AuthService.signOut();
      if (result.success) {
        _addResult('✅ Sign out successful');
        _loadAuthState();
      } else {
        _addResult('❌ Sign out failed: ${result.message}');
      }
    } catch (e) {
      _addResult('❌ Sign out error: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _setStatus('Sign out test completed');
      });
    }
  }

  Future<void> _testGetUserProfile() async {
    setState(() {
      _isLoading = true;
      _setStatus('Testing get user profile...');
    });

    try {
      final profile = await AuthService.getUserProfile();
      if (profile != null) {
        _addResult('✅ User profile retrieved: ${profile.email}');
      } else {
        _addResult('⚠️ No user profile found');
      }
    } catch (e) {
      _addResult('❌ Get user profile error: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _setStatus('Get user profile test completed');
      });
    }
  }

  Future<void> _testAuthState() async {
    setState(() {
      _isLoading = true;
      _setStatus('Testing auth state...');
    });

    try {
      final isSignedIn = AuthService.isSignedIn;
      final isEmailVerified = AuthService.isEmailVerified;
      final isAnonymous = AuthService.isAnonymous;
      final currentUser = AuthService.currentUser;

      _addResult('✅ Auth state check:');
      _addResult('   - Signed in: $isSignedIn');
      _addResult('   - Email verified: $isEmailVerified');
      _addResult('   - Anonymous: $isAnonymous');
      _addResult('   - User ID: ${currentUser?.uid ?? 'None'}');
      _addResult('   - Email: ${currentUser?.email ?? 'None'}');
    } catch (e) {
      _addResult('❌ Auth state error: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _setStatus('Auth state test completed');
      });
    }
  }

  Future<void> _testPasswordReset() async {
    setState(() {
      _isLoading = true;
      _setStatus('Testing password reset...');
    });

    try {
      final testEmail = 'test@example.com';
      final result = await AuthService.sendPasswordResetEmail(
        PasswordResetData(email: testEmail),
      );
      
      if (result.success) {
        _addResult('✅ Password reset email sent to $testEmail');
      } else {
        _addResult('❌ Password reset failed: ${result.message}');
      }
    } catch (e) {
      _addResult('❌ Password reset error: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _setStatus('Password reset test completed');
      });
    }
  }

  Future<void> _testUpdateProfile() async {
    setState(() {
      _isLoading = true;
      _setStatus('Testing update profile...');
    });

    try {
      final result = await AuthService.updateProfile(
        displayName: 'Test User ${DateTime.now().millisecondsSinceEpoch}',
      );
      
      if (result.success) {
        _addResult('✅ Profile updated successfully');
        _loadAuthState();
      } else {
        _addResult('❌ Profile update failed: ${result.message}');
      }
    } catch (e) {
      _addResult('❌ Profile update error: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _setStatus('Profile update test completed');
      });
    }
  }

  Future<void> _clearTestResults() async {
    setState(() {
      _testResults.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication Test'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAuthState,
            tooltip: 'Refresh Auth State',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              color: _isLoading ? Colors.orange : Colors.green,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _isLoading ? Icons.hourglass_empty : Icons.check_circle,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Auth State Info
            if (_currentAuthState != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Auth State',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Authenticated: ${_currentAuthState!.isAuthenticated}'),
                      Text('Email Verified: ${_currentAuthState!.isEmailVerified}'),
                      Text('Anonymous: ${_currentAuthState!.isAnonymous}'),
                      Text('User ID: ${_currentAuthState!.user?.uid ?? 'None'}'),
                      Text('Email: ${_currentAuthState!.user?.email ?? 'None'}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Test Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTestButton(
                  'Anonymous Sign In',
                  Icons.person,
                  Colors.blue,
                  _testAnonymousSignIn,
                ),
                _buildTestButton(
                  'Sign Out',
                  Icons.logout,
                  Colors.red,
                  _testSignOut,
                ),
                _buildTestButton(
                  'Get User Profile',
                  Icons.person_outline,
                  Colors.green,
                  _testGetUserProfile,
                ),
                _buildTestButton(
                  'Check Auth State',
                  Icons.info,
                  Colors.orange,
                  _testAuthState,
                ),
                _buildTestButton(
                  'Test Password Reset',
                  Icons.lock_reset,
                  Colors.purple,
                  _testPasswordReset,
                ),
                _buildTestButton(
                  'Update Profile',
                  Icons.edit,
                  Colors.teal,
                  _testUpdateProfile,
                ),
                _buildTestButton(
                  'Go to Login',
                  Icons.login,
                  Colors.indigo,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  ),
                ),
                _buildTestButton(
                  'Go to Register',
                  Icons.person_add,
                  Colors.pink,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  ),
                ),
                _buildTestButton(
                  'Profile Management',
                  Icons.settings,
                  Colors.grey,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileManagementScreen()),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Test Results
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.list_alt),
                          const SizedBox(width: 8),
                          const Text(
                            'Test Results',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (_testResults.isNotEmpty)
                            TextButton(
                              onPressed: _clearTestResults,
                              child: const Text('Clear'),
                            ),
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _testResults.length,
                          itemBuilder: (context, index) {
                            final result = _testResults[index];
                            final isError = result.startsWith('❌');
                            final isSuccess = result.startsWith('✅');
                            final isWarning = result.startsWith('⚠️');
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                result,
                                style: TextStyle(
                                  color: isError 
                                      ? Colors.red 
                                      : isSuccess 
                                          ? Colors.green 
                                          : isWarning
                                              ? Colors.orange
                                              : Colors.black87,
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(String title, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : onPressed,
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey,
      ),
    );
  }
}
