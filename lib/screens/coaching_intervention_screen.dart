import 'package:flutter/material.dart';
import '../services/coaching_intervention_service.dart';

class CoachingInterventionScreen extends StatefulWidget {
  const CoachingInterventionScreen({super.key});

  @override
  State<CoachingInterventionScreen> createState() => _CoachingInterventionScreenState();
}

class _CoachingInterventionScreenState extends State<CoachingInterventionScreen> {
  List<CoachingIntervention> _interventions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInterventions();
  }

  Future<void> _loadInterventions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final interventions = await CoachingInterventionService.getInterventions();
      setState(() {
        _interventions = interventions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading interventions: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      appBar: AppBar(
        title: const Text('Mali\'s Coaching'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF181114),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInterventions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _interventions.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _interventions.length,
                  itemBuilder: (context, index) {
                    final intervention = _interventions[index];
                    return _buildInterventionCard(intervention);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFEE2B8D).withOpacity(0.1),
                  const Color(0xFFEE2B8D).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.psychology,
              size: 60,
              color: Color(0xFFEE2B8D),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No coaching messages yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF181114),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mali will send you personalized coaching messages based on your financial behavior',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInterventionCard(CoachingIntervention intervention) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Mali avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEE2B8D), Color(0xFFEE2B8D)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Title and priority
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          intervention.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getInterventionColor(intervention.type),
                          ),
                        ),
                        Text(
                          _getInterventionTypeText(intervention.type),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Priority indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(intervention.priority).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Priority ${intervention.priority}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getPriorityColor(intervention.priority),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Message
              Text(
                intervention.message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF181114),
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Actions
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: intervention.actions.map((action) => 
                  _buildActionButton(action, intervention)
                ).toList(),
              ),
              
              const SizedBox(height: 12),
              
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDateTime(intervention.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  Row(
                    children: [
                      if (!intervention.isRead)
                        TextButton(
                          onPressed: () => _markAsRead(intervention.id),
                          child: const Text(
                            'Mark as Read',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      TextButton(
                        onPressed: () => _dismissIntervention(intervention.id),
                        child: const Text(
                          'Dismiss',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String action, CoachingIntervention intervention) {
    return ElevatedButton(
      onPressed: () => _handleAction(action, intervention),
      style: ElevatedButton.styleFrom(
        backgroundColor: _getInterventionColor(intervention.type).withOpacity(0.1),
        foregroundColor: _getInterventionColor(intervention.type),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: _getInterventionColor(intervention.type).withOpacity(0.3),
          ),
        ),
      ),
      child: Text(
        action,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  void _handleAction(String action, CoachingIntervention intervention) {
    // Handle different actions based on the intervention type
    switch (action.toLowerCase()) {
      case 'wait 24 hours':
      case 'delay purchase':
        _showConfirmationDialog(
          'Purchase Delayed',
          'I\'ll remind you about this purchase in 24 hours. Take time to think it over!',
        );
        break;
        
      case 'add to wishlist':
        _showConfirmationDialog(
          'Added to Wishlist',
          'Great idea! I\'ll help you track this item in your wishlist.',
        );
        break;
        
      case 'set a spending limit':
        _showSpendingLimitDialog();
        break;
        
      case 'check budget':
        Navigator.pushNamed(context, '/budget');
        break;
        
      case 'review goals':
        Navigator.pushNamed(context, '/goals');
        break;
        
      case 'talk to mali':
        Navigator.pushNamed(context, '/chat');
        break;
        
      case 'celebrate':
        _showCelebrationDialog();
        break;
        
      default:
        _showConfirmationDialog(
          'Action Taken',
          'Thanks for taking action! I\'ll continue to support your financial journey.',
        );
    }
    
    // Mark as read after action
    _markAsRead(intervention.id);
  }

  void _showConfirmationDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSpendingLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Spending Limit'),
        content: const Text('What\'s a reasonable spending limit for you today?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showConfirmationDialog(
                'Limit Set',
                'I\'ll help you stay within your spending limit today!',
              );
            },
            child: const Text('Set Limit'),
          ),
        ],
      ),
    );
  }

  void _showCelebrationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Celebration Time!'),
        content: const Text('You\'re doing amazing! Keep up the great work on your financial journey!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Thanks Mali!'),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsRead(String interventionId) async {
    try {
      await CoachingInterventionService.markAsRead(interventionId);
      await _loadInterventions();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error marking as read: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _dismissIntervention(String interventionId) async {
    try {
      await CoachingInterventionService.dismissIntervention(interventionId);
      await _loadInterventions();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error dismissing intervention: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getInterventionColor(InterventionType type) {
    switch (type) {
      case InterventionType.gentle:
        return Colors.blue;
      case InterventionType.warning:
        return Colors.orange;
      case InterventionType.urgent:
        return Colors.red;
      case InterventionType.celebration:
        return Colors.green;
      case InterventionType.educational:
        return Colors.purple;
      case InterventionType.motivational:
        return const Color(0xFFEE2B8D);
    }
  }

  String _getInterventionTypeText(InterventionType type) {
    switch (type) {
      case InterventionType.gentle:
        return 'Gentle reminder';
      case InterventionType.warning:
        return 'Important notice';
      case InterventionType.urgent:
        return 'Urgent alert';
      case InterventionType.celebration:
        return 'Celebration';
      case InterventionType.educational:
        return 'Learning moment';
      case InterventionType.motivational:
        return 'Motivation';
    }
  }

  Color _getPriorityColor(int priority) {
    if (priority >= 8) return Colors.red;
    if (priority >= 6) return Colors.orange;
    if (priority >= 4) return Colors.yellow[700]!;
    return Colors.green;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

