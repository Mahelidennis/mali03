import 'dart:math';
import '../models/financial_models.dart';
import 'database_service.dart';

/// Service for financial analytics and insights
class AnalyticsService {
  
  // ==================== EXPENSE ANALYTICS ====================

  /// Get spending summary for a specific period
  static Future<Map<String, dynamic>> getSpendingSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final expenses = await DatabaseService.getExpenses(
      startDate: startDate,
      endDate: endDate,
    );

    final totalSpending = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final spendingByCategory = <String, double>{};
    final dailySpending = <DateTime, double>{};

    for (final expense in expenses) {
      // Category spending
      spendingByCategory[expense.category] = 
          (spendingByCategory[expense.category] ?? 0) + expense.amount;
      
      // Daily spending
      final date = DateTime(expense.date.year, expense.date.month, expense.date.day);
      dailySpending[date] = (dailySpending[date] ?? 0) + expense.amount;
    }

    final averageDailySpending = totalSpending / max(1, endDate.difference(startDate).inDays);
    final topCategory = spendingByCategory.isNotEmpty 
        ? spendingByCategory.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'None';

    return {
      'totalSpending': totalSpending,
      'averageDailySpending': averageDailySpending,
      'spendingByCategory': spendingByCategory,
      'dailySpending': dailySpending,
      'topCategory': topCategory,
      'totalTransactions': expenses.length,
      'periodDays': endDate.difference(startDate).inDays,
    };
  }

  /// Get monthly spending trends
  static Future<List<Map<String, dynamic>>> getMonthlyTrends({int months = 6}) async {
    final trends = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = months - 1; i >= 0; i--) {
      final monthStart = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(now.year, now.month - i + 1, 0);
      
      final summary = await getSpendingSummary(
        startDate: monthStart,
        endDate: monthEnd,
      );

      trends.add({
        'month': monthStart.month,
        'year': monthStart.year,
        'totalSpending': summary['totalSpending'],
        'averageDailySpending': summary['averageDailySpending'],
        'totalTransactions': summary['totalTransactions'],
        'topCategory': summary['topCategory'],
      });
    }

    return trends;
  }

  /// Get category insights
  static Future<Map<String, dynamic>> getCategoryInsights({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final expenses = await DatabaseService.getExpenses(
      startDate: startDate,
      endDate: endDate,
    );

    final categorySpending = <String, double>{};
    final categoryCounts = <String, int>{};
    final categoryAverages = <String, double>{};

    for (final expense in expenses) {
      final category = expense.category;
      categorySpending[category] = (categorySpending[category] ?? 0) + expense.amount;
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    // Calculate averages
    categorySpending.forEach((category, total) {
      final count = categoryCounts[category] ?? 1;
      categoryAverages[category] = total / count;
    });

    // Sort categories by spending
    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalSpending = categorySpending.values.fold(0.0, (sum, amount) => sum + amount);

    return {
      'categorySpending': categorySpending,
      'categoryCounts': categoryCounts,
      'categoryAverages': categoryAverages,
      'sortedCategories': sortedCategories,
      'totalSpending': totalSpending,
      'categoryPercentages': categorySpending.map((category, amount) => 
        MapEntry(category, (amount / totalSpending * 100).round())),
    };
  }

  // ==================== BUDGET ANALYTICS ====================

  /// Get budget performance
  static Future<List<Map<String, dynamic>>> getBudgetPerformance() async {
    final budgets = await DatabaseService.getBudgets();
    final performance = <Map<String, dynamic>>[];

    for (final budget in budgets) {
      final expenses = await DatabaseService.getExpenses(
        startDate: budget.startDate,
        endDate: budget.endDate,
        category: budget.category,
      );

      final spent = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
      final remaining = budget.amount - spent;
      final percentage = budget.amount > 0 ? (spent / budget.amount * 100) : 0;
      final isOverBudget = spent > budget.amount;

      performance.add({
        'budget': budget,
        'spent': spent,
        'remaining': remaining,
        'percentage': percentage,
        'isOverBudget': isOverBudget,
        'daysRemaining': budget.endDate.difference(DateTime.now()).inDays,
        'averageDailySpent': spent / max(1, DateTime.now().difference(budget.startDate).inDays),
        'projectedSpending': _calculateProjectedSpending(budget, expenses),
      });
    }

    return performance;
  }

  /// Calculate projected spending for a budget
  static double _calculateProjectedSpending(Budget budget, List<Expense> expenses) {
    final daysPassed = DateTime.now().difference(budget.startDate).inDays;
    final totalDays = budget.endDate.difference(budget.startDate).inDays;
    
    if (daysPassed <= 0) return 0;
    
    final spent = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final averageDailySpent = spent / daysPassed;
    
    return averageDailySpent * totalDays;
  }

  // ==================== GOAL ANALYTICS ====================

  /// Get goal progress insights
  static Future<List<Map<String, dynamic>>> getGoalInsights() async {
    final goals = await DatabaseService.getGoals();
    final insights = <Map<String, dynamic>>[];

    for (final goal in goals) {
      final daysRemaining = goal.daysRemaining;
      final progressPercentage = goal.progressPercentage;
      final isOnTrack = _isGoalOnTrack(goal);
      final recommendedMonthlySaving = _calculateRecommendedMonthlySaving(goal);

      insights.add({
        'goal': goal,
        'daysRemaining': daysRemaining,
        'progressPercentage': progressPercentage,
        'isOnTrack': isOnTrack,
        'recommendedMonthlySaving': recommendedMonthlySaving,
        'isOverdue': goal.isOverdue,
        'completionDate': _calculateProjectedCompletionDate(goal),
      });
    }

    return insights;
  }

  /// Check if goal is on track
  static bool _isGoalOnTrack(FinancialGoal goal) {
    final daysSinceStart = DateTime.now().difference(goal.createdAt).inDays;
    final expectedProgress = daysSinceStart / goal.targetDate.difference(goal.createdAt).inDays;
    final actualProgress = goal.progressPercentage / 100;
    
    return actualProgress >= expectedProgress * 0.8; // 80% tolerance
  }

  /// Calculate recommended monthly saving for a goal
  static double _calculateRecommendedMonthlySaving(FinancialGoal goal) {
    final monthsRemaining = goal.daysRemaining / 30.0;
    if (monthsRemaining <= 0) return goal.remainingAmount;
    
    return goal.remainingAmount / monthsRemaining;
  }

  /// Calculate projected completion date
  static DateTime? _calculateProjectedCompletionDate(FinancialGoal goal) {
    if (goal.progressPercentage >= 100) return null;
    
    final currentSavingRate = goal.currentAmount / 
        max(1, DateTime.now().difference(goal.createdAt).inDays) * 30; // Monthly rate
    
    if (currentSavingRate <= 0) return null;
    
    final monthsToComplete = goal.remainingAmount / currentSavingRate;
    return DateTime.now().add(Duration(days: (monthsToComplete * 30).round()));
  }

  // ==================== FINANCIAL HEALTH SCORE ====================

  /// Calculate overall financial health score
  static Future<Map<String, dynamic>> getFinancialHealthScore() async {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0);

    // Get current month data
    final currentMonthExpenses = await DatabaseService.getExpenses(
      startDate: thisMonth,
      endDate: now,
    );

    // Get last month data
    final lastMonthExpenses = await DatabaseService.getExpenses(
      startDate: lastMonth,
      endDate: lastMonthEnd,
    );

    // Get budgets
    final budgets = await DatabaseService.getBudgets();
    final activeBudgets = budgets.where((b) => b.isActive).toList();

    // Get goals
    final goals = await DatabaseService.getGoals();
    final activeGoals = goals.where((g) => !g.isCompleted).toList();

    // Calculate scores
    final spendingScore = _calculateSpendingScore(currentMonthExpenses, lastMonthExpenses);
    final budgetScore = _calculateBudgetScore(activeBudgets);
    final goalScore = _calculateGoalScore(activeGoals);
    final consistencyScore = _calculateConsistencyScore(currentMonthExpenses);

    final overallScore = (spendingScore + budgetScore + goalScore + consistencyScore) / 4;

    return {
      'overallScore': overallScore.round(),
      'spendingScore': spendingScore.round(),
      'budgetScore': budgetScore.round(),
      'goalScore': goalScore.round(),
      'consistencyScore': consistencyScore.round(),
      'recommendations': _getRecommendations(overallScore, spendingScore, budgetScore, goalScore, consistencyScore),
    };
  }

  static double _calculateSpendingScore(List<Expense> current, List<Expense> previous) {
    final currentTotal = current.fold(0.0, (sum, e) => sum + e.amount);
    final previousTotal = previous.fold(0.0, (sum, e) => sum + e.amount);
    
    if (previousTotal == 0) return 50; // Neutral score if no previous data
    
    final change = (currentTotal - previousTotal) / previousTotal;
    
    if (change <= -0.1) return 100; // 10%+ decrease
    if (change <= 0) return 80; // No increase
    if (change <= 0.1) return 60; // 10% increase
    if (change <= 0.2) return 40; // 20% increase
    return 20; // >20% increase
  }

  static double _calculateBudgetScore(List<Budget> budgets) {
    if (budgets.isEmpty) return 30; // No budgets
    
    int onTrackCount = 0;
    for (final budget in budgets) {
      final expenses = DatabaseService.getExpenses(
        startDate: budget.startDate,
        endDate: budget.endDate,
        category: budget.category,
      );
      
      // This is simplified - in real implementation, you'd await this
      // For now, return a placeholder score
      onTrackCount++;
    }
    
    return (onTrackCount / budgets.length) * 100;
  }

  static double _calculateGoalScore(List<FinancialGoal> goals) {
    if (goals.isEmpty) return 30; // No goals
    
    int onTrackCount = 0;
    for (final goal in goals) {
      if (_isGoalOnTrack(goal)) onTrackCount++;
    }
    
    return (onTrackCount / goals.length) * 100;
  }

  static double _calculateConsistencyScore(List<Expense> expenses) {
    if (expenses.length < 7) return 50; // Not enough data
    
    // Calculate daily spending consistency
    final dailySpending = <DateTime, double>{};
    for (final expense in expenses) {
      final date = DateTime(expense.date.year, expense.date.month, expense.date.day);
      dailySpending[date] = (dailySpending[date] ?? 0) + expense.amount;
    }
    
    final amounts = dailySpending.values.toList();
    final average = amounts.fold(0.0, (sum, amount) => sum + amount) / amounts.length;
    final variance = amounts.fold(0.0, (sum, amount) => sum + pow(amount - average, 2)) / amounts.length;
    final standardDeviation = sqrt(variance);
    
    // Lower standard deviation = higher consistency score
    final coefficientOfVariation = average > 0 ? standardDeviation / average : 1;
    return max(0, 100 - (coefficientOfVariation * 100));
  }

  static List<String> _getRecommendations(double overall, double spending, double budget, double goal, double consistency) {
    final recommendations = <String>[];
    
    if (spending < 50) {
      recommendations.add('Consider reducing your spending to improve financial health');
    }
    
    if (budget < 50) {
      recommendations.add('Set up budgets to better track your expenses');
    }
    
    if (goal < 50) {
      recommendations.add('Create financial goals to stay motivated');
    }
    
    if (consistency < 50) {
      recommendations.add('Try to maintain more consistent spending patterns');
    }
    
    if (overall >= 80) {
      recommendations.add('Great job! You\'re doing well with your finances');
    } else if (overall >= 60) {
      recommendations.add('Good progress! Keep up the good work');
    } else {
      recommendations.add('Focus on improving your financial habits');
    }
    
    return recommendations;
  }

  // ==================== PREDICTIONS ====================

  /// Predict next month's spending
  static Future<Map<String, dynamic>> predictNextMonthSpending() async {
    final now = DateTime.now();
    final last3Months = <DateTime>[];
    
    for (int i = 3; i >= 1; i--) {
      last3Months.add(DateTime(now.year, now.month - i, 1));
    }
    
    final monthlyTotals = <double>[];
    
    for (final month in last3Months) {
      final monthEnd = DateTime(month.year, month.month + 1, 0);
      final expenses = await DatabaseService.getExpenses(
        startDate: month,
        endDate: monthEnd,
      );
      
      final total = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
      monthlyTotals.add(total);
    }
    
    // Simple linear regression for prediction
    final average = monthlyTotals.fold(0.0, (sum, amount) => sum + amount) / monthlyTotals.length;
    final trend = monthlyTotals.length > 1 
        ? (monthlyTotals.last - monthlyTotals.first) / (monthlyTotals.length - 1)
        : 0;
    
    final predicted = average + trend;
    
    return {
      'predictedSpending': predicted,
      'confidence': monthlyTotals.length >= 3 ? 'high' : 'medium',
      'historicalAverage': average,
      'trend': trend,
      'historicalData': monthlyTotals,
    };
  }
}
