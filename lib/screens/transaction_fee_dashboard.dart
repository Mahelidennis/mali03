import 'package:flutter/material.dart';
import '../services/transaction_fee_tracking_service.dart';

class TransactionFeeDashboard extends StatefulWidget {
  const TransactionFeeDashboard({super.key});

  @override
  State<TransactionFeeDashboard> createState() => _TransactionFeeDashboardState();
}

class _TransactionFeeDashboardState extends State<TransactionFeeDashboard> {
  FeeAnalytics? _analytics;
  Map<String, dynamic>? _insights;
  bool _isLoading = true;
  String _selectedPeriod = 'month';

  @override
  void initState() {
    super.initState();
    _loadFeeData();
  }

  Future<void> _loadFeeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final analytics = await TransactionFeeTrackingService.calculateFeeAnalytics();
      final insights = await TransactionFeeTrackingService.getFeeInsights();
      
      setState(() {
        _analytics = analytics;
        _insights = insights;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading fee data: $e'),
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
        title: const Text('Transaction Fees'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF181114),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFeeData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _analytics == null
              ? _buildEmptyState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Period Selector
                      _buildPeriodSelector(),
                      
                      const SizedBox(height: 24),
                      
                      // Fee Summary Cards
                      _buildFeeSummaryCards(),
                      
                      const SizedBox(height: 24),
                      
                      // Fee Breakdown
                      _buildFeeBreakdown(),
                      
                      const SizedBox(height: 24),
                      
                      // Payment Method Analysis
                      _buildPaymentMethodAnalysis(),
                      
                      const SizedBox(height: 24),
                      
                      // Insights & Recommendations
                      _buildInsightsSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Recent Fees
                      _buildRecentFees(),
                    ],
                  ),
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
              Icons.account_balance_wallet,
              size: 60,
              color: Color(0xFFEE2B8D),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No transaction fees yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF181114),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start making transactions to see your fee analysis',
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

  Widget _buildPeriodSelector() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFFEE2B8D)),
            const SizedBox(width: 12),
            const Text(
              'Period:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF181114),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  _buildPeriodButton('Today', 'day'),
                  const SizedBox(width: 8),
                  _buildPeriodButton('Week', 'week'),
                  const SizedBox(width: 8),
                  _buildPeriodButton('Month', 'month'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = _selectedPeriod == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = value;
        });
        _loadFeeData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEE2B8D) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildFeeSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Fees',
            'Ksh ${_analytics!.totalFees.toStringAsFixed(0)}',
            Icons.account_balance_wallet,
            const Color(0xFFEE2B8D),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Transactions',
            '${_analytics!.totalTransactions.toStringAsFixed(0)}',
            Icons.swap_horiz,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Avg Fee %',
            '${_analytics!.averageFeePercentage.toStringAsFixed(1)}%',
            Icons.trending_up,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeBreakdown() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fee Breakdown by Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181114),
              ),
            ),
            const SizedBox(height: 16),
            ..._analytics!.feesByType.entries.map((entry) => 
              _buildFeeTypeItem(entry.key, entry.value)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeTypeItem(FeeType type, double amount) {
    final typeName = _getFeeTypeName(type);
    final percentage = _analytics!.totalFees > 0 ? (amount / _analytics!.totalFees) * 100 : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getFeeTypeColor(type),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              typeName,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF181114),
              ),
            ),
          ),
          Text(
            'Ksh ${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF181114),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodAnalysis() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fees by Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181114),
              ),
            ),
            const SizedBox(height: 16),
            ..._analytics!.feesByPaymentMethod.entries.map((entry) => 
              _buildPaymentMethodItem(entry.key, entry.value)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodItem(PaymentMethod method, double amount) {
    final methodName = _getPaymentMethodName(method);
    final percentage = _analytics!.totalFees > 0 ? (amount / _analytics!.totalFees) * 100 : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getPaymentMethodColor(method).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getPaymentMethodIcon(method),
              color: _getPaymentMethodColor(method),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  methodName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF181114),
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}% of total fees',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Ksh ${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF181114),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection() {
    if (_insights == null) return const SizedBox.shrink();
    
    final insights = _insights!['insights'] as List<dynamic>? ?? [];
    final recommendations = _insights!['recommendations'] as List<dynamic>? ?? [];
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mali\'s Fee Insights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181114),
              ),
            ),
            const SizedBox(height: 16),
            
            if (insights.isNotEmpty) ...[
              const Text(
                'Key Insights:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEE2B8D),
                ),
              ),
              const SizedBox(height: 8),
              ...insights.map((insight) => _buildInsightItem(insight, Icons.lightbulb_outline, Colors.orange)),
              const SizedBox(height: 16),
            ],
            
            if (recommendations.isNotEmpty) ...[
              const Text(
                'Recommendations:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              ...recommendations.map((recommendation) => _buildInsightItem(recommendation, Icons.trending_up, Colors.green)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String text, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF181114),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentFees() {
    final recentFees = _analytics!.recentFees;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Transaction Fees',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181114),
              ),
            ),
            const SizedBox(height: 16),
            if (recentFees.isEmpty)
              const Center(
                child: Text(
                  'No recent fees',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              )
            else
              ...recentFees.map((fee) => _buildRecentFeeItem(fee)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentFeeItem(TransactionFee fee) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getPaymentMethodColor(fee.paymentMethod).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getPaymentMethodIcon(fee.paymentMethod),
              color: _getPaymentMethodColor(fee.paymentMethod),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fee.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF181114),
                  ),
                ),
                Text(
                  '${_getPaymentMethodName(fee.paymentMethod)} • ${_getFeeTypeName(fee.feeType)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Ksh ${fee.feeAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF181114),
                ),
              ),
              Text(
                '${_formatDateTime(fee.timestamp)}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getFeeTypeName(FeeType type) {
    switch (type) {
      case FeeType.transactionFee:
        return 'Transaction Fee';
      case FeeType.serviceCharge:
        return 'Service Charge';
      case FeeType.convenienceFee:
        return 'Convenience Fee';
      case FeeType.processingFee:
        return 'Processing Fee';
      case FeeType.withdrawalFee:
        return 'Withdrawal Fee';
      case FeeType.transferFee:
        return 'Transfer Fee';
      case FeeType.airtimeFee:
        return 'Airtime Fee';
      case FeeType.billPaymentFee:
        return 'Bill Payment Fee';
    }
  }

  Color _getFeeTypeColor(FeeType type) {
    switch (type) {
      case FeeType.transactionFee:
        return Colors.blue;
      case FeeType.serviceCharge:
        return Colors.orange;
      case FeeType.convenienceFee:
        return Colors.purple;
      case FeeType.processingFee:
        return Colors.green;
      case FeeType.withdrawalFee:
        return Colors.red;
      case FeeType.transferFee:
        return Colors.teal;
      case FeeType.airtimeFee:
        return Colors.pink;
      case FeeType.billPaymentFee:
        return Colors.indigo;
    }
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.mpesa:
        return 'M-Pesa';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.cardPayment:
        return 'Card Payment';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.mobileBanking:
        return 'Mobile Banking';
      case PaymentMethod.pesaLink:
        return 'PesaLink';
      case PaymentMethod.airtime:
        return 'Airtime';
      case PaymentMethod.other:
        return 'Other';
    }
  }

  Color _getPaymentMethodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.mpesa:
        return Colors.orange;
      case PaymentMethod.bankTransfer:
        return Colors.blue;
      case PaymentMethod.cardPayment:
        return Colors.purple;
      case PaymentMethod.cash:
        return Colors.green;
      case PaymentMethod.mobileBanking:
        return Colors.teal;
      case PaymentMethod.pesaLink:
        return Colors.indigo;
      case PaymentMethod.airtime:
        return Colors.pink;
      case PaymentMethod.other:
        return Colors.grey;
    }
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.mpesa:
        return Icons.phone_android;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.cardPayment:
        return Icons.credit_card;
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.mobileBanking:
        return Icons.mobile_friendly;
      case PaymentMethod.pesaLink:
        return Icons.link;
      case PaymentMethod.airtime:
        return Icons.signal_cellular_alt;
      case PaymentMethod.other:
        return Icons.payment;
    }
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

