import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'expense_tracker.dart';
import 'budget_alerts.dart';
import 'financial_reports.dart';
import 'dart:convert';

class DataBackupService {
  static const String _backupKey = 'data_backups';
  
  // Create backup data structure
  static Future<Map<String, dynamic>> createBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final currentTime = DateTime.now();
    
    // Get all user data
    final userProfile = prefs.getString('user_profile');
    final userIncomes = prefs.getStringList('user_incomes') ?? [];
    final userGoals = prefs.getStringList('user_goals') ?? [];
    final notificationSettings = prefs.getString('notification_settings');
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    final userOnboardingComplete = prefs.getBool('user_onboarding_complete') ?? false;
    
    // Get expenses
    final expenses = await ExpenseTracker.getExpenses();
    final expensesJson = expenses.map((expense) => expense.toJson()).toList();
    
    // Get alerts
    final alerts = await BudgetAlertManager.getAlerts();
    final alertsJson = alerts.map((alert) => alert.toJson()).toList();
    
    // Get reports
    final reports = await FinancialReportsManager.getReports();
    final reportsJson = reports.map((report) => report.toJson()).toList();
    
    final backupData = {
      'version': '1.0',
      'created_at': currentTime.toIso8601String(),
      'user_profile': userProfile,
      'user_incomes': userIncomes,
      'user_goals': userGoals,
      'notification_settings': notificationSettings,
      'onboarding_complete': onboardingComplete,
      'user_onboarding_complete': userOnboardingComplete,
      'expenses': expensesJson,
      'alerts': alertsJson,
      'reports': reportsJson,
    };
    
    return backupData;
  }

  // Save backup
  static Future<void> saveBackup(Map<String, dynamic> backupData) async {
    final prefs = await SharedPreferences.getInstance();
    final backups = await getBackups();
    
    final backupId = DateTime.now().millisecondsSinceEpoch.toString();
    backupData['id'] = backupId;
    
    backups.add(backupData);
    
    // Keep only last 10 backups
    if (backups.length > 10) {
      backups.removeRange(0, backups.length - 10);
    }
    
    final backupsJson = backups.map((backup) => jsonEncode(backup)).toList();
    await prefs.setStringList(_backupKey, backupsJson);
  }

  // Get all backups
  static Future<List<Map<String, dynamic>>> getBackups() async {
    final prefs = await SharedPreferences.getInstance();
    final backupsString = prefs.getStringList(_backupKey) ?? [];
    
    return backupsString.map((backupString) {
      return jsonDecode(backupString) as Map<String, dynamic>;
    }).toList();
  }

  // Restore from backup
  static Future<bool> restoreFromBackup(Map<String, dynamic> backupData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Restore user profile
      if (backupData['user_profile'] != null) {
        await prefs.setString('user_profile', backupData['user_profile']);
      }
      
      // Restore incomes
      if (backupData['user_incomes'] != null) {
        await prefs.setStringList('user_incomes', List<String>.from(backupData['user_incomes']));
      }
      
      // Restore goals
      if (backupData['user_goals'] != null) {
        await prefs.setStringList('user_goals', List<String>.from(backupData['user_goals']));
      }
      
      // Restore notification settings
      if (backupData['notification_settings'] != null) {
        await prefs.setString('notification_settings', backupData['notification_settings']);
      }
      
      // Restore onboarding status
      if (backupData['onboarding_complete'] != null) {
        await prefs.setBool('onboarding_complete', backupData['onboarding_complete']);
      }
      
      if (backupData['user_onboarding_complete'] != null) {
        await prefs.setBool('user_onboarding_complete', backupData['user_onboarding_complete']);
      }
      
      // Restore expenses
      if (backupData['expenses'] != null) {
        final expenses = (backupData['expenses'] as List).map((expenseJson) {
          return Expense.fromJson(expenseJson as Map<String, dynamic>);
        }).toList();
        
        // Clear existing expenses and add restored ones
        await ExpenseTracker.clearAllExpenses();
        for (final expense in expenses) {
          await ExpenseTracker.addExpense(expense);
        }
      }
      
      // Restore alerts
      if (backupData['alerts'] != null) {
        final alerts = (backupData['alerts'] as List).map((alertJson) {
          return BudgetAlert.fromJson(alertJson as Map<String, dynamic>);
        }).toList();
        
        // Clear existing alerts and add restored ones
        await BudgetAlertManager.clearAllAlerts();
        for (final alert in alerts) {
          await BudgetAlertManager.saveAlerts([alert]);
        }
      }
      
      // Restore reports
      if (backupData['reports'] != null) {
        final reports = (backupData['reports'] as List).map((reportJson) {
          return FinancialReport.fromJson(reportJson as Map<String, dynamic>);
        }).toList();
        
        // Clear existing reports and add restored ones
        await FinancialReportsManager.clearAllReports();
        for (final report in reports) {
          await FinancialReportsManager.saveReport(report);
        }
      }
      
      return true;
    } catch (e) {
      print('Error restoring backup: $e');
      return false;
    }
  }

  // Export backup as JSON
  static String exportBackupAsJson(Map<String, dynamic> backupData) {
    return jsonEncode(backupData);
  }

  // Import backup from JSON
  static Map<String, dynamic>? importBackupFromJson(String jsonString) {
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error importing backup: $e');
      return null;
    }
  }

  // Delete backup
  static Future<void> deleteBackup(String backupId) async {
    final prefs = await SharedPreferences.getInstance();
    final backups = await getBackups();
    
    backups.removeWhere((backup) => backup['id'] == backupId);
    
    final backupsJson = backups.map((backup) => jsonEncode(backup)).toList();
    await prefs.setStringList(_backupKey, backupsJson);
  }

  // Get backup size
  static String getBackupSize(Map<String, dynamic> backupData) {
    final jsonString = jsonEncode(backupData);
    final bytes = utf8.encode(jsonString).length;
    
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  // Validate backup
  static bool isValidBackup(Map<String, dynamic> backupData) {
    return backupData.containsKey('version') && 
           backupData.containsKey('created_at') &&
           backupData.containsKey('user_profile');
  }
} 