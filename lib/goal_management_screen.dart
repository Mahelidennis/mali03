import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'goal_input_screen.dart';

class GoalManagementScreen extends StatefulWidget {
  const GoalManagementScreen({super.key});

  @override
  State<GoalManagementScreen> createState() => _GoalManagementScreenState();
}

class _GoalManagementScreenState extends State<GoalManagementScreen> {
  List<Map<String, dynamic>> _goals = [];
  bool _isLoading = true;
  String _selectedFilter = 'All'; // Default filter

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

  Future<void> _navigateToAddGoal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GoalInputScreen()),
    );
    if (result == true) {
      _loadGoals(); // Refresh goals if a new one was added
    }
  }

  Future<void> _deleteGoal(int index) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this goal?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _goals.removeAt(index);
      });
      final prefs = await SharedPreferences.getInstance();
      final goalsStringList = _goals.map((e) => jsonEncode(e)).toList();
      await prefs.setStringList('user_goals', goalsStringList);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal deleted successfully!'),
            backgroundColor: Color(0xFFEE2B8D),
          ),
        );
      }
    }
  }

  Future<void> _updateGoalProgress(int index, double newAmount) async {
    setState(() {
      _goals[index]['currentAmount'] = newAmount;
      if (newAmount >= _goals[index]['targetAmount']) {
        _goals[index]['isCompleted'] = true;
      }
    });
    
    final prefs = await SharedPreferences.getInstance();
    final goalsStringList = _goals.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('user_goals', goalsStringList);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goal progress updated!'),
          backgroundColor: Color(0xFFEE2B8D),
        ),
      );
    }
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

  double get _totalTargetAmount {
    return _filteredGoals.fold(0.0, (sum, goal) => sum + (goal['targetAmount'] ?? 0.0));
  }

  double get _totalCurrentAmount {
    return _filteredGoals.fold(0.0, (sum, goal) => sum + (goal['currentAmount'] ?? 0.0));
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

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Critical':
        return Colors.red;
      case 'High':
        return Colors.orange;
      case 'Medium':
        return Colors.blue;
      case 'Low':
        return Colors.green;
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
          'Goal Management',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFEE2B8D)),
            onPressed: _navigateToAddGoal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Goal Summary Card
                        _buildGoalSummaryCard(),
                        const SizedBox(height: 24),

                        // Filter options
                        _buildFilterOptions(),
                        const SizedBox(height: 24),

                        // Goals List
                        _buildGoalsList(),
                      ],
                    ),
                  ),
                ),
                // Floating Action Button for adding goals
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _navigateToAddGoal,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Create New Goal',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEE2B8D),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildGoalSummaryCard() {
    final totalTarget = _totalTargetAmount;
    final totalCurrent = _totalCurrentAmount;
    final totalProgress = totalTarget > 0 ? (totalCurrent / totalTarget) * 100 : 0.0;

    return Container(
      width: double.infinity,
      height: 140,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ksh ${totalCurrent.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Ksh ${totalTarget.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Total Progress • Total Target',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: totalProgress / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${totalProgress.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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

  Widget _buildGoalsList() {
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
              'No goals found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first financial goal to start tracking',
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
          'Your Goals',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...filteredGoals.asMap().entries.map((entry) {
          final index = entry.key;
          final goal = entry.value;
          return _buildGoalItem(goal, index);
        }).toList(),
      ],
    );
  }

  Widget _buildGoalItem(Map<String, dynamic> goal, int index) {
    final category = goal['category'] ?? 'Other';
    final targetAmount = goal['targetAmount'] ?? 0.0;
    final currentAmount = goal['currentAmount'] ?? 0.0;
    final priority = goal['priority'] ?? 'Medium';
    final targetDate = DateTime.parse(goal['targetDate']);
    final isCompleted = goal['isCompleted'] ?? false;
    final isOverdue = !isCompleted && targetDate.isBefore(DateTime.now());
    
    final progress = targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0.0;
    final remaining = targetAmount - currentAmount;

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor(priority).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  priority,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getPriorityColor(priority),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'update') {
                    _showUpdateProgressDialog(index, currentAmount, targetAmount);
                  } else if (value == 'delete') {
                    _deleteGoal(index);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'update',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Update Progress'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: const Icon(
                  Icons.more_vert,
                  color: Colors.grey,
                  size: 20,
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
                  Text(
                    '${progress.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: progressColor,
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target: ${targetDate.day}/${targetDate.month}/${targetDate.year}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
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
                const Text(
                  'Overdue',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showUpdateProgressDialog(int index, double currentAmount, double targetAmount) {
    final controller = TextEditingController(text: currentAmount.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Goal Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current amount: Ksh ${currentAmount.toStringAsFixed(0)}'),
            Text('Target amount: Ksh ${targetAmount.toStringAsFixed(0)}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'New Current Amount (Ksh)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newAmount = double.tryParse(controller.text);
              if (newAmount != null && newAmount >= 0) {
                _updateGoalProgress(index, newAmount);
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
