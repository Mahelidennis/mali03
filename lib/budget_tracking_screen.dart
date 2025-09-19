import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BudgetTrackingScreen extends StatefulWidget {
  const BudgetTrackingScreen({super.key});

  @override
  State<BudgetTrackingScreen> createState() => _BudgetTrackingScreenState();
}

class _BudgetTrackingScreenState extends State<BudgetTrackingScreen> {
  List<Map<String, dynamic>> _budgets = [];
  List<Map<String, dynamic>> _expenses = [];
  bool _isLoading = true;
  String _selectedPeriod = 'Monthly';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    final prefs = await SharedPreferences.getInstance();
    
    // Load budgets
    final budgetsStringList = prefs.getStringList('user_budgets') ?? [];
    _budgets = budgetsStringList
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList();
    
    // Load expenses
    final expensesStringList = prefs.getStringList('user_expenses') ?? [];
    _expenses = expensesStringList
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList();
    
    setState(() {
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredBudgets {
    return _budgets.where((budget) {
      return budget['period'] == _selectedPeriod;
    }).toList();
  }

  double _getSpentAmount(String category, String period) {
    final now = DateTime.now();
    return _expenses.where((expense) {
      final expenseDate = DateTime.parse(expense['date']);
      final expenseCategory = expense['category'];
      
      if (expenseCategory != category) return false;
      
      switch (period) {
        case 'Weekly':
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final weekEnd = weekStart.add(const Duration(days: 6));
          return expenseDate.isAfter(weekStart.subtract(const Duration(days: 1))) && 
                 expenseDate.isBefore(weekEnd.add(const Duration(days: 1)));
        case 'Monthly':
          return expenseDate.year == now.year && expenseDate.month == now.month;
        case 'Yearly':
          return expenseDate.year == now.year;
        default:
          return false;
      }
    }).fold(0.0, (sum, expense) => sum + (expense['amount'] ?? 0.0));
  }

  List<Map<String, dynamic>> get _budgetAlerts {
    final alerts = <Map<String, dynamic>>[];
    
    for (final budget in _filteredBudgets) {
      final category = budget['category'];
      final budgetAmount = budget['amount'];
      final spentAmount = _getSpentAmount(category, budget['period']);
      final percentage = budgetAmount > 0 ? (spentAmount / budgetAmount) * 100 : 0.0;
      
      if (percentage >= 100) {
        alerts.add({
          'type': 'exceeded',
          'category': category,
          'budget': budgetAmount,
          'spent': spentAmount,
          'percentage': percentage,
          'message': 'You\'ve exceeded your $category budget!',
          'color': Colors.red,
        });
      } else if (percentage >= 80) {
        alerts.add({
          'type': 'warning',
          'category': category,
          'budget': budgetAmount,
          'spent': spentAmount,
          'percentage': percentage,
          'message': 'You\'re close to exceeding your $category budget',
          'color': Colors.orange,
        });
      }
    }
    
    return alerts;
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food & Dining':
        return Icons.restaurant;
      case 'Transportation':
        return Icons.directions_car;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Entertainment':
        return Icons.movie;
      case 'Healthcare':
        return Icons.local_hospital;
      case 'Education':
        return Icons.school;
      case 'Utilities':
        return Icons.electrical_services;
      case 'Travel':
        return Icons.flight;
      case 'Personal Care':
        return Icons.face;
      case 'Personal Care':
        return Icons.face;
      case 'Gifts & Donations':
        return Icons.card_giftcard;
      case 'Insurance':
        return Icons.security;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food & Dining':
        return Colors.orange;
      case 'Transportation':
        return Colors.blue;
      case 'Shopping':
        return Colors.purple;
      case 'Entertainment':
        return Colors.red;
      case 'Healthcare':
        return Colors.green;
      case 'Education':
        return Colors.indigo;
      case 'Utilities':
        return Colors.amber;
      case 'Travel':
        return Colors.teal;
      case 'Personal Care':
        return Colors.pink;
      case 'Gifts & Donations':
        return Colors.cyan;
      case 'Insurance':
        return Colors.deepOrange;
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
          'Budget Tracking',
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
                  // Period Filter
                  _buildPeriodFilter(),
                  const SizedBox(height: 24),

                  // Budget Alerts
                  if (_budgetAlerts.isNotEmpty) ...[
                    _buildBudgetAlerts(),
                    const SizedBox(height: 24),
                  ],

                  // Budget Overview
                  _buildBudgetOverview(),
                  const SizedBox(height: 24),

                  // Individual Budget Progress
                  _buildBudgetProgress(),
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ['Weekly', 'Monthly', 'Yearly'].map((period) {
        final isSelected = _selectedPeriod == period;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPeriod = period;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEE2B8D) : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              period,
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

  Widget _buildBudgetAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budget Alerts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ..._budgetAlerts.map((alert) => _buildAlertCard(alert)),
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
            alert['type'] == 'exceeded' ? Icons.warning : Icons.info,
            color: alert['color'] as Color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert['message'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: alert['color'] as Color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Budget: Ksh ${alert['budget'].toStringAsFixed(0)} • Spent: Ksh ${alert['spent'].toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetOverview() {
    final totalBudget = _filteredBudgets.fold(0.0, (sum, budget) => sum + (budget['amount'] ?? 0.0));
    final totalSpent = _filteredBudgets.fold(0.0, (sum, budget) {
      return sum + _getSpentAmount(budget['category'], budget['period']);
    });
    final remaining = totalBudget - totalSpent;
    final percentage = totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0.0;

    Color cardColor;
    if (percentage >= 100) {
      cardColor = Colors.red[800]!;
    } else if (percentage >= 80) {
      cardColor = Colors.orange[800]!;
    } else {
      cardColor = Colors.green[800]!;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardColor,
            cardColor.withOpacity(0.8),
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
            'Budget Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Ksh ${totalBudget.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Spent',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Ksh ${totalSpent.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Remaining: Ksh ${remaining.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
              widthFactor: percentage / 100,
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

  Widget _buildBudgetProgress() {
    if (_filteredBudgets.isEmpty) {
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
              Icons.account_balance_wallet,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No budgets to track',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set up budgets to start tracking your spending',
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
          'Budget Progress',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ..._filteredBudgets.map((budget) => _buildBudgetProgressItem(budget)),
      ],
    );
  }

  Widget _buildBudgetProgressItem(Map<String, dynamic> budget) {
    final category = budget['category'] ?? 'Other';
    final budgetAmount = budget['amount'] ?? 0.0;
    final spentAmount = _getSpentAmount(category, budget['period']);
    final remaining = budgetAmount - spentAmount;
    final percentage = budgetAmount > 0 ? (spentAmount / budgetAmount) * 100 : 0.0;

    Color progressColor;
    if (percentage >= 100) {
      progressColor = Colors.red;
    } else if (percentage >= 80) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.green;
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
                      category,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${budget['period']} Budget',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
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
                    'Budget: Ksh ${budgetAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Spent: Ksh ${spentAmount.toStringAsFixed(0)}',
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
                      color: remaining >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  if (percentage >= 80)
                    Text(
                      percentage >= 100 ? 'Budget Exceeded!' : 'Almost at limit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
              widthFactor: percentage / 100,
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
