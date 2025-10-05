import 'package:flutter/material.dart';
import '../services/sms_service_factory.dart';
import '../models/transaction_model.dart';
import '../widgets/mali_logo.dart';
import '../widgets/transaction_charges_summary.dart';

class SmsInsightsScreen extends StatefulWidget {
  const SmsInsightsScreen({super.key});

  @override
  State<SmsInsightsScreen> createState() => _SmsInsightsScreenState();
}

class _SmsInsightsScreenState extends State<SmsInsightsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  List<Transaction> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get transaction statistics
      final stats = await SmsServiceFactory.getTransactionStats();
      
      // Get recent transactions
      final transactions = await SmsServiceFactory.getStoredTransactions();
      
      // Sort by date (most recent first) and take first 10
      transactions.sort((a, b) => b.date.compareTo(a.date));
      final recentTransactions = transactions.take(10).toList();

      setState(() {
        _stats = stats;
        _recentTransactions = recentTransactions;
      });
    } catch (e) {
      print('Error loading SMS insights: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      appBar: AppBar(
        title: const Text('SMS Insights'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF181114),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),
                  
                  const SizedBox(height: 24),
                  
                  // Statistics cards
                  _buildStatsCards(),
                  
                  const SizedBox(height: 24),
                  
                  // Recent transactions
                  _buildRecentTransactions(),
                  
                  const SizedBox(height: 24),
                  
                  // Transaction charges summary
                  TransactionChargesSummary(
                    transactions: _recentTransactions,
                    period: 'this period',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFEE2B8D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.sms,
              color: Color(0xFFEE2B8D),
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'M-PESA Tracking',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF181114),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_stats['totalTransactions'] ?? 0} transactions tracked',
                  style: const TextStyle(
                    color: Color(0xFF575354),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final totalIncome = _stats['totalIncome'] ?? 0.0;
    final totalExpenses = _stats['totalExpenses'] ?? 0.0;
    final netAmount = _stats['netAmount'] ?? 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Income',
            'Ksh ${totalIncome.toStringAsFixed(0)}',
            Colors.green,
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Expenses',
            'Ksh ${totalExpenses.toStringAsFixed(0)}',
            Colors.red,
            Icons.trending_down,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF575354),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    if (_recentTransactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(
              Icons.receipt_long,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No transactions yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181114),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'M-PESA transactions will appear here once detected',
              style: TextStyle(
                color: Color(0xFF575354),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF181114),
            ),
          ),
          const SizedBox(height: 16),
          ..._recentTransactions.map((transaction) => 
            _buildTransactionItem(transaction)
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? Colors.green : Colors.red;
    final amountPrefix = isIncome ? '+' : '-';
    final hasCharge = transaction.transactionCharge != null && transaction.transactionCharge! > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: amountColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: amountColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF181114),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      transaction.category,
                      style: const TextStyle(
                        color: Color(0xFF575354),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatDate(transaction.date),
                      style: const TextStyle(
                        color: Color(0xFF575354),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$amountPrefix Ksh ${transaction.amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (hasCharge) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Charge: Ksh ${transaction.transactionCharge!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEE2B8D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _clearData,
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear Data'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEE2B8D),
              side: const BorderSide(color: Color(0xFFEE2B8D)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  Future<void> _clearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Transaction Data'),
        content: const Text('Are you sure you want to clear all SMS transaction data? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SmsServiceFactory.clearTransactions();
      await _loadData();
    }
  }
}
