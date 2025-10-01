import 'package:flutter/material.dart';
import '../services/transaction_fee_tracking_service.dart';

class FeeSummaryWidget extends StatefulWidget {
  final VoidCallback? onTap;
  
  const FeeSummaryWidget({
    super.key,
    this.onTap,
  });

  @override
  State<FeeSummaryWidget> createState() => _FeeSummaryWidgetState();
}

class _FeeSummaryWidgetState extends State<FeeSummaryWidget> {
  Map<String, dynamic>? _feeSummary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeeSummary();
  }

  Future<void> _loadFeeSummary() async {
    try {
      final summary = await TransactionFeeTrackingService.getFeeSummary();
      setState(() {
        _feeSummary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingCard();
    }

    if (_feeSummary == null || _feeSummary!['thisMonth'] == 0.0) {
      return _buildEmptyCard();
    }

    return _buildFeeSummaryCard();
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading fee data...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.account_balance_wallet,
              color: Colors.grey[400],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No transaction fees yet',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Start making transactions to see fee tracking',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
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

  Widget _buildFeeSummaryCard() {
    final today = _feeSummary!['today'] as double;
    final thisWeek = _feeSummary!['thisWeek'] as double;
    final thisMonth = _feeSummary!['thisMonth'] as double;
    final monthCount = _feeSummary!['monthCount'] as int;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEE2B8D).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Color(0xFFEE2B8D),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Transaction Fees',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF181114),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Fee amounts
              Row(
                children: [
                  Expanded(
                    child: _buildFeeItem(
                      'Today',
                      'Ksh ${today.toStringAsFixed(0)}',
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFeeItem(
                      'This Week',
                      'Ksh ${thisWeek.toStringAsFixed(0)}',
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFeeItem(
                      'This Month',
                      'Ksh ${thisMonth.toStringAsFixed(0)}',
                      const Color(0xFFEE2B8D),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Transaction count
              Row(
                children: [
                  Icon(
                    Icons.swap_horiz,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$monthCount transactions this month',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Fee percentage
              if (thisMonth > 0) ...[
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${((thisMonth / (thisMonth * 10)) * 100).toStringAsFixed(1)}% of spending',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeeItem(String label, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

