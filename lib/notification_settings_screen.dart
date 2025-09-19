import 'package:flutter/material.dart';
import 'notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  
  bool _budgetAlertsEnabled = true;
  bool _goalRemindersEnabled = true;
  bool _spendingAlertsEnabled = true;
  bool _achievementNotificationsEnabled = true;
  bool _tipNotificationsEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    await _notificationService.initialize();
    
    setState(() {
      _budgetAlertsEnabled = _notificationService.budgetAlertsEnabled;
      _goalRemindersEnabled = _notificationService.goalRemindersEnabled;
      _spendingAlertsEnabled = _notificationService.spendingAlertsEnabled;
      _achievementNotificationsEnabled = _notificationService.achievementNotificationsEnabled;
      _tipNotificationsEnabled = _notificationService.tipNotificationsEnabled;
      _isLoading = false;
    });
  }

  Future<void> _updateSetting(String setting, bool value) async {
    switch (setting) {
      case 'budget':
        setState(() => _budgetAlertsEnabled = value);
        await _notificationService.updateSettings(budgetAlerts: value);
        break;
      case 'goals':
        setState(() => _goalRemindersEnabled = value);
        await _notificationService.updateSettings(goalReminders: value);
        break;
      case 'spending':
        setState(() => _spendingAlertsEnabled = value);
        await _notificationService.updateSettings(spendingAlerts: value);
        break;
      case 'achievements':
        setState(() => _achievementNotificationsEnabled = value);
        await _notificationService.updateSettings(achievements: value);
        break;
      case 'tips':
        setState(() => _tipNotificationsEnabled = value);
        await _notificationService.updateSettings(tips: value);
        break;
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
          'Notification Settings',
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
                  // Header
                  const Text(
                    'Manage Your Notifications',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose which notifications you want to receive to stay on top of your finances.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Budget Alerts
                  _buildNotificationSetting(
                    'Budget Alerts',
                    'Get notified when you\'re approaching or exceeding your budget limits.',
                    Icons.account_balance_wallet,
                    Colors.blue,
                    _budgetAlertsEnabled,
                    (value) => _updateSetting('budget', value),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Goal Reminders
                  _buildNotificationSetting(
                    'Goal Reminders',
                    'Receive reminders about goal deadlines and progress updates.',
                    Icons.emoji_events,
                    Colors.purple,
                    _goalRemindersEnabled,
                    (value) => _updateSetting('goals', value),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Spending Alerts
                  _buildNotificationSetting(
                    'Spending Alerts',
                    'Get alerts when your spending patterns are unusual or excessive.',
                    Icons.warning,
                    Colors.orange,
                    _spendingAlertsEnabled,
                    (value) => _updateSetting('spending', value),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Achievement Notifications
                  _buildNotificationSetting(
                    'Achievement Notifications',
                    'Celebrate your financial milestones and completed goals.',
                    Icons.celebration,
                    Colors.green,
                    _achievementNotificationsEnabled,
                    (value) => _updateSetting('achievements', value),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Tip Notifications
                  _buildNotificationSetting(
                    'Daily Tips',
                    'Receive helpful financial tips and advice daily.',
                    Icons.lightbulb_outline,
                    Colors.amber,
                    _tipNotificationsEnabled,
                    (value) => _updateSetting('tips', value),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Test Notifications Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _testNotifications(),
                      icon: const Icon(Icons.notifications_active, color: Colors.white),
                      label: const Text(
                        'Test Notifications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEE2B8D),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Information Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'About Notifications',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Notifications help you stay on track with your financial goals. They are generated based on your spending patterns, budget performance, and goal progress.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You can always change these settings later in the app.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationSetting(
    String title,
    String description,
    IconData icon,
    Color color,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFEE2B8D),
            activeTrackColor: const Color(0xFFEE2B8D).withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  void _testNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Notifications'),
        content: const Text('This will create sample notifications to show you how they look. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _createTestNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Test notifications created! Check your notification center.'),
                  backgroundColor: Color(0xFFEE2B8D),
                ),
              );
            },
            child: const Text('Create Test'),
          ),
        ],
      ),
    );
  }

  Future<void> _createTestNotifications() async {
    // Create sample notifications for testing
    final testNotifications = [
      AppNotification(
        id: 'test_budget_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Budget Alert',
        message: 'You\'ve used 85% of your Food & Dining budget this month.',
        type: NotificationType.budgetAlert,
        priority: NotificationPriority.medium,
        createdAt: DateTime.now(),
        data: {'category': 'Food & Dining', 'percentage': 85},
      ),
      AppNotification(
        id: 'test_goal_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Goal Reminder',
        message: 'Your Emergency Fund goal deadline is in 5 days!',
        type: NotificationType.goalReminder,
        priority: NotificationPriority.high,
        createdAt: DateTime.now(),
        data: {'goalTitle': 'Emergency Fund', 'daysRemaining': 5},
      ),
      AppNotification(
        id: 'test_achievement_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Achievement Unlocked! 🎉',
        message: 'Congratulations! You\'ve completed your Phone Upgrade goal!',
        type: NotificationType.achievement,
        priority: NotificationPriority.medium,
        createdAt: DateTime.now(),
        data: {'goalTitle': 'Phone Upgrade', 'achievementType': 'goal_completion'},
      ),
      AppNotification(
        id: 'test_tip_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Daily Financial Tip',
        message: '💡 Tip: Track every expense, no matter how small. Small purchases add up quickly!',
        type: NotificationType.tip,
        priority: NotificationPriority.low,
        createdAt: DateTime.now(),
        data: {'tipType': 'daily'},
      ),
    ];

    for (final notification in testNotifications) {
      await _notificationService.addNotification(notification);
    }
  }
}
