import 'package:flutter/material.dart';
import 'mali_chat_screen.dart';
import 'profile_screen.dart';
import 'home_screen.dart';
import 'expenses_screen.dart';
import 'goals_tracking_screen.dart';
import 'financial_reports_screen.dart';
import 'income_management_screen.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ExpensesScreen(),
    const IncomeManagementScreen(),
    const GoalsTrackingScreen(),
    const FinancialReportsScreen(),
    const MaliChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 24),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long, size: 24),
              label: 'Expenses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet, size: 24),
              label: 'Income',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events, size: 24),
              label: 'Goals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart, size: 24),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat, size: 24),
              label: 'Mali Chat',
            ),
          ],
        ),
      ),
    );
  }
} 