import 'package:flutter/material.dart';
import 'mali_chat_screen.dart';
import 'home_screen.dart';
import 'screens/finance_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/profile_management_screen.dart';
import 'screens/migration_screen.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'services/auth_service.dart';
import 'services/migration_service.dart';
import 'models/auth_models.dart';
import 'widgets/mali_logo.dart';
import 'notification_center_screen.dart';
import 'settings_screen.dart';
import 'screens/sms_permission_screen.dart';
import 'screens/sms_insights_screen.dart';
import 'services/sms_service_factory.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;
  AuthState? _authState;
  bool _isLoading = true;

  final List<Widget> _screens = [
    const HomeScreen(),
    const FinanceScreen(), // Combined expenses, income, and reports
    const GoalsScreen(), // Combined goals and budget tracking
    const MaliChatScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    await AuthService.initialize();
    
    // Listen to auth state changes
    AuthService.authStateChanges.listen((AuthState state) {
      if (mounted) {
        setState(() {
          _authState = state;
          _isLoading = false;
        });
        
        // Check for migration if user is authenticated
        if (state.isAuthenticated) {
          _checkMigration();
          _checkSmsPermission();
        }
      }
    });
  }

  Future<void> _checkMigration() async {
    try {
      final needsMigration = await MigrationService.isMigrationNeeded();
      if (needsMigration && mounted) {
        // Show migration screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const MigrationScreen(),
          ),
        );
      }
    } catch (e) {
      print('Error checking migration: $e');
    }
  }

  Future<void> _checkSmsPermission() async {
    try {
      final hasConsent = await SmsServiceFactory.hasUserConsent();
      final hasPermission = await SmsServiceFactory.hasSmsPermission();
      
      // If user hasn't given consent yet, show permission screen
      if (!hasConsent && mounted) {
        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (context) => const SmsPermissionScreen(),
          ),
        );
        
        // If user enabled tracking, start scanning
        if (result == true) {
          _startSmsScanning();
        }
      } else if (hasPermission) {
        // If permission is already granted, start scanning
        _startSmsScanning();
      }
    } catch (e) {
      print('Error checking SMS permission: $e');
    }
  }

  Future<void> _startSmsScanning() async {
    try {
      // Scan for M-PESA transactions
      final transactions = await SmsServiceFactory.scanMpesaTransactions();
      
      if (transactions.isNotEmpty) {
        // Save transactions
        await SmsServiceFactory.saveTransactions(transactions);
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Found ${transactions.length} new M-PESA transactions'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('Error scanning SMS transactions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEE2B8D)),
          ),
        ),
      );
    }

    // Wrap the main app with onboarding flow
    return OnboardingWrapper(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFEE2B8D),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
          ),
          elevation: 0,
                  items: [
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.home, size: 24),
                      label: 'Home',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.account_balance_wallet, size: 24),
                      label: 'Finance',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.emoji_events, size: 24),
                      label: 'Goals',
                    ),
                    BottomNavigationBarItem(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEE2B8D).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.psychology,
                          size: 24,
                          color: Color(0xFFEE2B8D),
                        ),
                      ),
                      label: 'Mali',
                    ),
                  ],
        ),
      ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final isAuthenticated = _authState?.isAuthenticated ?? false;
    final isAnonymous = _authState?.isAnonymous ?? true;
    final userEmail = _authState?.user?.email;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
               const MaliLogo(
                 width: 250,
                 height: 150,
                 textSize: 32,
               ),
          const SizedBox(width: 12),
          if (isAnonymous) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Text(
                'Guest Mode',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        // Notification icon
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationCenterScreen()),
                );
              },
            ),
            // Add notification badge here if needed
          ],
        ),
        // Settings icon
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.black87),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
        if (isAuthenticated && !isAnonymous) ...[
          // Authenticated user menu
          PopupMenuButton<String>(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFEE2B8D).withOpacity(0.1),
              child: Text(
                userEmail?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  color: Color(0xFFEE2B8D),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  _navigateToProfileManagement();
                  break;
                case 'sms_insights':
                  _navigateToSmsInsights();
                  break;
                case 'signout':
                  _signOut();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Color(0xFFEE2B8D)),
                    const SizedBox(width: 8),
                    const Text('Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sms_insights',
                child: Row(
                  children: [
                    const Icon(Icons.sms, color: Color(0xFFEE2B8D)),
                    const SizedBox(width: 8),
                    const Text('SMS Insights'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
        ] else ...[
          // Guest user menu
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.account_circle_outlined,
              color: Color(0xFFEE2B8D),
            ),
            onSelected: (value) {
              switch (value) {
                case 'signin':
                  _navigateToLogin();
                  break;
                case 'signup':
                  _navigateToRegister();
                  break;
                case 'signin_anonymous':
                  _signInAnonymously();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'signin',
                child: Row(
                  children: [
                    Icon(Icons.login, color: Color(0xFFEE2B8D)),
                    SizedBox(width: 8),
                    Text('Sign In'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'signup',
                child: Row(
                  children: [
                    Icon(Icons.person_add, color: Color(0xFFEE2B8D)),
                    SizedBox(width: 8),
                    Text('Create Account'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'signin_anonymous',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Continue as Guest'),
                  ],
                ),
              ),
            ],
          ),
        ],
        const SizedBox(width: 16),
      ],
    );
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  void _navigateToProfileManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileManagementScreen()),
    );
  }

  void _navigateToSmsInsights() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SmsInsightsScreen(),
      ),
    );
  }

  Future<void> _signInAnonymously() async {
    try {
      final result = await AuthService.signInAnonymously();
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome! You\'re now in guest mode.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error?.message ?? 'Failed to sign in anonymously'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _signOut() async {
    try {
      final result = await AuthService.signOut();
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error?.message ?? 'Failed to sign out'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 