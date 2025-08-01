import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Budget {
  final String id;
  final String name;
  final double amount;
  final String category;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  Budget({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      name: json['name'],
      amount: json['amount'].toDouble(),
      category: json['category'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isActive: json['isActive'] ?? true,
    );
  }
}

class BudgetTracker {
  static const String _budgetsKey = 'user_budgets';
  static const String _savingsKey = 'user_savings';

  // Add new budget
  static Future<void> addBudget(Budget budget) async {
    final prefs = await SharedPreferences.getInstance();
    final budgets = await getBudgets();
    budgets.add(budget);
    
    final budgetsJson = budgets.map((b) => b.toJson()).toList();
    await prefs.setString(_budgetsKey, jsonEncode(budgetsJson));
  }

  // Get all budgets
  static Future<List<Budget>> getBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final budgetsString = prefs.getString(_budgetsKey);
    
    if (budgetsString == null) return [];
    
    final budgetsJson = jsonDecode(budgetsString) as List;
    return budgetsJson.map((json) => Budget.fromJson(json)).toList();
  }

  // Get active budgets
  static Future<List<Budget>> getActiveBudgets() async {
    final budgets = await getBudgets();
    return budgets.where((budget) => budget.isActive).toList();
  }

  // Update budget
  static Future<void> updateBudget(Budget updatedBudget) async {
    final prefs = await SharedPreferences.getInstance();
    final budgets = await getBudgets();
    
    final index = budgets.indexWhere((budget) => budget.id == updatedBudget.id);
    if (index != -1) {
      budgets[index] = updatedBudget;
    }
    
    final budgetsJson = budgets.map((b) => b.toJson()).toList();
    await prefs.setString(_budgetsKey, jsonEncode(budgetsJson));
  }

  // Delete budget
  static Future<void> deleteBudget(String budgetId) async {
    final prefs = await SharedPreferences.getInstance();
    final budgets = await getBudgets();
    budgets.removeWhere((budget) => budget.id == budgetId);
    
    final budgetsJson = budgets.map((b) => b.toJson()).toList();
    await prefs.setString(_budgetsKey, jsonEncode(budgetsJson));
  }

  // Get budget progress
  static Future<Map<String, dynamic>> getBudgetProgress(String budgetId) async {
    final budgets = await getBudgets();
    final budget = budgets.firstWhere((b) => b.id == budgetId);
    
    // Calculate progress based on time elapsed
    final now = DateTime.now();
    final totalDays = budget.endDate.difference(budget.startDate).inDays;
    final elapsedDays = now.difference(budget.startDate).inDays;
    
    final progressPercentage = (elapsedDays / totalDays * 100).clamp(0.0, 100.0);
    
    return {
      'budget': budget,
      'progress_percentage': progressPercentage,
      'days_elapsed': elapsedDays,
      'total_days': totalDays,
      'days_remaining': totalDays - elapsedDays,
    };
  }

  // Track savings
  static Future<void> addSavings(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    final currentSavings = await getCurrentSavings();
    final newTotal = currentSavings + amount;
    
    await prefs.setDouble(_savingsKey, newTotal);
  }

  // Get current savings
  static Future<double> getCurrentSavings() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_savingsKey) ?? 0.0;
  }

  // Get savings goal progress
  static Future<Map<String, dynamic>> getSavingsProgress(double monthlyGoal) async {
    final currentSavings = await getCurrentSavings();
    final progressPercentage = (currentSavings / monthlyGoal * 100).clamp(0.0, 100.0);
    
    return {
      'current_savings': currentSavings,
      'monthly_goal': monthlyGoal,
      'progress_percentage': progressPercentage,
      'remaining': monthlyGoal - currentSavings,
    };
  }

  // Get budget insights
  static Future<Map<String, dynamic>> getBudgetInsights() async {
    final budgets = await getActiveBudgets();
    final currentSavings = await getCurrentSavings();
    
    double totalBudgetAmount = 0;
    double totalSpent = 0;
    
    for (final budget in budgets) {
      totalBudgetAmount += budget.amount;
      // This would integrate with expense tracker
      // For now, using mock data
      totalSpent += budget.amount * 0.7; // 70% spent
    }
    
    final budgetUtilization = (totalSpent / totalBudgetAmount * 100).clamp(0.0, 100.0);
    
    return {
      'active_budgets': budgets.length,
      'total_budget_amount': totalBudgetAmount,
      'total_spent': totalSpent,
      'budget_utilization': budgetUtilization,
      'current_savings': currentSavings,
      'budgets': budgets,
    };
  }
} 