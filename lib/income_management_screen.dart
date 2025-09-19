import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'income_input_screen.dart';

class IncomeManagementScreen extends StatefulWidget {
  const IncomeManagementScreen({super.key});

  @override
  State<IncomeManagementScreen> createState() => _IncomeManagementScreenState();
}

class _IncomeManagementScreenState extends State<IncomeManagementScreen> {
  List<Map<String, dynamic>> _incomes = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  
  final List<String> _filterOptions = ['All', 'This Month', 'Last Month', 'This Year'];

  @override
  void initState() {
    super.initState();
    _loadIncomes();
  }

  Future<void> _loadIncomes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final incomesString = prefs.getStringList('user_incomes') ?? [];
      
      final incomes = incomesString.map((incomeString) {
        return jsonDecode(incomeString) as Map<String, dynamic>;
      }).toList();

      // Sort by date (newest first)
      incomes.sort((a, b) {
        final dateA = DateTime.parse(a['date']);
        final dateB = DateTime.parse(b['date']);
        return dateB.compareTo(dateA);
      });

      setState(() {
        _incomes = incomes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading incomes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredIncomes() {
    if (_selectedFilter == 'All') return _incomes;
    
    final now = DateTime.now();
    return _incomes.where((income) {
      final incomeDate = DateTime.parse(income['date']);
      
      switch (_selectedFilter) {
        case 'This Month':
          return incomeDate.year == now.year && incomeDate.month == now.month;
        case 'Last Month':
          final lastMonth = DateTime(now.year, now.month - 1);
          return incomeDate.year == lastMonth.year && incomeDate.month == lastMonth.month;
        case 'This Year':
          return incomeDate.year == now.year;
        default:
          return true;
      }
    }).toList();
  }

  double _getTotalIncome() {
    return _getFilteredIncomes().fold(0.0, (sum, income) => sum + (income['amount'] as double));
  }

  Map<String, double> _getIncomeBySource() {
    final filteredIncomes = _getFilteredIncomes();
    final incomeBySource = <String, double>{};
    
    for (final income in filteredIncomes) {
      final source = income['source'] as String;
      incomeBySource[source] = (incomeBySource[source] ?? 0) + (income['amount'] as double);
    }
    
    return incomeBySource;
  }

  Future<void> _deleteIncome(Map<String, dynamic> income) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final incomes = prefs.getStringList('user_incomes') ?? [];
      
      // Remove the income
      incomes.removeWhere((incomeString) {
        final incomeData = jsonDecode(incomeString);
        return incomeData['date'] == income['date'] && 
               incomeData['amount'] == income['amount'] &&
               incomeData['title'] == income['title'];
      });
      
      await prefs.setStringList('user_incomes', incomes);
      await _loadIncomes();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Income deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting income: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          'Income Management',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFEE2B8D)),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const IncomeInputScreen()),
              );
              if (result == true) {
                _loadIncomes();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2E7D32), // Dark green
                        Color(0xFF1B5E20), // Darker green
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total Income (${_selectedFilter})',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ksh ${_getTotalIncome().toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Filter tabs
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filterOptions.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            selectedColor: const Color(0xFFEE2B8D).withOpacity(0.2),
                            checkmarkColor: const Color(0xFFEE2B8D),
                            labelStyle: TextStyle(
                              color: isSelected ? const Color(0xFFEE2B8D) : Colors.grey[600],
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Income sources breakdown
                if (_getIncomeBySource().isNotEmpty) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Income by Source',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._getIncomeBySource().entries.map((entry) {
                          final percentage = _getTotalIncome() > 0 
                              ? (entry.value / _getTotalIncome() * 100)
                              : 0.0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Ksh ${entry.value.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Income list
                Expanded(
                  child: _getFilteredIncomes().isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _getFilteredIncomes().length,
                          itemBuilder: (context, index) {
                            final income = _getFilteredIncomes()[index];
                            return _buildIncomeItem(income);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const IncomeInputScreen()),
          );
          if (result == true) {
            _loadIncomes();
          }
        },
        backgroundColor: const Color(0xFFEE2B8D),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No income records found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first income source',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const IncomeInputScreen()),
              );
              if (result == true) {
                _loadIncomes();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEE2B8D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Add Income'),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeItem(Map<String, dynamic> income) {
    final date = DateTime.parse(income['date']);
    final amount = income['amount'] as double;
    final title = income['title'] as String;
    final source = income['source'] as String;
    final description = income['description'] as String?;

    IconData icon;
    switch (source.toLowerCase()) {
      case 'salary':
        icon = Icons.work;
        break;
      case 'freelance':
        icon = Icons.computer;
        break;
      case 'business':
        icon = Icons.business;
        break;
      case 'investment':
        icon = Icons.trending_up;
        break;
      case 'gift':
        icon = Icons.card_giftcard;
        break;
      case 'bonus':
        icon = Icons.stars;
        break;
      default:
        icon = Icons.account_balance_wallet;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2E7D32),
              size: 20,
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
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  source,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                if (description != null && description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: const TextStyle(
                    color: Colors.grey,
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
                '+ Ksh ${amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.red[300],
                onPressed: () => _showDeleteDialog(income),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> income) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Income'),
        content: Text('Are you sure you want to delete "${income['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteIncome(income);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
