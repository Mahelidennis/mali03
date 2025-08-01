import 'package:flutter/material.dart';
import 'spending_tracker_screen.dart';
import 'goals_screen.dart';
import 'chat_screen.dart';
import 'expense_form.dart';
import 'income_form.dart';
import 'expense_tracker.dart'; // Added import for ExpenseTracker
import 'package:shared_preferences/shared_preferences.dart'; // Added import for SharedPreferences
import 'dart:convert'; // Added import for jsonDecode
import 'financial_insights_screen.dart';
import 'alerts_screen.dart';
import 'budget_alerts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> _financialSummary = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFinancialSummary();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when returning from other screens
    _loadFinancialSummary();
  }

  Future<void> _loadFinancialSummary() async {
    final currentMonth = DateTime.now();
    
    // Get real expense data
    final spendingInsights = await ExpenseTracker.getSpendingInsights(currentMonth);
    
    // Get real income data
    final prefs = await SharedPreferences.getInstance();
    final incomesString = prefs.getStringList('user_incomes') ?? [];
    double totalIncome = 0;
    for (final incomeString in incomesString) {
      final incomeData = jsonDecode(incomeString);
      final incomeDate = DateTime.parse(incomeData['date']);
      if (incomeDate.year == currentMonth.year && incomeDate.month == currentMonth.month) {
        totalIncome += incomeData['amount'];
      }
    }

    // Get real goals data
    final goalsString = prefs.getStringList('user_goals') ?? [];
    double totalGoals = 0;
    for (final goalString in goalsString) {
      final goalData = jsonDecode(goalString);
      totalGoals += goalData['amount'];
    }

    setState(() {
      _financialSummary = {
        'total_spending': spendingInsights['total_spending'] ?? 0.0,
        'total_income': totalIncome,
        'total_goals': totalGoals,
        'top_category': spendingInsights['top_category'] ?? '',
        'top_amount': spendingInsights['top_amount'] ?? 0.0,
        'expense_count': spendingInsights['expense_count'] ?? 0,
        'income_count': incomesString.length,
        'goal_count': goalsString.length,
      };
      _isLoading = false;
    });
  }

  void _showAddExpenseDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExpenseForm()),
    );
  }

  void _showAddIncomeDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const IncomeForm()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isLargeScreen = screenSize.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mali',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FinancialInsightsScreen()),
              );
            },
          ),
          FutureBuilder<int>(
            future: BudgetAlertManager.getUnreadCount(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AlertsScreen()),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(isSmallScreen),
            SizedBox(height: isSmallScreen ? 16 : 24),
            _buildQuickActions(isSmallScreen),
            SizedBox(height: isSmallScreen ? 16 : 24),
            _buildMaliInsights(isSmallScreen),
            SizedBox(height: isSmallScreen ? 16 : 24),
            _buildChatWidget(context, isSmallScreen),
            SizedBox(height: isSmallScreen ? 16 : 24),
            _buildRecentActivity(isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(bool isSmallScreen) {
    final totalIncome = _financialSummary['total_income'] ?? 0.0;
    final totalSpending = _financialSummary['total_spending'] ?? 0.0;
    final savings = totalIncome - totalSpending;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
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
              CircleAvatar(
                radius: isSmallScreen ? 20 : 24,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.waving_hand, 
                  color: Colors.purple,
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hey Sarah! 👋',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 18 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Ready to crush your financial goals?',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up, 
                  color: Colors.white, 
                  size: isSmallScreen ? 16 : 20
                ),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Expanded(
                  child: Text(
                    savings >= 0 
                      ? 'You\'ve saved KSh ${savings.toStringAsFixed(0)} this month! 🎉'
                      : 'You\'re KSh ${(-savings).toStringAsFixed(0)} over budget this month 💸',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isSmallScreen) {
    final totalSpending = _financialSummary['total_spending'] ?? 0.0;
    final totalIncome = _financialSummary['total_income'] ?? 0.0;
    final totalGoals = _financialSummary['total_goals'] ?? 0.0;
    final expenseCount = _financialSummary['expense_count'] ?? 0;
    final incomeCount = _financialSummary['income_count'] ?? 0;
    final goalCount = _financialSummary['goal_count'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Spending',
                Icons.account_balance_wallet,
                Colors.red,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SpendingTrackerScreen()),
                  );
                },
                isSmallScreen,
                subtitle: expenseCount > 0 ? '${expenseCount} items • KSh ${totalSpending.toStringAsFixed(0)}' : 'No expenses yet',
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(
              child: _buildActionCard(
                'Goals',
                Icons.flag,
                Colors.orange,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GoalsScreen()),
                  );
                },
                isSmallScreen,
                subtitle: goalCount > 0 ? '${goalCount} goals • KSh ${totalGoals.toStringAsFixed(0)}' : 'No goals set yet',
              ),
            ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Add Expense',
                Icons.add_circle,
                Colors.red,
                () => _showAddExpenseDialog(context),
                isSmallScreen,
                subtitle: 'Via chat or form',
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(
              child: _buildActionCard(
                'Add Income',
                Icons.attach_money,
                Colors.green,
                () => _showAddIncomeDialog(context),
                isSmallScreen,
                subtitle: incomeCount > 0 ? '${incomeCount} items • KSh ${totalIncome.toStringAsFixed(0)}' : 'No income yet',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap, bool isSmallScreen, {String? subtitle}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
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
            Icon(
              icon, 
              color: color, 
              size: isSmallScreen ? 24 : 32
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: isSmallScreen ? 12 : 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isSmallScreen ? 10 : 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMaliInsights(bool isSmallScreen) {
    final totalSpending = _financialSummary['total_spending'] ?? 0.0;
    final topCategory = _financialSummary['top_category'] ?? '';
    final topAmount = _financialSummary['top_amount'] ?? 0.0;
    final totalIncome = _financialSummary['total_income'] ?? 0.0;

    String insightMessage = '';
    
    if (totalSpending > 0) {
      if (topCategory.isNotEmpty && topAmount > 0) {
        insightMessage = 'Girl, you spent KSh ${totalSpending.toStringAsFixed(0)} this month! 💰 Your biggest expense is $topCategory at KSh ${topAmount.toStringAsFixed(0)}. Let me help you track that spending! 📊';
      } else {
        insightMessage = 'Girl, you spent KSh ${totalSpending.toStringAsFixed(0)} this month! 💰 Let me help you track that spending and maybe find ways to save more! 📊';
      }
    } else if (totalIncome > 0) {
      insightMessage = 'Girl, you earned KSh ${totalIncome.toStringAsFixed(0)} this month! 💰 That\'s amazing! How are you planning to use this money? Let\'s make sure you\'re not just spending it all! 💅';
    } else {
      insightMessage = 'Girl, I\'m here to help you track your money! 💰 Start by telling me about your income or expenses in the chat! 💪';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.amber[100],
                child: Icon(Icons.lightbulb, color: Colors.amber[800]),
              ),
              const SizedBox(width: 12),
              const Text(
                'Mali\'s Insight',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insightMessage,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatWidget(BuildContext context, bool isSmallScreen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
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
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: isSmallScreen ? 18 : 24,
                    child: Icon(
                      Icons.chat_bubble, 
                      color: Colors.purple, 
                      size: isSmallScreen ? 20 : 24
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chat with Mali',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Your financial big sister',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white70,
                    size: isSmallScreen ? 16 : 20,
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Text(
                'Ask me anything about your money! 💰\nGet personalized advice, track spending, or just chat! 💅',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 12 : 14,
                  height: 1.4,
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 6 : 8, 
                        horizontal: isSmallScreen ? 8 : 12
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '💬 "What did I spend last week?"',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 10 : 12,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 6 : 8),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 6 : 8, 
                        horizontal: isSmallScreen ? 8 : 12
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '🎯 "Help me save more"',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 10 : 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildActivityItem(
          'Coffee at Java House',
          'KSh -450',
          '2 hours ago',
          Icons.coffee,
          Colors.brown,
        ),
        _buildActivityItem(
          'Salary Deposit',
          'KSh +45,000',
          '1 day ago',
          Icons.account_balance,
          Colors.green,
        ),
        _buildActivityItem(
          'Uber Ride',
          'KSh -350',
          '2 days ago',
          Icons.directions_car,
          Colors.blue,
        ),
        _buildActivityItem(
          'Grocery Shopping',
          'KSh -2,500',
          '3 days ago',
          Icons.shopping_cart,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String amount, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: amount.startsWith('+') ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
