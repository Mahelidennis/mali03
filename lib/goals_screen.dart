import 'package:flutter/material.dart';

class FinancialGoal {
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String category;
  final DateTime targetDate;

  FinancialGoal({
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.category,
    required this.targetDate,
  });

  double get progress => currentAmount / targetAmount;
  double get remaining => targetAmount - currentAmount;
}

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final List<FinancialGoal> _goals = [
    FinancialGoal(
      title: 'Emergency Fund',
      targetAmount: 50000,
      currentAmount: 15000,
      category: 'Savings',
      targetDate: DateTime.now().add(const Duration(days: 90)),
    ),
    FinancialGoal(
      title: 'Vacation to Mombasa',
      targetAmount: 80000,
      currentAmount: 25000,
      category: 'Travel',
      targetDate: DateTime.now().add(const Duration(days: 180)),
    ),
    FinancialGoal(
      title: 'New Phone',
      targetAmount: 35000,
      currentAmount: 8000,
      category: 'Technology',
      targetDate: DateTime.now().add(const Duration(days: 60)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Goals',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Add new goal functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add new goal coming soon! 🎯'),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildMaliMessage(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                return _buildGoalCard(_goals[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaliMessage() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.purple, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.flag, color: Colors.purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mali says:',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Girl, you\'re ${_getOverallProgress()}% to your goals! Keep pushing! 💪',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getOverallProgress() {
    if (_goals.isEmpty) return '0';
    double totalProgress = _goals.fold(0.0, (sum, goal) => sum + goal.progress);
    return ((totalProgress / _goals.length) * 100).round().toString();
  }

  Widget _buildGoalCard(FinancialGoal goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getCategoryColor(goal.category),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  goal.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
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
                    'KSh ${goal.currentAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'of KSh ${goal.targetAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(goal.progress * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    'KSh ${goal.remaining.toStringAsFixed(0)} left',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: goal.progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              goal.progress >= 1.0 ? Colors.green : Colors.blue,
            ),
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          Text(
            _getMaliComment(goal),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'savings':
        return Colors.green;
      case 'travel':
        return Colors.orange;
      case 'technology':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getMaliComment(FinancialGoal goal) {
    if (goal.progress >= 1.0) {
      return "🎉 Girl, you did it! Mali is so proud of you!";
    } else if (goal.progress >= 0.7) {
      return "💪 Almost there! You're killing it!";
    } else if (goal.progress >= 0.4) {
      return "🔥 Good progress! Keep it up!";
    } else {
      return "💡 Let's get serious about this goal!";
    }
  }
} 