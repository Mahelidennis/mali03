import 'package:flutter/material.dart';
import 'goal_management_screen.dart';

class GoalsTrackingScreen extends StatefulWidget {
  const GoalsTrackingScreen({super.key});

  @override
  State<GoalsTrackingScreen> createState() => _GoalsTrackingScreenState();
}

class _GoalsTrackingScreenState extends State<GoalsTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Goals',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: const GoalManagementScreen(),
    );
  }
}