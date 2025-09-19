import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'expense_tracker.dart';
import 'income_management_screen.dart';
import 'settings_screen.dart';
import 'budget_tracking_screen.dart';
import 'financial_reports_screen.dart';
import 'goal_management_screen.dart';
import 'mali_chat_enhanced.dart';
import 'notification_service.dart';
import 'notification_center_screen.dart';
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> _financialData = {};
  bool _isLoading = true;
  final NotificationService _notificationService = NotificationService();
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    await _notificationService.runAllChecks();
    await _loadNotificationCount();
  }

  Future<void> _loadNotificationCount() async {
    final count = await _notificationService.getUnreadCount();
    if (mounted) {
      setState(() {
        _unreadNotificationCount = count;
      });
    }
  }

  Future<void> _loadFinancialData() async {
    final currentMonth = DateTime.now();

    // Get income data
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

    // Get expense data
    final expensesString = prefs.getStringList('user_expenses') ?? [];
    double totalExpenses = 0;
    List<Map<String, dynamic>> recentExpenses = [];
    for (final expenseString in expensesString) {
      final expenseData = jsonDecode(expenseString);
      final expenseDate = DateTime.parse(expenseData['date']);
      if (expenseDate.year == currentMonth.year && expenseDate.month == currentMonth.month) {
        totalExpenses += expenseData['amount'];
        recentExpenses.add(expenseData);
      }
    }

    // Sort recent expenses by date (most recent first) and take first 3
    recentExpenses.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
    recentExpenses = recentExpenses.take(3).toList();

    // Get budget data
    final budgetsString = prefs.getStringList('user_budgets') ?? [];
    List<Map<String, dynamic>> monthlyBudgets = [];
    double totalBudget = 0;
    for (final budgetString in budgetsString) {
      final budgetData = jsonDecode(budgetString);
      if (budgetData['period'] == 'Monthly') {
        monthlyBudgets.add(budgetData);
        totalBudget += budgetData['amount'];
      }
    }

    // Calculate budget vs spending
    double budgetSpent = 0;
    for (final budget in monthlyBudgets) {
      final category = budget['category'];
      for (final expense in recentExpenses) {
        if (expense['category'] == category) {
          budgetSpent += expense['amount'];
        }
      }
    }

    // Get goal data
    final goalsString = prefs.getStringList('user_goals') ?? [];
    List<Map<String, dynamic>> activeGoals = [];
    double totalGoalTarget = 0;
    double totalGoalCurrent = 0;
    for (final goalString in goalsString) {
      final goalData = jsonDecode(goalString);
      if (!goalData['isCompleted']) {
        activeGoals.add(goalData);
        totalGoalTarget += goalData['targetAmount'];
        totalGoalCurrent += goalData['currentAmount'];
      }
    }

    // Sort goals by priority and take top 3
    activeGoals.sort((a, b) {
      final priorityOrder = {'Critical': 4, 'High': 3, 'Medium': 2, 'Low': 1};
      final aPriority = priorityOrder[a['priority']] ?? 0;
      final bPriority = priorityOrder[b['priority']] ?? 0;
      return bPriority.compareTo(aPriority);
    });
    activeGoals = activeGoals.take(3).toList();

    setState(() {
      _financialData = {
        'total_spending': totalExpenses,
        'total_income': totalIncome,
        'balance': totalIncome - totalExpenses,
        'recent_expenses': recentExpenses,
        'total_budget': totalBudget,
        'budget_spent': budgetSpent,
        'budget_remaining': totalBudget - budgetSpent,
        'budget_percentage': totalBudget > 0 ? (budgetSpent / totalBudget) * 100 : 0.0,
        'active_goals': activeGoals,
        'total_goal_target': totalGoalTarget,
        'total_goal_current': totalGoalCurrent,
        'goal_progress': totalGoalTarget > 0 ? (totalGoalCurrent / totalGoalTarget) * 100 : 0.0,
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom header
          Container(
            padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 16),
            child: Column(
              children: [
                // Main Dashboard title
                const Text(
                  'Main Dashboard',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                        // Mali title with notification and settings icons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Mali',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Row(
                              children: [
                                // Notification icon with badge
                                Stack(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.notifications, color: Colors.black87),
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => const NotificationCenterScreen()),
                                        );
                                        await _loadNotificationCount();
                                      },
                                    ),
                                    if (_unreadNotificationCount > 0)
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEE2B8D),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 16,
                                            minHeight: 16,
                                          ),
                                          child: Text(
                                            '$_unreadNotificationCount',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.settings, color: Colors.black87),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                const SizedBox(height: 8),
                // Welcome message
                const Text(
                  'Hey, financial warrior! Ready to conquer your goals? 💪',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        // Balance card
                        _buildBalanceCard(),
                        const SizedBox(height: 24),
                        // Recent transactions
                        _buildRecentTransactions(),
                        const SizedBox(height: 24),
                                // Budget section
                                _buildBudgetSection(),
                                const SizedBox(height: 24),
                                
                                // Financial Insights section
                                _buildFinancialInsightsSection(),
                                const SizedBox(height: 24),
                                
                                // Goals section
                                _buildGoalsSection(),
                                const SizedBox(height: 24),
                                
                                // Critical Notifications section
                                _buildCriticalNotificationsSection(),
                                const SizedBox(height: 24),
                                
                                // Mali Chat Insights section
                                _buildMaliInsightsSection(),
                                const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    final balance = _financialData['balance'] ?? 12450.0; // Default to match design
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const IncomeManagementScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E7D32), // Dark green
              Color(0xFF1B5E20), // Darker green
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
                    'Ksh ${balance.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white70,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Current Balance - Tap to manage income',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final recentExpenses = _financialData['recent_expenses'] as List<Map<String, dynamic>>? ?? [];
    
    if (recentExpenses.isEmpty) {
      return Container(
        width: double.infinity,
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
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No recent transactions',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some expenses to see them here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
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
          const Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...recentExpenses.map((expense) => _buildTransactionItem(expense)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> expense) {
    final category = expense['category'] ?? 'Other';
    final amount = expense['amount'] ?? 0.0;
    final title = expense['title'] ?? 'Expense';
    final paymentMethod = expense['paymentMethod'] ?? '';

    IconData icon;
    Color iconColor;
    switch (category) {
      case 'Food & Dining':
        icon = Icons.restaurant;
        iconColor = Colors.orange;
        break;
      case 'Transportation':
        icon = Icons.directions_car;
        iconColor = Colors.blue;
        break;
      case 'Shopping':
        icon = Icons.shopping_bag;
        iconColor = Colors.purple;
        break;
      case 'Entertainment':
        icon = Icons.movie;
        iconColor = Colors.red;
        break;
      case 'Healthcare':
        icon = Icons.local_hospital;
        iconColor = Colors.green;
        break;
      case 'Education':
        icon = Icons.school;
        iconColor = Colors.indigo;
        break;
      case 'Utilities':
        icon = Icons.electrical_services;
        iconColor = Colors.amber;
        break;
      case 'Travel':
        icon = Icons.flight;
        iconColor = Colors.teal;
        break;
      case 'Personal Care':
        icon = Icons.face;
        iconColor = Colors.pink;
        break;
      case 'Gifts & Donations':
        icon = Icons.card_giftcard;
        iconColor = Colors.cyan;
        break;
      case 'Insurance':
        icon = Icons.security;
        iconColor = Colors.deepOrange;
        break;
      default:
        icon = Icons.category;
        iconColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
                if (paymentMethod.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    paymentMethod,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '- Ksh ${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSection() {
    final totalBudget = _financialData['total_budget'] ?? 0.0;
    final budgetSpent = _financialData['budget_spent'] ?? 0.0;
    final budgetRemaining = _financialData['budget_remaining'] ?? 0.0;
    final budgetPercentage = _financialData['budget_percentage'] ?? 0.0;

    if (totalBudget == 0) {
      return Container(
        width: double.infinity,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Budget Tracking',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BudgetTrackingScreen()),
                    );
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: Color(0xFFEE2B8D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No budgets set',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set up budgets to track your spending',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Color budgetColor;
    if (budgetPercentage >= 100) {
      budgetColor = Colors.red[800]!;
    } else if (budgetPercentage >= 80) {
      budgetColor = Colors.orange[800]!;
    } else {
      budgetColor = Colors.green[800]!;
    }

    return Container(
      width: double.infinity,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Budget Tracking',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BudgetTrackingScreen()),
                  );
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFFEE2B8D),
                    fontWeight: FontWeight.w600,
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
                    'Total Budget',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Ksh ${totalBudget.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Spent',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Ksh ${budgetSpent.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: budgetColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Remaining: Ksh ${budgetRemaining.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: budgetRemaining >= 0 ? Colors.green : Colors.red,
                ),
              ),
              Text(
                '${budgetPercentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: budgetColor,
                ),
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
              widthFactor: budgetPercentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: budgetColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialInsightsSection() {
    final totalIncome = _financialData['total_income'] ?? 0.0;
    final totalExpenses = _financialData['total_spending'] ?? 0.0;
    final netIncome = totalIncome - totalExpenses;
    final savingsRate = totalIncome > 0 ? ((netIncome / totalIncome) * 100) : 0.0;

    return Container(
      width: double.infinity,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Financial Insights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FinancialReportsScreen()),
                  );
                },
                child: const Text(
                  'View Reports',
                  style: TextStyle(
                    color: Color(0xFFEE2B8D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Net Income Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: netIncome >= 0 ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: netIncome >= 0 ? Colors.green[200]! : Colors.red[200]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  netIncome >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: netIncome >= 0 ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        netIncome >= 0 ? 'Positive Cash Flow' : 'Negative Cash Flow',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: netIncome >= 0 ? Colors.green[800] : Colors.red[800],
                        ),
                      ),
                      Text(
                        'Ksh ${netIncome.abs().toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: netIncome >= 0 ? Colors.green[800] : Colors.red[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Savings Rate
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Savings Rate',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${savingsRate.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Income',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Ksh ${totalIncome.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Quick Tip
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEE2B8D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFFEE2B8D),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    savingsRate >= 20 
                        ? 'Great job! You\'re saving ${savingsRate.toStringAsFixed(1)}% of your income!'
                        : savingsRate >= 10
                            ? 'Good progress! Try to increase your savings rate.'
                            : 'Consider reducing expenses to improve your savings rate.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
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

  Widget _buildGoalsSection() {
    final activeGoals = _financialData['active_goals'] as List<Map<String, dynamic>>? ?? [];
    final totalGoalTarget = _financialData['total_goal_target'] ?? 0.0;
    final totalGoalCurrent = _financialData['total_goal_current'] ?? 0.0;
    final goalProgress = _financialData['goal_progress'] ?? 0.0;

    if (activeGoals.isEmpty) {
      return Container(
        width: double.infinity,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Goals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GoalManagementScreen()),
                    );
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: Color(0xFFEE2B8D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No goals set',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first financial goal',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Goals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GoalManagementScreen()),
                  );
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFFEE2B8D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Overall Progress
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEE2B8D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overall Progress',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Ksh ${totalGoalCurrent.toStringAsFixed(0)} / Ksh ${totalGoalTarget.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${goalProgress.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEE2B8D),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Individual Goals
          ...activeGoals.map((goal) => _buildGoalItem(goal)),
        ],
      ),
    );
  }

  Widget _buildGoalItem(Map<String, dynamic> goal) {
    final title = goal['title'] ?? 'Untitled Goal';
    final category = goal['category'] ?? 'Other';
    final targetAmount = goal['targetAmount'] ?? 0.0;
    final currentAmount = goal['currentAmount'] ?? 0.0;
    final progress = targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0.0;
    final priority = goal['priority'] ?? 'Medium';

    IconData icon;
    Color iconColor;
    switch (category) {
      case 'Emergency Fund':
        icon = Icons.security;
        iconColor = Colors.red;
        break;
      case 'Vacation':
        icon = Icons.flight;
        iconColor = Colors.blue;
        break;
      case 'Phone Upgrade':
        icon = Icons.phone_iphone;
        iconColor = Colors.purple;
        break;
      case 'Education':
        icon = Icons.school;
        iconColor = Colors.green;
        break;
      case 'Home Purchase':
        icon = Icons.home;
        iconColor = Colors.orange;
        break;
      case 'Car Purchase':
        icon = Icons.directions_car;
        iconColor = Colors.teal;
        break;
      case 'Wedding':
        icon = Icons.favorite;
        iconColor = Colors.pink;
        break;
      case 'Investment':
        icon = Icons.trending_up;
        iconColor = Colors.indigo;
        break;
      case 'Debt Payment':
        icon = Icons.payment;
        iconColor = Colors.deepOrange;
        break;
      case 'Retirement':
        icon = Icons.elderly;
        iconColor = Colors.brown;
        break;
      case 'Business':
        icon = Icons.business;
        iconColor = Colors.cyan;
        break;
      default:
        icon = Icons.category;
        iconColor = Colors.grey;
    }

    Color progressColor;
    if (progress >= 100) {
      progressColor = Colors.green;
    } else if (progress >= 80) {
      progressColor = Colors.orange;
    } else {
      progressColor = const Color(0xFFEE2B8D);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(priority).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        priority,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getPriorityColor(priority),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${progress.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: progressColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Ksh ${currentAmount.toStringAsFixed(0)} / Ksh ${targetAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: progressColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
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

  Widget _buildCriticalNotificationsSection() {
    return FutureBuilder<List<AppNotification>>(
      future: _notificationService.getCriticalNotifications(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final criticalNotifications = snapshot.data!;
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: Colors.red[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Critical Alerts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationCenterScreen()),
                      );
                      await _loadNotificationCount();
                    },
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFFEE2B8D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...criticalNotifications.take(3).map((notification) => 
                _buildCriticalNotificationItem(notification)
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCriticalNotificationItem(AppNotification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () async {
              await _notificationService.dismissNotification(notification.id);
              await _loadNotificationCount();
              setState(() {}); // Refresh the section
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMaliInsightsSection() {
    final totalIncome = _financialData['total_income'] ?? 0.0;
    final totalExpenses = _financialData['total_spending'] ?? 0.0;
    final netIncome = totalIncome - totalExpenses;
    final activeGoals = _financialData['active_goals'] as List<Map<String, dynamic>>? ?? [];
    final totalBudget = _financialData['total_budget'] ?? 0.0;
    final budgetSpent = _financialData['budget_spent'] ?? 0.0;

    // Generate smart insights
    String insight;
    String insightType;
    Color insightColor;
    IconData insightIcon;

    if (netIncome < 0) {
      insight = "You're spending more than you earn! Let's work on reducing expenses or increasing income.";
      insightType = "Spending Alert";
      insightColor = Colors.red;
      insightIcon = Icons.warning;
    } else if (activeGoals.isEmpty) {
      insight = "You don't have any financial goals set! Setting clear goals is key to financial success.";
      insightType = "Goal Setting";
      insightColor = Colors.orange;
      insightIcon = Icons.emoji_events;
    } else if (totalBudget > 0 && budgetSpent > totalBudget) {
      insight = "You're over budget this month! Consider reducing non-essential expenses.";
      insightType = "Budget Alert";
      insightColor = Colors.red;
      insightIcon = Icons.account_balance_wallet;
    } else if (netIncome > totalIncome * 0.2) {
      insight = "Great job! You're saving over 20% of your income. Keep up the excellent work!";
      insightType = "Savings Success";
      insightColor = Colors.green;
      insightIcon = Icons.trending_up;
    } else if (activeGoals.length >= 3) {
      insight = "You have multiple goals! Focus on one priority goal to make faster progress.";
      insightType = "Goal Focus";
      insightColor = Colors.blue;
      insightIcon = Icons.center_focus_strong;
    } else {
      insight = "Your financial health looks good! Keep tracking and stay consistent with your goals.";
      insightType = "Financial Health";
      insightColor = Colors.green;
      insightIcon = Icons.favorite;
    }

    return Container(
      width: double.infinity,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEE2B8D),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.smart_toy,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Mali\'s Insights',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MaliChatEnhanced()),
                  );
                },
                child: const Text(
                  'Chat with Mali',
                  style: TextStyle(
                    color: Color(0xFFEE2B8D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Insight Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: insightColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: insightColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  insightIcon,
                  color: insightColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insightType,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: insightColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        insight,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick Actions
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Ask Mali',
                  Icons.chat,
                  const Color(0xFFEE2B8D),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MaliChatEnhanced()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Get Advice',
                  Icons.lightbulb_outline,
                  Colors.orange,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MaliChatEnhanced()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
