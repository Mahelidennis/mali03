import 'package:flutter/material.dart';
import 'financial_data_service.dart';

class SpendingTrackerScreen extends StatefulWidget {
  const SpendingTrackerScreen({super.key});

  @override
  State<SpendingTrackerScreen> createState() => _SpendingTrackerScreenState();
}

class _SpendingTrackerScreenState extends State<SpendingTrackerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Other';
  Map<String, dynamic> _currentSpending = {};
  List<Map<String, dynamic>> _recentTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSpendingData();
  }

  Future<void> _loadSpendingData() async {
    final spendingData = await FinancialDataService.getCurrentMonthSpending();
    final transactions = spendingData['transactions'] as List? ?? [];
    
    setState(() {
      _currentSpending = Map<String, dynamic>.from(spendingData);
      _recentTransactions = transactions.map((t) => Map<String, dynamic>.from(t)).toList();
      _isLoading = false;
    });
  }

  void _addTransaction() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      
      await FinancialDataService.addSpendingTransaction(
        category: _selectedCategory,
        amount: amount,
        description: _descriptionController.text,
      );

      // Clear form
      _amountController.clear();
      _descriptionController.clear();
      _selectedCategory = 'Other';

      // Reload data
      await _loadSpendingData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added KSh ${amount.toStringAsFixed(0)} to $_selectedCategory'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Spending Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAddTransactionCard(),
                  const SizedBox(height: 24),
                  _buildSpendingSummary(),
                  const SizedBox(height: 24),
                  _buildRecentTransactions(),
                ],
              ),
            ),
    );
  }

  Widget _buildAddTransactionCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Transaction',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: FinancialDataService.spendingCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (KSh)',
                  border: OutlineInputBorder(),
                  prefixText: 'KSh ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Add Transaction',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpendingSummary() {
    double totalSpent = 0.0;
    _currentSpending.forEach((category, amount) {
      if (amount is double && category != 'transactions') {
        totalSpent += amount;
      }
    });

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This Month\'s Spending',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Spent',
                    'KSh ${totalSpent.toStringAsFixed(0)}',
                    Icons.account_balance_wallet,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryItem(
                    'Categories',
                    '${_currentSpending.length - 1}',
                    Icons.category,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Top Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._getTopCategories().map((category) => _buildCategoryItem(category)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
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
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getTopCategories() {
    final categories = <Map<String, dynamic>>[];
    _currentSpending.forEach((category, amount) {
      if (amount is double && category != 'transactions' && amount > 0) {
        categories.add({
          'category': category,
          'amount': amount,
        });
      }
    });
    
    categories.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
    return categories.take(3).toList();
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            category['category'],
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            'KSh ${(category['amount'] as double).toStringAsFixed(0)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_recentTransactions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No transactions yet this month',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ..._recentTransactions.take(5).map((transaction) => _buildTransactionItem(transaction)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final date = DateTime.parse(transaction['date']);
    final amount = transaction['amount'] as double;
    final category = transaction['category'] as String;
    final description = transaction['description'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(category),
              color: Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (description != null && description.isNotEmpty)
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'KSh ${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Coffee & Drinks':
        return Icons.coffee;
      case 'Transport':
        return Icons.directions_car;
      case 'Food & Dining':
        return Icons.restaurant;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Entertainment':
        return Icons.movie;
      case 'Bills & Utilities':
        return Icons.receipt;
      case 'Healthcare':
        return Icons.medical_services;
      case 'Education':
        return Icons.school;
      case 'Investment':
        return Icons.trending_up;
      case 'Savings':
        return Icons.savings;
      default:
        return Icons.attach_money;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
} 