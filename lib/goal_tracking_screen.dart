import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GoalTrackingScreen extends StatefulWidget {
  const GoalTrackingScreen({super.key});

  @override
  State<GoalTrackingScreen> createState() => _GoalTrackingScreenState();
}

class _GoalTrackingScreenState extends State<GoalTrackingScreen> {
  List<Map<String, dynamic>> _goals = [];
  bool _isLoading = true;
  String _selectedFilter = 'Active';

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() {
      _isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final goalsStringList = prefs.getStringList('user_goals') ?? [];
    setState(() {
      _goals = goalsStringList
          .map((e) => jsonDecode(e) as Map<String, dynamic>)
          .toList();
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredGoals {
    switch (_selectedFilter) {
      case 'Active':
        return _goals.where((goal) => !goal['isCompleted']).toList();
      case 'Completed':
        return _goals.where((goal) => goal['isCompleted']).toList();
      case 'Overdue':
        final now = DateTime.now();
        return _goals.where((goal) {
          final targetDate = DateTime.parse(goal['targetDate']);
          return !goal['isCompleted'] && targetDate.isBefore(now);
        }).toList();
      case 'All':
      default:
        return _goals;
    }
  }

  List<Map<String, dynamic>> get _goalAlerts {
    final alerts = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    for (final goal in _goals) {
      final targetDate = DateTime.parse(goal['targetDate']);
      final daysRemaining = targetDate.difference(now).inDays;
      final progress = goal['targetAmount'] > 0 ? (goal['currentAmount'] / goal['targetAmount']) * 100 : 0.0;
      
      if (daysRemaining <= 7 && daysRemaining > 0 && progress < 100) {
        alerts.add({
          'type': 'deadline',
          'goal': goal['title'],
          'days': daysRemaining,
          'message': '${goal['title']} deadline in $daysRemaining days',
          'color': Colors.orange,
        });
      } else if (daysRemaining < 0 && !goal['isCompleted']) {
        alerts.add({
          'type': 'overdue',
          'goal': goal['title'],
          'days': daysRemaining.abs(),
          'message': '${goal['title']} is ${daysRemaining.abs()} days overdue',
          'color': Colors.red,
        });
      } else if (progress >= 90 && progress < 100) {
        alerts.add({
          'type': 'near_completion',
          'goal': goal['title'],
          'progress': progress,
          'message': '${goal['title']} is ${progress.toStringAsFixed(0)}% complete!',
          'color': Colors.green,
        });
      }
    }
    
    return alerts;
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Emergency Fund':
        return Icons.security;
      case 'Vacation':
        return Icons.flight;
      case 'Phone Upgrade':
        return Icons.phone_iphone;
      case 'Education':
        return Icons.school;
      case 'Home Purchase':
        return Icons.home;
      case 'Car Purchase':
        return Icons.directions_car;
      case 'Wedding':
        return Icons.favorite;
      case 'Investment':
        return Icons.trending_up;
      case 'Debt Payment':
        return Icons.payment;
      case 'Retirement':
        return Icons.elderly;
      case 'Business':
        return Icons.business;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Emergency Fund':
        return Colors.red;
      case 'Vacation':
        return Colors.blue;
      case 'Phone Upgrade':
        return Colors.purple;
      case 'Education':
        return Colors.green;
      case 'Home Purchase':
        return Colors.orange;
      case 'Car Purchase':
        return Colors.teal;
      case 'Wedding':
        return Colors.pink;
      case 'Investment':
        return Colors.indigo;
      case 'Debt Payment':
        return Colors.deepOrange;
      case 'Retirement':
        return Colors.brown;
      case 'Business':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

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
          'Goal Tracking',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter options
                  _buildFilterOptions(),
                  const SizedBox(height: 24),

                  // Goal Alerts
                  if (_goalAlerts.isNotEmpty) ...[
                    _buildGoalAlerts(),
                    const SizedBox(height: 24),
                  ],

                  // Goal Overview
                  _buildGoalOverview(),
                  const SizedBox(height: 24),

                  // Individual Goal Progress
                  _buildGoalProgress(),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ['All', 'Active', 'Completed', 'Overdue'].map((filter) {
        final isSelected = _selectedFilter == filter;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedFilter = filter;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEE2B8D) : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              filter,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGoalAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Goal Alerts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ..._goalAlerts.map((alert) => _buildAlertCard(alert)),
      ],
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (alert['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alert['color'] as Color,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            alert['type'] == 'deadline' ? Icons.schedule : 
            alert['type'] == 'overdue' ? Icons.warning : Icons.celebration,
            color: alert['color'] as Color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              alert['message'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: alert['color'] as Color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalOverview() {
    final activeGoals = _goals.where((goal) => !goal['isCompleted']).toList();
    final completedGoals = _goals.where((goal) => goal['isCompleted']).toList();
    final totalTarget = activeGoals.fold(0.0, (sum, goal) => sum + (goal['targetAmount'] ?? 0.0));
    final totalCurrent = activeGoals.fold(0.0, (sum, goal) => sum + (goal['currentAmount'] ?? 0.0));
    final overallProgress = totalTarget > 0 ? (totalCurrent / totalTarget) * 100 : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFEE2B8D),
            const Color(0xFFEE2B8D).withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Goal Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Active Goals',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${activeGoals.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Completed',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${completedGoals.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Progress: ${overallProgress.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                'Ksh ${totalCurrent.toStringAsFixed(0)} / Ksh ${totalTarget.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: overallProgress / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalProgress() {
    final filteredGoals = _filteredGoals;
    
    if (filteredGoals.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.emoji_events,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No goals to track',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create goals to start tracking your progress',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Goal Progress',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...filteredGoals.map((goal) => _buildGoalProgressItem(goal)),
      ],
    );
  }

  Widget _buildGoalProgressItem(Map<String, dynamic> goal) {
    final category = goal['category'] ?? 'Other';
    final targetAmount = goal['targetAmount'] ?? 0.0;
    final currentAmount = goal['currentAmount'] ?? 0.0;
    final targetDate = DateTime.parse(goal['targetDate']);
    final isCompleted = goal['isCompleted'] ?? false;
    final isOverdue = !isCompleted && targetDate.isBefore(DateTime.now());
    
    final progress = targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0.0;
    final remaining = targetAmount - currentAmount;
    final daysRemaining = targetDate.difference(DateTime.now()).inDays;

    Color progressColor;
    if (isCompleted) {
      progressColor = Colors.green;
    } else if (isOverdue) {
      progressColor = Colors.red;
    } else if (progress >= 80) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getCategoryColor(category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  color: _getCategoryColor(category),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal['title'] ?? 'Untitled Goal',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      category,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${progress.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Target: Ksh ${targetAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Current: Ksh ${currentAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Remaining: Ksh ${remaining.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: remaining > 0 ? Colors.grey : Colors.green,
                    ),
                  ),
                  if (isCompleted)
                    const Text(
                      'Completed! 🎉',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    )
                  else if (isOverdue)
                    Text(
                      'Overdue by ${daysRemaining.abs()} days',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    )
                  else if (daysRemaining <= 7)
                    Text(
                      '$daysRemaining days left',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    )
                  else
                    Text(
                      '$daysRemaining days left',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
