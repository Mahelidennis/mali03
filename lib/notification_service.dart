import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'budget_alerts.dart';
import 'expense_tracker.dart';
import 'dart:convert';

class NotificationService {
  static const String _notificationSettingsKey = 'notification_settings';
  
  // Notification settings
  static Future<Map<String, bool>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsString = prefs.getString(_notificationSettingsKey);
    
    if (settingsString != null) {
      final settings = jsonDecode(settingsString) as Map<String, dynamic>;
      return Map<String, bool>.from(settings);
    }
    
    // Default settings
    return {
      'spending_alerts': true,
      'savings_alerts': true,
      'goal_alerts': true,
      'budget_alerts': true,
      'daily_reminders': true,
      'weekly_reports': true,
    };
  }

  static Future<void> updateNotificationSettings(Map<String, bool> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationSettingsKey, jsonEncode(settings));
  }

  // Check and send notifications
  static Future<void> checkAndSendNotifications() async {
    final settings = await getNotificationSettings();
    
    // Only send notifications if enabled
    if (!settings.values.any((enabled) => enabled)) {
      return;
    }

    final alerts = await BudgetAlertManager.checkForAlerts();
    
    for (final alert in alerts) {
      final shouldSend = _shouldSendNotification(alert.type, settings);
      if (shouldSend) {
        await _showLocalNotification(alert);
      }
    }
  }

  static bool _shouldSendNotification(String alertType, Map<String, bool> settings) {
    switch (alertType) {
      case 'spending':
        return settings['spending_alerts'] ?? false;
      case 'savings':
        return settings['savings_alerts'] ?? false;
      case 'goal':
        return settings['goal_alerts'] ?? false;
      case 'budget':
        return settings['budget_alerts'] ?? false;
      default:
        return false;
    }
  }

  static Future<void> _showLocalNotification(BudgetAlert alert) async {
    // For now, we'll use SnackBar as a simple notification
    // In a real app, you'd use flutter_local_notifications package
    print('🔔 Notification: ${alert.title} - ${alert.message}');
  }

  // Daily reminder notification
  static Future<void> sendDailyReminder() async {
    final settings = await getNotificationSettings();
    if (!(settings['daily_reminders'] ?? false)) return;

    final currentMonth = DateTime.now();
    final spendingInsights = await ExpenseTracker.getSpendingInsights(currentMonth);
    final totalSpending = spendingInsights['total_spending'] ?? 0.0;
    
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
    
    String reminderMessage = '';
    if (savings > 0) {
      reminderMessage = 'Great job! You saved KSh ${savings.toStringAsFixed(0)} today. Keep it up! 💪';
    } else if (totalSpending > 0) {
      reminderMessage = 'You spent KSh ${totalSpending.toStringAsFixed(0)} today. Remember to track your expenses! 📊';
    } else {
      reminderMessage = 'Don\'t forget to track your income and expenses today! 💰';
    }

    print('🔔 Daily Reminder: $reminderMessage');
  }

  // Weekly report notification
  static Future<void> sendWeeklyReport() async {
    final settings = await getNotificationSettings();
    if (!(settings['weekly_reports'] ?? false)) return;

    final currentMonth = DateTime.now();
    final spendingInsights = await ExpenseTracker.getSpendingInsights(currentMonth);
    final totalSpending = spendingInsights['total_spending'] ?? 0.0;
    
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

    String reportMessage = '📊 Weekly Report: Income KSh ${totalIncome.toStringAsFixed(0)}, Spending KSh ${totalSpending.toStringAsFixed(0)}, Savings ${savingsRate.toStringAsFixed(1)}%';

    print('🔔 Weekly Report: $reportMessage');
  }

  // Custom notification
  static Future<void> sendCustomNotification(String title, String message) async {
    print('🔔 Custom Notification: $title - $message');
  }
} 