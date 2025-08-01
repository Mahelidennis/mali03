import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'expense_tracker.dart';
import 'dart:convert';

class FinancialReport {
  final String title;
  final DateTime generatedDate;
  final Map<String, dynamic> data;
  final String type; // 'monthly', 'summary', 'detailed'

  FinancialReport({
    required this.title,
    required this.generatedDate,
    required this.data,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'generatedDate': generatedDate.toIso8601String(),
      'data': data,
      'type': type,
    };
  }

  factory FinancialReport.fromJson(Map<String, dynamic> json) {
    return FinancialReport(
      title: json['title'],
      generatedDate: DateTime.parse(json['generatedDate']),
      data: json['data'],
      type: json['type'],
    );
  }
}

class FinancialReportsManager {
  static const String _reportsKey = 'financial_reports';

  // Generate monthly report
  static Future<FinancialReport> generateMonthlyReport(DateTime month) async {
    final spendingInsights = await ExpenseTracker.getSpendingInsights(month);
    
    // Get income data
    final prefs = await SharedPreferences.getInstance();
    final incomesString = prefs.getStringList('user_incomes') ?? [];
    double totalIncome = 0;
    Map<String, double> incomeByCategory = {};
    
    for (final incomeString in incomesString) {
      final incomeData = jsonDecode(incomeString);
      final incomeDate = DateTime.parse(incomeData['date']);
      if (incomeDate.year == month.year && incomeDate.month == month.month) {
        totalIncome += incomeData['amount'];
        final category = incomeData['category'];
        incomeByCategory[category] = (incomeByCategory[category] ?? 0) + incomeData['amount'];
      }
    }

    // Get goals data
    final goalsString = prefs.getStringList('user_goals') ?? [];
    double totalGoals = 0;
    List<Map<String, dynamic>> goals = [];
    
    for (final goalString in goalsString) {
      final goalData = jsonDecode(goalString);
      totalGoals += goalData['amount'];
      goals.add(goalData);
    }

    final totalSpending = spendingInsights['total_spending'] ?? 0.0;
    final savings = totalIncome - totalSpending;
    final savingsRate = totalIncome > 0 ? (savings / totalIncome * 100) : 0.0;

    final reportData = {
      'month': '${month.year}-${month.month.toString().padLeft(2, '0')}',
      'total_income': totalIncome,
      'total_spending': totalSpending,
      'savings': savings,
      'savings_rate': savingsRate,
      'income_by_category': incomeByCategory,
      'spending_by_category': spendingInsights['category_breakdown'] ?? {},
      'top_spending_category': spendingInsights['top_category'] ?? '',
      'top_spending_amount': spendingInsights['top_amount'] ?? 0.0,
      'average_daily_spending': spendingInsights['average_daily'] ?? 0.0,
      'expense_count': spendingInsights['expense_count'] ?? 0,
      'income_count': incomesString.length,
      'total_goals': totalGoals,
      'goals': goals,
      'days_in_month': DateTime(month.year, month.month + 1, 0).day,
    };

    return FinancialReport(
      title: 'Monthly Financial Report - ${month.year}-${month.month.toString().padLeft(2, '0')}',
      generatedDate: DateTime.now(),
      data: reportData,
      type: 'monthly',
    );
  }

  // Generate summary report
  static Future<FinancialReport> generateSummaryReport() async {
    final currentMonth = DateTime.now();
    final spendingInsights = await ExpenseTracker.getSpendingInsights(currentMonth);
    
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

    // Get goals data
    final goalsString = prefs.getStringList('user_goals') ?? [];
    double totalGoals = 0;
    
    for (final goalString in goalsString) {
      final goalData = jsonDecode(goalString);
      totalGoals += goalData['amount'];
    }

    final totalSpending = spendingInsights['total_spending'] ?? 0.0;
    final savings = totalIncome - totalSpending;
    final savingsRate = totalIncome > 0 ? (savings / totalIncome * 100) : 0.0;
    final progressPercentage = totalGoals > 0 ? (savings / totalGoals * 100).clamp(0.0, 100.0) : 0.0;

    final reportData = {
      'current_savings': savings,
      'total_income': totalIncome,
      'total_spending': totalSpending,
      'savings_rate': savingsRate,
      'total_goals': totalGoals,
      'goal_progress': progressPercentage,
      'top_spending_category': spendingInsights['top_category'] ?? '',
      'expense_count': spendingInsights['expense_count'] ?? 0,
      'income_count': incomesString.length,
      'goal_count': goalsString.length,
    };

    return FinancialReport(
      title: 'Financial Summary Report',
      generatedDate: DateTime.now(),
      data: reportData,
      type: 'summary',
    );
  }

  // Save report
  static Future<void> saveReport(FinancialReport report) async {
    final prefs = await SharedPreferences.getInstance();
    final reports = await getReports();
    reports.add(report);
    
    final reportsJson = reports.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_reportsKey, reportsJson);
  }

  // Get all reports
  static Future<List<FinancialReport>> getReports() async {
    final prefs = await SharedPreferences.getInstance();
    final reportsString = prefs.getStringList(_reportsKey) ?? [];
    
    return reportsString.map((reportString) {
      return FinancialReport.fromJson(jsonDecode(reportString));
    }).toList();
  }

  // Clear all reports
  static Future<void> clearAllReports() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_reportsKey);
  }

  // Generate CSV data
  static String generateCSV(FinancialReport report) {
    final data = report.data;
    final csv = StringBuffer();
    
    // Header
    csv.writeln('Financial Report: ${report.title}');
    csv.writeln('Generated: ${report.generatedDate.toIso8601String()}');
    csv.writeln('');
    
    // Summary data
    csv.writeln('Summary');
    csv.writeln('Metric,Value');
    csv.writeln('Total Income,KSh ${data['total_income']?.toStringAsFixed(0) ?? '0'}');
    csv.writeln('Total Spending,KSh ${data['total_spending']?.toStringAsFixed(0) ?? '0'}');
    csv.writeln('Savings,KSh ${data['savings']?.toStringAsFixed(0) ?? '0'}');
    csv.writeln('Savings Rate,${data['savings_rate']?.toStringAsFixed(1) ?? '0'}%');
    csv.writeln('');
    
    // Income breakdown
    if (data['income_by_category'] != null) {
      csv.writeln('Income Breakdown');
      csv.writeln('Category,Amount');
      final incomeByCategory = data['income_by_category'] as Map<String, dynamic>;
      incomeByCategory.forEach((category, amount) {
        csv.writeln('$category,KSh ${amount.toStringAsFixed(0)}');
      });
      csv.writeln('');
    }
    
    // Spending breakdown
    if (data['spending_by_category'] != null) {
      csv.writeln('Spending Breakdown');
      csv.writeln('Category,Amount');
      final spendingByCategory = data['spending_by_category'] as Map<String, dynamic>;
      spendingByCategory.forEach((category, amount) {
        csv.writeln('$category,KSh ${amount.toStringAsFixed(0)}');
      });
      csv.writeln('');
    }
    
    // Goals
    if (data['goals'] != null) {
      csv.writeln('Financial Goals');
      csv.writeln('Goal,Target Amount');
      final goals = data['goals'] as List<dynamic>;
      for (final goal in goals) {
        csv.writeln('${goal['title']},KSh ${goal['amount'].toStringAsFixed(0)}');
      }
    }
    
    return csv.toString();
  }

  // Generate text report
  static String generateTextReport(FinancialReport report) {
    final data = report.data;
    final text = StringBuffer();
    
    text.writeln('${report.title}');
    text.writeln('Generated on: ${report.generatedDate.toString()}');
    text.writeln('');
    text.writeln('📊 FINANCIAL SUMMARY');
    text.writeln('====================');
    text.writeln('💰 Total Income: KSh ${data['total_income']?.toStringAsFixed(0) ?? '0'}');
    text.writeln('💸 Total Spending: KSh ${data['total_spending']?.toStringAsFixed(0) ?? '0'}');
    text.writeln('💪 Savings: KSh ${data['savings']?.toStringAsFixed(0) ?? '0'}');
    text.writeln('📈 Savings Rate: ${data['savings_rate']?.toStringAsFixed(1) ?? '0'}%');
    text.writeln('');
    
    if (data['income_by_category'] != null) {
      text.writeln('📥 INCOME BREAKDOWN');
      text.writeln('==================');
      final incomeByCategory = data['income_by_category'] as Map<String, dynamic>;
      incomeByCategory.forEach((category, amount) {
        text.writeln('• $category: KSh ${amount.toStringAsFixed(0)}');
      });
      text.writeln('');
    }
    
    if (data['spending_by_category'] != null) {
      text.writeln('📤 SPENDING BREAKDOWN');
      text.writeln('====================');
      final spendingByCategory = data['spending_by_category'] as Map<String, dynamic>;
      spendingByCategory.forEach((category, amount) {
        text.writeln('• $category: KSh ${amount.toStringAsFixed(0)}');
      });
      text.writeln('');
    }
    
    if (data['goals'] != null) {
      text.writeln('🎯 FINANCIAL GOALS');
      text.writeln('=================');
      final goals = data['goals'] as List<dynamic>;
      for (final goal in goals) {
        text.writeln('• ${goal['title']}: KSh ${goal['amount'].toStringAsFixed(0)}');
      }
      text.writeln('');
    }
    
    text.writeln('Generated by Mali - Your Financial Big Sister 💅');
    
    return text.toString();
  }
} 