import 'package:flutter/material.dart';
import 'budget_alerts.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<BudgetAlert> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    final alerts = await BudgetAlertManager.getAlerts();
    setState(() {
      _alerts = alerts;
      _isLoading = false;
    });
  }

  Future<void> _refreshAlerts() async {
    setState(() {
      _isLoading = true;
    });
    
    // Check for new alerts
    await BudgetAlertManager.checkForAlerts();
    
    // Reload alerts
    await _loadAlerts();
  }

  Future<void> _markAsRead(BudgetAlert alert) async {
    await BudgetAlertManager.markAsRead(alert.id);
    await _loadAlerts();
  }

  Future<void> _clearAllAlerts() async {
    await BudgetAlertManager.clearAllAlerts();
    await _loadAlerts();
  }

  Color _getAlertColor(String type) {
    switch (type) {
      case 'spending':
        return Colors.red;
      case 'savings':
        return Colors.orange;
      case 'budget':
        return Colors.red;
      case 'goal':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'spending':
        return Icons.trending_down;
      case 'savings':
        return Icons.savings;
      case 'budget':
        return Icons.warning;
      case 'goal':
        return Icons.flag;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alerts & Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAlerts,
          ),
          if (_alerts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Alerts'),
                    content: const Text('Are you sure you want to clear all alerts?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _clearAllAlerts();
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _alerts.isEmpty
              ? _buildEmptyState()
              : _buildAlertsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Alerts Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mali will notify you about important financial events!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshAlerts,
            icon: const Icon(Icons.refresh),
            label: const Text('Check for Alerts'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList() {
    return RefreshIndicator(
      onRefresh: _refreshAlerts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _alerts.length,
        itemBuilder: (context, index) {
          final alert = _alerts[index];
          return _buildAlertCard(alert);
        },
      ),
    );
  }

  Widget _buildAlertCard(BudgetAlert alert) {
    final alertColor = _getAlertColor(alert.type);
    final alertIcon = _getAlertIcon(alert.type);
    final timeAgo = _getTimeAgo(alert.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: alert.isRead ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alert.isRead ? Colors.grey[300]! : alertColor.withOpacity(0.3),
        ),
        boxShadow: alert.isRead ? null : [
          BoxShadow(
            color: alertColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: alertColor.withOpacity(0.1),
          child: Icon(alertIcon, color: alertColor),
        ),
        title: Text(
          alert.title,
          style: TextStyle(
            fontWeight: alert.isRead ? FontWeight.normal : FontWeight.bold,
            color: alert.isRead ? Colors.grey[600] : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              alert.message,
              style: TextStyle(
                fontSize: 14,
                color: alert.isRead ? Colors.grey[500] : Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeAgo,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
        trailing: alert.isRead
            ? null
            : IconButton(
                icon: const Icon(Icons.check, size: 20),
                onPressed: () => _markAsRead(alert),
                color: alertColor,
              ),
        onTap: () {
          if (!alert.isRead) {
            _markAsRead(alert);
          }
        },
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
} 