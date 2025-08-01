import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'expense_tracker.dart';
import 'dart:convert';

class BudgetAlert {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String type; // 'spending', 'goal', 'budget', 'savings'
  final bool isRead;

  BudgetAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'isRead': isRead,
    };
  }

  factory BudgetAlert.fromJson(Map<String, dynamic> json) {
    return BudgetAlert(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
      isRead: json['isRead'] ?? false,
    );
  }
}

class BudgetAlertManager {
  static const String _alertsKey = 'budget_alerts';

  // Check for new alerts based on spending patterns
  static Future<List<BudgetAlert>> checkForAlerts() async {
    final currentMonth = DateTime.now();
    final spendingInsights = await ExpenseTracker.getSpendingInsights(currentMonth);
    final totalSpending = spendingInsights['total_spending'] ?? 0.0;
    final topCategory = spendingInsights['top_category'] ?? '';
    final topAmount = spendingInsights['top_amount'] ?? 0.0;
    final averageDaily = spendingInsights['average_daily'] ?? 0.0;

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

    final savings = totalIncome - totalSpending;
    final savingsRate = totalIncome > 0 ? (savings / totalIncome * 100) : 0.0;

    List<BudgetAlert> alerts = [];

    // High spending alert
    if (topAmount > 15000) {
      alerts.add(BudgetAlert(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'High Spending Alert! 💸',
        message: 'Girl, you spent KSh ${topAmount.toStringAsFixed(0)} on $topCategory this month! That\'s a lot! Maybe set a budget for this category? 💡',
        timestamp: DateTime.now(),
        type: 'spending',
      ));
    }

    // Daily spending alert
    if (averageDaily > 3000) {
      alerts.add(BudgetAlert(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        title: 'Daily Spending Alert! 📊',
        message: 'Your daily spending is KSh ${averageDaily.toStringAsFixed(0)}. That\'s quite high! Try to reduce it to save more! 💪',
        timestamp: DateTime.now(),
        type: 'spending',
      ));
    }

    // Low savings alert
    if (savingsRate < 10 && totalIncome > 0) {
      alerts.add(BudgetAlert(
        id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
        title: 'Low Savings Alert! 💰',
        message: 'Your savings rate is only ${savingsRate.toStringAsFixed(1)}%. Try to save at least 20% of your income! 💡',
        timestamp: DateTime.now(),
        type: 'savings',
      ));
    }

    // Over budget alert
    if (savings < 0) {
      alerts.add(BudgetAlert(
        id: (DateTime.now().millisecondsSinceEpoch + 3).toString(),
        title: 'Over Budget Alert! ⚠️',
        message: 'Girl, you\'re spending more than you earn! You\'re KSh ${(-savings).toStringAsFixed(0)} over budget. Let\'s fix this! 💪',
        timestamp: DateTime.now(),
        type: 'budget',
      ));
    }

    // Goal progress alerts
    final goalsString = prefs.getStringList('user_goals') ?? [];
    if (goalsString.isNotEmpty) {
      double totalGoals = 0;
      for (final goalString in goalsString) {
        final goalData = jsonDecode(goalString);
        totalGoals += goalData['amount'];
      }

      final progressPercentage = totalGoals > 0 ? (savings / totalGoals * 100).clamp(0.0, 100.0) : 0.0;

      if (progressPercentage >= 50 && progressPercentage < 100) {
        alerts.add(BudgetAlert(
          id: (DateTime.now().millisecondsSinceEpoch + 4).toString(),
          title: 'Goal Progress Alert! 🎯',
          message: 'You\'re ${progressPercentage.toStringAsFixed(1)}% to your goals! Keep pushing, girl! You\'re doing amazing! 💪',
          timestamp: DateTime.now(),
          type: 'goal',
        ));
      }
    }

    // Save new alerts
    if (alerts.isNotEmpty) {
      await saveAlerts(alerts);
    }

    return alerts;
  }

  // Get all alerts
  static Future<List<BudgetAlert>> getAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final alertsString = prefs.getStringList(_alertsKey) ?? [];
    
    return alertsString.map((alertString) {
      return BudgetAlert.fromJson(jsonDecode(alertString));
    }).toList();
  }

  // Save alerts
  static Future<void> saveAlerts(List<BudgetAlert> newAlerts) async {
    final prefs = await SharedPreferences.getInstance();
    final existingAlerts = await getAlerts();
    
    // Add new alerts to existing ones
    final allAlerts = [...existingAlerts, ...newAlerts];
    
    // Keep only last 50 alerts
    final recentAlerts = allAlerts.take(50).toList();
    
    final alertsJson = recentAlerts.map((alert) => jsonEncode(alert.toJson())).toList();
    await prefs.setStringList(_alertsKey, alertsJson);
  }

  // Mark alert as read
  static Future<void> markAsRead(String alertId) async {
    final prefs = await SharedPreferences.getInstance();
    final alerts = await getAlerts();
    
    for (int i = 0; i < alerts.length; i++) {
      if (alerts[i].id == alertId) {
        alerts[i] = BudgetAlert(
          id: alerts[i].id,
          title: alerts[i].title,
          message: alerts[i].message,
          timestamp: alerts[i].timestamp,
          type: alerts[i].type,
          isRead: true,
        );
        break;
      }
    }
    
    final alertsJson = alerts.map((alert) => jsonEncode(alert.toJson())).toList();
    await prefs.setStringList(_alertsKey, alertsJson);
  }

  // Clear all alerts
  static Future<void> clearAllAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_alertsKey);
  }

  // Get unread count
  static Future<int> getUnreadCount() async {
    final alerts = await getAlerts();
    return alerts.where((alert) => !alert.isRead).length;
  }
} 