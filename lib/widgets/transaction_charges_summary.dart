import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/transaction_charges_service.dart';

class TransactionChargesSummary extends StatelessWidget {
  final List<Transaction> transactions;
  final String period;

  const TransactionChargesSummary({
    super.key,
    required this.transactions,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final chargesSummary = TransactionChargesService.getChargesSummary(transactions, period);
    final totalCharges = chargesSummary['totalCharges'] as double;
    final transactionCount = chargesSummary['transactionCount'] as int;
    final averageCharge = chargesSummary['averageCharge'] as double;
    final chargesByType = chargesSummary['chargesByType'] as Map<String, double>;

    if (transactionCount == 0) {
      return _buildEmptyState();
    }

    return Container(
      margin: const EdgeInsets.all(16),
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
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.attach_money,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction Charges',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF181114),
                      ),
                    ),
                    Text(
                      'Total charges for $period',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF575354),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Total charges card
          _buildTotalChargesCard(totalCharges, transactionCount, averageCharge),
          
          const SizedBox(height: 16),
          
          // Charges breakdown
          if (chargesByType.isNotEmpty) ...[
            Text(
              'Charges by Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF181114),
              ),
            ),
            const SizedBox(height: 12),
            ...chargesByType.entries.map((entry) => 
              _buildCategoryChargeItem(entry.key, entry.value, totalCharges)
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Insights
          _buildInsightsCard(totalCharges, transactionCount, averageCharge),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16),
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
          Icon(
            Icons.attach_money,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Transaction Charges',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Transaction charges will appear here once you have M-PESA transactions',
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalChargesCard(double totalCharges, int transactionCount, double averageCharge) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade50, Colors.red.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Charges',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ksh ${totalCharges.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$transactionCount transactions',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Avg: Ksh ${averageCharge.toStringAsFixed(0)}',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChargeItem(String category, double charge, double totalCharges) {
    final percentage = totalCharges > 0 ? (charge / totalCharges) * 100 : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              category,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF181114),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Ksh ${charge.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF181114),
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard(double totalCharges, int transactionCount, double averageCharge) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.blue.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Insights',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            'Monthly Impact',
            'You spend Ksh ${(totalCharges * 30).toStringAsFixed(0)} monthly on M-PESA charges',
            Icons.trending_up,
          ),
          const SizedBox(height: 8),
          _buildInsightItem(
            'Cost per Transaction',
            'Each M-PESA transaction costs you Ksh ${averageCharge.toStringAsFixed(0)} on average',
            Icons.analytics,
          ),
          const SizedBox(height: 8),
          _buildInsightItem(
            'Savings Tip',
            'Consider batching small transactions to reduce charges',
            Icons.savings,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.blue.shade600,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: Colors.blue.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

