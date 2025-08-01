import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'expense_tracker.dart';
import 'dart:convert';

class GoalVisualizationScreen extends StatefulWidget {
  const GoalVisualizationScreen({super.key});

  @override
  State<GoalVisualizationScreen> createState() => _GoalVisualizationScreenState();
}

class _GoalVisualizationScreenState extends State<GoalVisualizationScreen> {
  List<Map<String, dynamic>> _goals = [];
  Map<String, dynamic> _financialData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoalsAndData();
  }

  Future<void> _loadGoalsAndData() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsString = prefs.getStringList('user_goals') ?? [];
    
    List<Map<String, dynamic>> goals = [];
    for (final goalString in goalsString) {
      final goalData = jsonDecode(goalString);
      goals.add(goalData);
    }

    // Get current financial data
    final currentMonth = DateTime.now();
    final spendingInsights = await ExpenseTracker.getSpendingInsights(currentMonth);
    final totalSpending = spendingInsights['total_spending'] ?? 0.0;
    
    final incomesString = prefs.getStringList('user_incomes') ?? [];
    double totalIncome = 0;
    for (final incomeString in incomesString) {
      final incomeData = jsonDecode(incomeString);
      final incomeDate = DateTime.parse(incomeData['date']);
      if (incomeDate.year == currentMonth.year && incomeDate.month == currentMonth.month) {
        totalIncome += incomeData['amount'];
      }
    }
    
    final currentSavings = totalIncome - totalSpending;

    setState(() {
      _goals = goals;
      _financialData = {
        'current_savings': currentSavings,
        'total_income': totalIncome,
        'total_spending': totalSpending,
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Goal Visualization',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _goals.isEmpty
              ? _buildEmptyState()
              : _buildGoalsVisualization(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Goals Set Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set your first financial goal to start visualizing your progress!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            },
            icon: const Icon(Icons.chat),
            label: const Text('Chat with Mali to Set Goals'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsVisualization() {
    final currentSavings = _financialData['current_savings'] ?? 0.0;
    final totalGoalAmount = _goals.fold<double>(0.0, (sum, goal) => sum + goal['amount']);
    final progressPercentage = totalGoalAmount > 0 ? (currentSavings / totalGoalAmount * 100).clamp(0.0, 100.0) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverallProgressCard(currentSavings, totalGoalAmount, progressPercentage),
          const SizedBox(height: 24),
          _buildGoalsList(currentSavings),
          const SizedBox(height: 24),
          _buildSavingsTimeline(),
        ],
      ),
    );
  }

  Widget _buildOverallProgressCard(double currentSavings, double totalGoalAmount, double progressPercentage) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.flag, color: Colors.purple),
              ),
              const SizedBox(width: 12),
              const Text(
                'Overall Goal Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  'Current Savings',
                  'KSh ${currentSavings.toStringAsFixed(0)}',
                  Icons.savings,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressItem(
                  'Goal Amount',
                  'KSh ${totalGoalAmount.toStringAsFixed(0)}',
                  Icons.flag,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressBar(progressPercentage),
          const SizedBox(height: 12),
          Text(
            '${progressPercentage.toStringAsFixed(1)}% Complete',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double percentage) {
    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: percentage / 100,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsList(double currentSavings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Individual Goals',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._goals.map((goal) {
          final goalAmount = goal['amount'];
          final goalTitle = goal['title'];
          final goalProgress = currentSavings / goalAmount * 100;
          final clampedProgress = goalProgress.clamp(0.0, 100.0);
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.flag,
                      color: clampedProgress >= 100 ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        goalTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'KSh ${goalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: clampedProgress / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: clampedProgress >= 100 ? Colors.green : Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${clampedProgress.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: clampedProgress >= 100 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  clampedProgress >= 100 
                    ? '🎉 Goal achieved! Amazing work!'
                    : 'Keep saving to reach your goal!',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSavingsTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Savings Timeline',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildTimelineItem(
                'Current Month',
                'KSh ${_financialData['current_savings']?.toStringAsFixed(0) ?? '0'}',
                Icons.today,
                Colors.blue,
              ),
              _buildTimelineItem(
                'Monthly Goal',
                'KSh ${(_goals.fold<double>(0.0, (sum, goal) => sum + goal['amount']) / 12).toStringAsFixed(0)}',
                Icons.calendar_month,
                Colors.green,
              ),
              _buildTimelineItem(
                'Total Goals',
                'KSh ${_goals.fold<double>(0.0, (sum, goal) => sum + goal['amount']).toStringAsFixed(0)}',
                Icons.flag,
                Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
} 