import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'goals_screen.dart';
import 'profile_screen.dart';
import 'home_screen.dart';
import 'spending_tracker_screen.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    
    return Scaffold(
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
          backgroundColor: const Color(0xFF16213E), // Dark background
          selectedItemColor: Colors.blue[300], // Brighter blue for contrast
          unselectedItemColor: Colors.grey[400], // Lighter grey for visibility
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 10 : 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: isSmallScreen ? 10 : 12,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: isSmallScreen ? 20 : 24),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble, size: isSmallScreen ? 20 : 24),
              label: 'Chat with Mali',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: isSmallScreen ? 20 : 24),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
} 