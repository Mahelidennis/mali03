import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      category: json['category'],
      date: DateTime.parse(json['date']),
      note: json['note'],
    );
  }
}

class ExpenseTracker {
  static const String _expensesKey = 'user_expenses';
  static const String _categoriesKey = 'expense_categories';

  static final List<String> defaultCategories = [
    'Food & Dining',
    'Transport',
    'Shopping',
    'Bills & Utilities',
    'Entertainment',
    'Healthcare',
    'Education',
    'Coffee',
    'Other',
  ];

  // Add new expense
  static Future<void> addExpense(Expense expense) async {
    final prefs = await SharedPreferences.getInstance();
    final expenses = await getExpenses();
    expenses.add(expense);
    
    final expensesJson = expenses.map((e) => e.toJson()).toList();
    await prefs.setString(_expensesKey, jsonEncode(expensesJson));
  }

  // Get all expenses
  static Future<List<Expense>> getExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesString = prefs.getString(_expensesKey);
    
    if (expensesString == null) return [];
    
    final expensesJson = jsonDecode(expensesString) as List;
    return expensesJson.map((json) => Expense.fromJson(json)).toList();
  }

  // Get expenses by month
  static Future<List<Expense>> getExpensesByMonth(DateTime month) async {
    final allExpenses = await getExpenses();
    return allExpenses.where((expense) {
      return expense.date.year == month.year && 
             expense.date.month == month.month;
    }).toList();
  }

  // Get spending by category
  static Future<Map<String, double>> getSpendingByCategory(DateTime month) async {
    final expenses = await getExpensesByMonth(month);
    final spendingByCategory = <String, double>{};
    
    for (final expense in expenses) {
      spendingByCategory[expense.category] = 
          (spendingByCategory[expense.category] ?? 0) + expense.amount;
    }
    
    return spendingByCategory;
  }

  // Get total spending for month
  static Future<double> getTotalSpending(DateTime month) async {
    final expenses = await getExpensesByMonth(month);
    return expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
  }

  // Delete expense
  static Future<void> deleteExpense(String expenseId) async {
    final prefs = await SharedPreferences.getInstance();
    final expenses = await getExpenses();
    expenses.removeWhere((expense) => expense.id == expenseId);
    
    final expensesJson = expenses.map((e) => e.toJson()).toList();
    await prefs.setString(_expensesKey, jsonEncode(expensesJson));
  }

  // Update expense
  static Future<void> updateExpense(Expense updatedExpense) async {
    final prefs = await SharedPreferences.getInstance();
    final expenses = await getExpenses();
    
    final index = expenses.indexWhere((expense) => expense.id == updatedExpense.id);
    if (index != -1) {
      expenses[index] = updatedExpense;
    }
    
    final expensesJson = expenses.map((e) => e.toJson()).toList();
    await prefs.setString(_expensesKey, jsonEncode(expensesJson));
  }

  // Clear all expenses
  static Future<void> clearAllExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_expensesKey);
  }

  // Get spending insights
  static Future<Map<String, dynamic>> getSpendingInsights(DateTime month) async {
    final expenses = await getExpensesByMonth(month);
    final spendingByCategory = await getSpendingByCategory(month);
    final totalSpending = await getTotalSpending(month);
    
    // Find top spending category
    String topCategory = '';
    double topAmount = 0;
    spendingByCategory.forEach((category, amount) {
      if (amount > topAmount) {
        topAmount = amount;
        topCategory = category;
      }
    });

    // Calculate average daily spending
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final averageDailySpending = totalSpending / daysInMonth;

    return {
      'total_spending': totalSpending,
      'top_category': topCategory,
      'top_amount': topAmount,
      'average_daily': averageDailySpending,
      'category_breakdown': spendingByCategory,
      'expense_count': expenses.length,
    };
  }
} 