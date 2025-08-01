import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FinancialDataService {
  static const String _spendingKey = 'user_spending_data';
  static const String _savingsKey = 'user_savings_data';
  static const String _goalsKey = 'user_goals_data';
  static const String _budgetKey = 'user_budget_data';

  // Spending categories with Kenyan context
  static const List<String> spendingCategories = [
    'Coffee & Drinks',
    'Transport',
    'Food & Dining',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Healthcare',
    'Education',
    'Investment',
    'Savings',
    'Other',
  ];

  // Get current month's spending data
  static Future<Map<String, dynamic>> getCurrentMonthSpending() async {
    final prefs = await SharedPreferences.getInstance();
    final spendingJson = prefs.getString(_spendingKey);
    
    if (spendingJson != null) {
      final data = jsonDecode(spendingJson);
      final currentMonth = DateTime.now().month;
      final currentYear = DateTime.now().year;
      
      // Filter for current month
      final currentMonthData = data['$currentYear-$currentMonth'] ?? {};
      return Map<String, dynamic>.from(currentMonthData);
    }
    
    return {};
  }

  // Add spending transaction
  static Future<void> addSpendingTransaction({
    required String category,
    required double amount,
    String? description,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final spendingJson = prefs.getString(_spendingKey);
    
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;
    final monthKey = '$currentYear-$currentMonth';
    
    Map<String, dynamic> allData = {};
    if (spendingJson != null) {
      allData = Map<String, dynamic>.from(jsonDecode(spendingJson));
    }
    
    if (allData[monthKey] == null) {
      allData[monthKey] = {};
    }
    
    if (allData[monthKey][category] == null) {
      allData[monthKey][category] = 0.0;
    }
    
    allData[monthKey][category] = (allData[monthKey][category] as double) + amount;
    
    // Add transaction details
    if (allData[monthKey]['transactions'] == null) {
      allData[monthKey]['transactions'] = [];
    }
    
    allData[monthKey]['transactions'].add({
      'category': category,
      'amount': amount,
      'description': description ?? '',
      'date': DateTime.now().toIso8601String(),
    });
    
    await prefs.setString(_spendingKey, jsonEncode(allData));
  }

  // Get savings data
  static Future<Map<String, dynamic>> getSavingsData() async {
    final prefs = await SharedPreferences.getInstance();
    final savingsJson = prefs.getString(_savingsKey);
    
    if (savingsJson != null) {
      return Map<String, dynamic>.from(jsonDecode(savingsJson));
    }
    
    return {
      'current_savings': 0.0,
      'monthly_goal': 10000.0,
      'total_saved': 0.0,
      'savings_history': [],
    };
  }

  // Add savings transaction
  static Future<void> addSavingsTransaction({
    required double amount,
    String? source,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final savingsJson = prefs.getString(_savingsKey);
    
    Map<String, dynamic> savingsData = {
      'current_savings': 0.0,
      'monthly_goal': 10000.0,
      'total_saved': 0.0,
      'savings_history': [],
    };
    
    if (savingsJson != null) {
      savingsData = Map<String, dynamic>.from(jsonDecode(savingsJson));
    }
    
    savingsData['current_savings'] = (savingsData['current_savings'] as double) + amount;
    savingsData['total_saved'] = (savingsData['total_saved'] as double) + amount;
    
    savingsData['savings_history'].add({
      'amount': amount,
      'source': source ?? 'Manual',
      'date': DateTime.now().toIso8601String(),
    });
    
    await prefs.setString(_savingsKey, jsonEncode(savingsData));
  }

  // Get budget data
  static Future<Map<String, dynamic>> getBudgetData() async {
    final prefs = await SharedPreferences.getInstance();
    final budgetJson = prefs.getString(_budgetKey);
    
    if (budgetJson != null) {
      return Map<String, dynamic>.from(jsonDecode(budgetJson));
    }
    
    return {
      'monthly_budget': 25000.0,
      'spent_this_month': 0.0,
      'budget_categories': {},
    };
  }

  // Set monthly budget
  static Future<void> setMonthlyBudget(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    final budgetJson = prefs.getString(_budgetKey);
    
    Map<String, dynamic> budgetData = {
      'monthly_budget': amount,
      'spent_this_month': 0.0,
      'budget_categories': {},
    };
    
    if (budgetJson != null) {
      budgetData = Map<String, dynamic>.from(jsonDecode(budgetJson));
      budgetData['monthly_budget'] = amount;
    }
    
    await prefs.setString(_budgetKey, jsonEncode(budgetData));
  }

  // Get goals data
  static Future<Map<String, dynamic>> getGoalsData() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = prefs.getString(_goalsKey);
    
    if (goalsJson != null) {
      return Map<String, dynamic>.from(jsonDecode(goalsJson));
    }
    
    return {
      'active_goals': [],
      'completed_goals': [],
    };
  }

  // Add financial goal
  static Future<void> addFinancialGoal({
    required String title,
    required double targetAmount,
    required String category,
    DateTime? targetDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = prefs.getString(_goalsKey);
    
    Map<String, dynamic> goalsData = {
      'active_goals': [],
      'completed_goals': [],
    };
    
    if (goalsJson != null) {
      goalsData = Map<String, dynamic>.from(jsonDecode(goalsJson));
    }
    
    goalsData['active_goals'].add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'target_amount': targetAmount,
      'current_amount': 0.0,
      'category': category,
      'target_date': targetDate?.toIso8601String() ?? DateTime.now().add(const Duration(days: 90)).toIso8601String(),
      'created_date': DateTime.now().toIso8601String(),
    });
    
    await prefs.setString(_goalsKey, jsonEncode(goalsData));
  }

  // Get comprehensive financial data for AI
  static Future<Map<String, dynamic>> getComprehensiveFinancialData() async {
    final spendingData = await getCurrentMonthSpending();
    final savingsData = await getSavingsData();
    final budgetData = await getBudgetData();
    final goalsData = await getGoalsData();
    
    // Calculate total spent this month
    double totalSpent = 0.0;
    spendingData.forEach((category, amount) {
      if (amount is double) {
        totalSpent += amount;
      }
    });
    
    return {
      'current_savings': savingsData['current_savings'] ?? 0.0,
      'monthly_budget': budgetData['monthly_budget'] ?? 0.0,
      'spent_this_month': totalSpent,
      'active_goals': (goalsData['active_goals'] as List?)?.length ?? 0,
      'completed_goals': (goalsData['completed_goals'] as List?)?.length ?? 0,
      'coffee_spending': spendingData['Coffee & Drinks'] ?? 0.0,
      'transport_spending': spendingData['Transport'] ?? 0.0,
      'food_spending': spendingData['Food & Dining'] ?? 0.0,
      'shopping_spending': spendingData['Shopping'] ?? 0.0,
      'entertainment_spending': spendingData['Entertainment'] ?? 0.0,
      'spending_breakdown': spendingData,
      'budget_remaining': (budgetData['monthly_budget'] ?? 0.0) - totalSpent,
      'savings_progress': savingsData['current_savings'] ?? 0.0,
      'monthly_savings_goal': savingsData['monthly_goal'] ?? 0.0,
    };
  }

  // Get spending insights for AI
  static Future<List<Map<String, dynamic>>> getSpendingInsights() async {
    final spendingData = await getCurrentMonthSpending();
    final insights = <Map<String, dynamic>>[];
    
    spendingData.forEach((category, amount) {
      if (amount is double && amount > 0) {
        insights.add({
          'category': category,
          'amount': amount,
          'percentage': 0.0, // Will be calculated
        });
      }
    });
    
    // Calculate percentages
    double total = insights.fold(0.0, (sum, insight) => sum + (insight['amount'] as double));
    for (var insight in insights) {
      insight['percentage'] = total > 0 ? (insight['amount'] as double) / total * 100 : 0.0;
    }
    
    // Sort by amount (highest first)
    insights.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
    
    return insights;
  }
} 