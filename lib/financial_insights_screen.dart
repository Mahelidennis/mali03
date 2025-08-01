import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'expense_tracker.dart';
import 'dart:convert';

class FinancialInsightsScreen extends StatefulWidget {
  const FinancialInsightsScreen({super.key});

  @override
  State<FinancialInsightsScreen> createState() => _FinancialInsightsScreenState();
}

class _FinancialInsightsScreenState extends State<FinancialInsightsScreen> {
  Map<String, dynamic> _insights = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    final currentMonth = DateTime.now();
    
    // Get expense insights
    final spendingInsights = await ExpenseTracker.getSpendingInsights(currentMonth);
    
    // Get income data
    final prefs = await SharedPreferences.getInstance();
    final incomesString = prefs.getStringList('user_incomes') ?? [];
    double totalIncome = 0;
    Map<String, double> incomeByCategory = {};
    
    for (final incomeString in incomesString) {
      final incomeData = jsonDecode(incomeString);
      final incomeDate = DateTime.parse(incomeData['date']);
      if (incomeDate.year == currentMonth.year && incomeDate.month == currentMonth.month) {
        totalIncome += incomeData['amount'];
        final category = incomeData['category'];
        incomeByCategory[category] = (incomeByCategory[category] ?? 0) + incomeData['amount'];
      }
    }

    // Get goals data
    final goalsString = prefs.getStringList('user_goals') ?? [];
    double totalGoals = 0;
    for (final goalString in goalsString) {
      final goalData = jsonDecode(goalString);
      totalGoals += goalData['amount'];
    }

    // Calculate savings rate
    final totalSpending = spendingInsights['total_spending'] ?? 0.0;
    final savings = totalIncome - totalSpending;
    final savingsRate = totalIncome > 0 ? (savings / totalIncome * 100) : 0.0;

    // Calculate spending by category percentage
    final categoryBreakdown = spendingInsights['category_breakdown'] ?? {};
    final totalSpendingForPercentage = categoryBreakdown.values.fold(0.0, (sum, amount) => sum + amount);
    
    Map<String, double> categoryPercentages = {};
    categoryBreakdown.forEach((category, amount) {
      categoryPercentages[category] = totalSpendingForPercentage > 0 ? (amount / totalSpendingForPercentage * 100) : 0.0;
    });

    setState(() {
      _insights = {
        'total_income': totalIncome,
        'total_spending': totalSpending,
        'savings': savings,
        'savings_rate': savingsRate,
        'total_goals': totalGoals,
        'top_spending_category': spendingInsights['top_category'] ?? '',
        'top_spending_amount': spendingInsights['top_amount'] ?? 0.0,
        'average_daily_spending': spendingInsights['average_daily'] ?? 0.0,
        'expense_count': spendingInsights['expense_count'] ?? 0,
        'income_count': incomesString.length,
        'goal_count': goalsString.length,
        'category_breakdown': categoryBreakdown,
        'category_percentages': categoryPercentages,
        'income_by_category': incomeByCategory,
        'days_in_month': DateTime(currentMonth.year, currentMonth.month + 1, 0).day,
        'days_remaining': DateTime(currentMonth.year, currentMonth.month + 1, 0).day - currentMonth.day,
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Financial Insights',
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverviewCard(),
                  const SizedBox(height: 16),
                  _buildSavingsCard(),
                  const SizedBox(height: 16),
                  _buildSpendingBreakdown(),
                  const SizedBox(height: 16),
                  _buildIncomeBreakdown(),
                  const SizedBox(height: 16),
                  _buildGoalsCard(),
                  const SizedBox(height: 16),
                  _buildRecommendations(),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewCard() {
    final totalIncome = _insights['total_income'] ?? 0.0;
    final totalSpending = _insights['total_spending'] ?? 0.0;
    final savings = _insights['savings'] ?? 0.0;
    final savingsRate = _insights['savings_rate'] ?? 0.0;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.analytics, color: Colors.purple),
              ),
              const SizedBox(width: 12),
              const Text(
                'This Month\'s Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInsightItem(
                  'Income',
                  'KSh ${totalIncome.toStringAsFixed(0)}',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInsightItem(
                  'Spending',
                  'KSh ${totalSpending.toStringAsFixed(0)}',
                  Icons.trending_down,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInsightItem(
                  'Savings',
                  'KSh ${savings.toStringAsFixed(0)}',
                  Icons.savings,
                  savings >= 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInsightItem(
                  'Savings Rate',
                  '${savingsRate.toStringAsFixed(1)}%',
                  Icons.pie_chart,
                  savingsRate >= 20 ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String label, String value, IconData icon, Color color) {
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

  Widget _buildSavingsCard() {
    final savings = _insights['savings'] ?? 0.0;
    final savingsRate = _insights['savings_rate'] ?? 0.0;

    String message = '';
    Color cardColor = Colors.green;
    
    if (savingsRate >= 20) {
      message = 'Girl, you\'re killing it! 💪 Your ${savingsRate.toStringAsFixed(1)}% savings rate is amazing! Keep it up! 🎉';
      cardColor = Colors.green;
    } else if (savingsRate >= 10) {
      message = 'Good job, girl! 💪 You\'re saving ${savingsRate.toStringAsFixed(1)}% of your income. Let\'s try to get to 20%! 💡';
      cardColor = Colors.orange;
    } else if (savings >= 0) {
      message = 'You\'re saving KSh ${savings.toStringAsFixed(0)}, girl! 💰 That\'s ${savingsRate.toStringAsFixed(1)}% of your income. Let\'s increase that! 💪';
      cardColor = Colors.orange;
    } else {
      message = 'Girl, you\'re spending more than you earn! 💸 Let\'s work on that budget together! 💪';
      cardColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: cardColor.withOpacity(0.2),
            child: Icon(Icons.savings, color: cardColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: cardColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingBreakdown() {
    final categoryBreakdown = _insights['category_breakdown'] ?? {};
    final categoryPercentages = _insights['category_percentages'] ?? {};

    if (categoryBreakdown.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Text(
          'No spending data yet. Start by adding some expenses!',
          style: TextStyle(fontSize: 14),
        ),
      );
    }

    return Container(
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
          const Text(
            'Spending Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...categoryBreakdown.entries.map((entry) {
            final category = entry.key;
            final amount = entry.value;
            final percentage = categoryPercentages[category] ?? 0.0;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      category,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'KSh ${amount.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildIncomeBreakdown() {
    final incomeByCategory = _insights['income_by_category'] ?? {};

    if (incomeByCategory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Text(
          'No income data yet. Start by adding some income!',
          style: TextStyle(fontSize: 14),
        ),
      );
    }

    return Container(
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
          const Text(
            'Income Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...incomeByCategory.entries.map((entry) {
            final category = entry.key;
            final amount = entry.value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      category,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'KSh ${amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildGoalsCard() {
    final totalGoals = _insights['total_goals'] ?? 0.0;
    final goalCount = _insights['goal_count'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.orange[100],
            child: Icon(Icons.flag, color: Colors.orange[800]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Financial Goals',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.orange[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  goalCount > 0 
                    ? 'You have $goalCount goals worth KSh ${totalGoals.toStringAsFixed(0)}'
                    : 'No goals set yet. Start by setting some financial goals!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    final savingsRate = _insights['savings_rate'] ?? 0.0;
    final topCategory = _insights['top_spending_category'] ?? '';
    final topAmount = _insights['top_spending_amount'] ?? 0.0;
    final averageDaily = _insights['average_daily_spending'] ?? 0.0;

    List<String> recommendations = [];

    if (savingsRate < 20) {
      recommendations.add('💡 Try to save at least 20% of your income');
    }
    if (topAmount > 10000) {
      recommendations.add('💡 Consider setting a budget for $topCategory');
    }
    if (averageDaily > 2000) {
      recommendations.add('💡 Your daily spending is high. Try to reduce it');
    }
    if (recommendations.isEmpty) {
      recommendations.add('🎉 You\'re doing great! Keep up the good work!');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Icon(Icons.lightbulb, color: Colors.blue[800]),
              ),
              const SizedBox(width: 12),
              Text(
                'Mali\'s Recommendations',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendations.map((rec) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              rec,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[700],
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }
} 