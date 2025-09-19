import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum NotificationType {
  budgetAlert,
  goalReminder,
  spendingAlert,
  achievement,
  tip,
  deadline,
  overdue,
  milestone,
}

enum NotificationPriority {
  low,
  medium,
  high,
  critical,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final bool isRead;
  final bool isDismissed;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.createdAt,
    this.scheduledFor,
    this.isRead = false,
    this.isDismissed = false,
    this.data,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'type': type.name,
    'priority': priority.name,
    'createdAt': createdAt.toIso8601String(),
    'scheduledFor': scheduledFor?.toIso8601String(),
    'isRead': isRead,
    'isDismissed': isDismissed,
    'data': data,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'],
    title: json['title'],
    message: json['message'],
    type: NotificationType.values.firstWhere((e) => e.name == json['type']),
    priority: NotificationPriority.values.firstWhere((e) => e.name == json['priority']),
    createdAt: DateTime.parse(json['createdAt']),
    scheduledFor: json['scheduledFor'] != null ? DateTime.parse(json['scheduledFor']) : null,
    isRead: json['isRead'] ?? false,
    isDismissed: json['isDismissed'] ?? false,
    data: json['data'],
  );

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    DateTime? createdAt,
    DateTime? scheduledFor,
    bool? isRead,
    bool? isDismissed,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      isRead: isRead ?? this.isRead,
      isDismissed: isDismissed ?? this.isDismissed,
      data: data ?? this.data,
    );
  }
}

class NotificationService {
  static const String _notificationsKey = 'app_notifications';
  static const String _notificationSettingsKey = 'notification_settings';
  
  // Singleton instance
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Notification settings
  bool _budgetAlertsEnabled = true;
  bool _goalRemindersEnabled = true;
  bool _spendingAlertsEnabled = true;
  bool _achievementNotificationsEnabled = true;
  bool _tipNotificationsEnabled = true;

  // Getters for settings
  bool get budgetAlertsEnabled => _budgetAlertsEnabled;
  bool get goalRemindersEnabled => _goalRemindersEnabled;
  bool get spendingAlertsEnabled => _spendingAlertsEnabled;
  bool get achievementNotificationsEnabled => _achievementNotificationsEnabled;
  bool get tipNotificationsEnabled => _tipNotificationsEnabled;

  Future<void> initialize() async {
    await _loadSettings();
    await _checkScheduledNotifications();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _budgetAlertsEnabled = prefs.getBool('budget_alerts_enabled') ?? true;
    _goalRemindersEnabled = prefs.getBool('goal_reminders_enabled') ?? true;
    _spendingAlertsEnabled = prefs.getBool('spending_alerts_enabled') ?? true;
    _achievementNotificationsEnabled = prefs.getBool('achievement_notifications_enabled') ?? true;
    _tipNotificationsEnabled = prefs.getBool('tip_notifications_enabled') ?? true;
  }

  Future<void> updateSettings({
    bool? budgetAlerts,
    bool? goalReminders,
    bool? spendingAlerts,
    bool? achievements,
    bool? tips,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (budgetAlerts != null) {
      _budgetAlertsEnabled = budgetAlerts;
      await prefs.setBool('budget_alerts_enabled', budgetAlerts);
    }
    
    if (goalReminders != null) {
      _goalRemindersEnabled = goalReminders;
      await prefs.setBool('goal_reminders_enabled', goalReminders);
    }
    
    if (spendingAlerts != null) {
      _spendingAlertsEnabled = spendingAlerts;
      await prefs.setBool('spending_alerts_enabled', spendingAlerts);
    }
    
    if (achievements != null) {
      _achievementNotificationsEnabled = achievements;
      await prefs.setBool('achievement_notifications_enabled', achievements);
    }
    
    if (tips != null) {
      _tipNotificationsEnabled = tips;
      await prefs.setBool('tip_notifications_enabled', tips);
    }
  }

  Future<List<AppNotification>> getAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsString = prefs.getStringList(_notificationsKey) ?? [];
    
    return notificationsString
        .map((jsonString) => AppNotification.fromJson(jsonDecode(jsonString)))
        .toList();
  }

  Future<List<AppNotification>> getUnreadNotifications() async {
    final allNotifications = await getAllNotifications();
    return allNotifications.where((notification) => !notification.isRead && !notification.isDismissed).toList();
  }

  Future<List<AppNotification>> getNotificationsByType(NotificationType type) async {
    final allNotifications = await getAllNotifications();
    return allNotifications.where((notification) => notification.type == type).toList();
  }

  Future<void> addNotification(AppNotification notification) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getAllNotifications();
    
    notifications.insert(0, notification); // Add to beginning
    
    // Keep only last 100 notifications
    if (notifications.length > 100) {
      notifications.removeRange(100, notifications.length);
    }
    
    final notificationsString = notifications.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList(_notificationsKey, notificationsString);
  }

  Future<void> markAsRead(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getAllNotifications();
    
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      
      final notificationsString = notifications.map((n) => jsonEncode(n.toJson())).toList();
      await prefs.setStringList(_notificationsKey, notificationsString);
    }
  }

  Future<void> markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getAllNotifications();
    
    for (int i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }
    
    final notificationsString = notifications.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList(_notificationsKey, notificationsString);
  }

  Future<void> dismissNotification(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getAllNotifications();
    
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isDismissed: true);
      
      final notificationsString = notifications.map((n) => jsonEncode(n.toJson())).toList();
      await prefs.setStringList(_notificationsKey, notificationsString);
    }
  }

  Future<void> clearAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsKey);
  }

  Future<void> _checkScheduledNotifications() async {
    final notifications = await getAllNotifications();
    final now = DateTime.now();
    
    for (final notification in notifications) {
      if (notification.scheduledFor != null && 
          notification.scheduledFor!.isBefore(now) && 
          !notification.isDismissed) {
        // Notification is due, trigger it
        await _triggerNotification(notification);
      }
    }
  }

  Future<void> _triggerNotification(AppNotification notification) async {
    // In a real app, this would trigger actual push notifications
    // For now, we'll just ensure it's marked as active
    await addNotification(notification.copyWith(scheduledFor: null));
  }

  // Budget-related notifications
  Future<void> checkBudgetAlerts() async {
    if (!_budgetAlertsEnabled) return;

    final prefs = await SharedPreferences.getInstance();
    final budgetsString = prefs.getStringList('user_budgets') ?? [];
    final expensesString = prefs.getStringList('user_expenses') ?? [];
    
    if (budgetsString.isEmpty || expensesString.isEmpty) return;

    final budgets = budgetsString.map((e) => jsonDecode(e)).toList();
    final expenses = expensesString.map((e) => jsonDecode(e)).toList();
    
    final currentMonth = DateTime.now();
    final monthlyExpenses = expenses.where((expense) {
      final expenseDate = DateTime.parse(expense['date']);
      return expenseDate.year == currentMonth.year && expenseDate.month == currentMonth.month;
    }).toList();

    for (final budget in budgets) {
      if (budget['period'] == 'Monthly') {
        final category = budget['category'];
        final budgetAmount = budget['amount'];
        final spentAmount = monthlyExpenses
            .where((expense) => expense['category'] == category)
            .fold(0.0, (sum, expense) => sum + (expense['amount'] ?? 0.0));
        
        final percentage = budgetAmount > 0 ? (spentAmount / budgetAmount) * 100 : 0.0;
        
        if (percentage >= 100) {
          await _createBudgetAlert(
            'Budget Exceeded!',
            'You\'ve exceeded your $category budget by Ksh ${(spentAmount - budgetAmount).toStringAsFixed(0)}!',
            NotificationPriority.high,
            {'category': category, 'budgetAmount': budgetAmount, 'spentAmount': spentAmount},
          );
        } else if (percentage >= 80) {
          await _createBudgetAlert(
            'Budget Warning',
            'You\'ve used ${percentage.toStringAsFixed(0)}% of your $category budget. Only Ksh ${(budgetAmount - spentAmount).toStringAsFixed(0)} remaining!',
            NotificationPriority.medium,
            {'category': category, 'budgetAmount': budgetAmount, 'spentAmount': spentAmount, 'percentage': percentage},
          );
        }
      }
    }
  }

  Future<void> _createBudgetAlert(String title, String message, NotificationPriority priority, Map<String, dynamic> data) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: NotificationType.budgetAlert,
      priority: priority,
      createdAt: DateTime.now(),
      data: data,
    );
    
    await addNotification(notification);
  }

  // Goal-related notifications
  Future<void> checkGoalReminders() async {
    if (!_goalRemindersEnabled) return;

    final prefs = await SharedPreferences.getInstance();
    final goalsString = prefs.getStringList('user_goals') ?? [];
    
    if (goalsString.isEmpty) return;

    final goals = goalsString.map((e) => jsonDecode(e)).toList();
    final now = DateTime.now();
    
    for (final goal in goals) {
      if (goal['isCompleted']) continue;
      
      final targetDate = DateTime.parse(goal['targetDate']);
      final daysRemaining = targetDate.difference(now).inDays;
      final targetAmount = goal['targetAmount'];
      final currentAmount = goal['currentAmount'];
      final progress = targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0.0;
      
      if (daysRemaining < 0) {
        // Overdue goal
        await _createGoalReminder(
          'Goal Overdue!',
          '${goal['title']} is ${daysRemaining.abs()} days overdue. Time to reassess!',
          NotificationPriority.critical,
          {'goalId': goal['id'], 'daysOverdue': daysRemaining.abs(), 'goalTitle': goal['title']},
        );
      } else if (daysRemaining <= 7 && daysRemaining > 0) {
        // Deadline approaching
        await _createGoalReminder(
          'Deadline Approaching!',
          '${goal['title']} deadline is in $daysRemaining days. You\'re ${progress.toStringAsFixed(0)}% complete!',
          NotificationPriority.high,
          {'goalId': goal['id'], 'daysRemaining': daysRemaining, 'progress': progress, 'goalTitle': goal['title']},
        );
      } else if (progress >= 90 && progress < 100) {
        // Near completion
        await _createGoalReminder(
          'Almost There!',
          '${goal['title']} is ${progress.toStringAsFixed(0)}% complete! Just Ksh ${(targetAmount - currentAmount).toStringAsFixed(0)} to go!',
          NotificationPriority.medium,
          {'goalId': goal['id'], 'progress': progress, 'remaining': targetAmount - currentAmount, 'goalTitle': goal['title']},
        );
      }
    }
  }

  Future<void> _createGoalReminder(String title, String message, NotificationPriority priority, Map<String, dynamic> data) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: NotificationType.goalReminder,
      priority: priority,
      createdAt: DateTime.now(),
      data: data,
    );
    
    await addNotification(notification);
  }

  // Spending-related notifications
  Future<void> checkSpendingAlerts() async {
    if (!_spendingAlertsEnabled) return;

    final prefs = await SharedPreferences.getInstance();
    final expensesString = prefs.getStringList('user_expenses') ?? [];
    final incomesString = prefs.getStringList('user_incomes') ?? [];
    
    if (expensesString.isEmpty || incomesString.isEmpty) return;

    final expenses = expensesString.map((e) => jsonDecode(e)).toList();
    final incomes = incomesString.map((e) => jsonDecode(e)).toList();
    
    final currentMonth = DateTime.now();
    final monthlyExpenses = expenses.where((expense) {
      final expenseDate = DateTime.parse(expense['date']);
      return expenseDate.year == currentMonth.year && expenseDate.month == currentMonth.month;
    }).toList();
    
    final monthlyIncomes = incomes.where((income) {
      final incomeDate = DateTime.parse(income['date']);
      return incomeDate.year == currentMonth.year && incomeDate.month == currentMonth.month;
    }).toList();

    final totalExpenses = monthlyExpenses.fold(0.0, (sum, expense) => sum + (expense['amount'] ?? 0.0));
    final totalIncome = monthlyIncomes.fold(0.0, (sum, income) => sum + (income['amount'] ?? 0.0));
    
    if (totalIncome > 0) {
      final spendingRatio = totalExpenses / totalIncome;
      
      if (spendingRatio > 1.0) {
        await _createSpendingAlert(
          'Overspending Alert!',
          'You\'re spending ${(spendingRatio * 100).toStringAsFixed(0)}% of your income! Consider reducing expenses.',
          NotificationPriority.critical,
          {'spendingRatio': spendingRatio, 'totalExpenses': totalExpenses, 'totalIncome': totalIncome},
        );
      } else if (spendingRatio > 0.8) {
        await _createSpendingAlert(
          'High Spending Warning',
          'You\'re spending ${(spendingRatio * 100).toStringAsFixed(0)}% of your income. Try to save more!',
          NotificationPriority.medium,
          {'spendingRatio': spendingRatio, 'totalExpenses': totalExpenses, 'totalIncome': totalIncome},
        );
      }
    }
  }

  Future<void> _createSpendingAlert(String title, String message, NotificationPriority priority, Map<String, dynamic> data) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: NotificationType.spendingAlert,
      priority: priority,
      createdAt: DateTime.now(),
      data: data,
    );
    
    await addNotification(notification);
  }

  // Achievement notifications
  Future<void> checkAchievements() async {
    if (!_achievementNotificationsEnabled) return;

    final prefs = await SharedPreferences.getInstance();
    final goalsString = prefs.getStringList('user_goals') ?? [];
    final expensesString = prefs.getStringList('user_expenses') ?? [];
    final incomesString = prefs.getStringList('user_incomes') ?? [];
    
    // Check for completed goals
    final goals = goalsString.map((e) => jsonDecode(e)).toList();
    for (final goal in goals) {
      if (goal['isCompleted']) {
        // Check if we already notified about this achievement
        final notifications = await getAllNotifications();
        final alreadyNotified = notifications.any((n) => 
          n.type == NotificationType.achievement && 
          n.data?['goalId'] == goal['id']);
        
        if (!alreadyNotified) {
          await _createAchievementNotification(
            'Goal Achieved! 🎉',
            'Congratulations! You\'ve completed your goal: ${goal['title']}!',
            NotificationPriority.medium,
            {'goalId': goal['id'], 'goalTitle': goal['title'], 'achievementType': 'goal_completion'},
          );
        }
      }
    }
  }

  Future<void> _createAchievementNotification(String title, String message, NotificationPriority priority, Map<String, dynamic> data) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: NotificationType.achievement,
      priority: priority,
      createdAt: DateTime.now(),
      data: data,
    );
    
    await addNotification(notification);
  }

  // Tip notifications
  Future<void> sendDailyTip() async {
    if (!_tipNotificationsEnabled) return;

    final tips = [
      "💡 Tip: Track every expense, no matter how small. Small purchases add up quickly!",
      "💰 Tip: Set up automatic transfers to your savings account on payday.",
      "📊 Tip: Review your budget weekly to stay on track with your financial goals.",
      "🎯 Tip: Focus on one financial goal at a time for better results.",
      "🛡️ Tip: Build an emergency fund equal to 3-6 months of expenses.",
      "📈 Tip: Invest in yourself - education and skills are the best investments.",
      "💳 Tip: Pay off high-interest debt first to save money on interest.",
      "🏠 Tip: Consider the 50/30/20 rule: 50% needs, 30% wants, 20% savings.",
      "⏰ Tip: Start investing early - compound interest is your best friend.",
      "🎉 Tip: Celebrate small financial wins to stay motivated!",
    ];

    final randomTip = tips[DateTime.now().day % tips.length];
    
    await _createTipNotification(
      'Daily Financial Tip',
      randomTip,
      NotificationPriority.low,
      {'tipType': 'daily', 'tipIndex': DateTime.now().day % tips.length},
    );
  }

  Future<void> _createTipNotification(String title, String message, NotificationPriority priority, Map<String, dynamic> data) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: NotificationType.tip,
      priority: priority,
      createdAt: DateTime.now(),
      data: data,
    );
    
    await addNotification(notification);
  }

  // Run all checks
  Future<void> runAllChecks() async {
    await checkBudgetAlerts();
    await checkGoalReminders();
    await checkSpendingAlerts();
    await checkAchievements();
    
    // Send daily tip only once per day
    final lastTipDate = await _getLastTipDate();
    final today = DateTime.now();
    if (lastTipDate == null || 
        lastTipDate.year != today.year || 
        lastTipDate.month != today.month || 
        lastTipDate.day != today.day) {
      await sendDailyTip();
      await _setLastTipDate(today);
    }
  }

  Future<DateTime?> _getLastTipDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString('last_tip_date');
    return dateString != null ? DateTime.parse(dateString) : null;
  }

  Future<void> _setLastTipDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_tip_date', date.toIso8601String());
  }

  // Get notification count
  Future<int> getUnreadCount() async {
    final unreadNotifications = await getUnreadNotifications();
    return unreadNotifications.length;
  }

  // Get notifications by priority
  Future<List<AppNotification>> getNotificationsByPriority(NotificationPriority priority) async {
    final allNotifications = await getAllNotifications();
    return allNotifications.where((notification) => notification.priority == priority).toList();
  }

  // Get critical notifications
  Future<List<AppNotification>> getCriticalNotifications() async {
    return await getNotificationsByPriority(NotificationPriority.critical);
  }

  // Get high priority notifications
  Future<List<AppNotification>> getHighPriorityNotifications() async {
    return await getNotificationsByPriority(NotificationPriority.high);
  }
}
