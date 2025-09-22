import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/financial_models.dart';
import 'services/database_service.dart';
import 'services/validation_service.dart';
import 'services/analytics_service.dart';

/// Enhanced expense tracker with database integration
class EnhancedExpenseTracker extends StatefulWidget {
  const EnhancedExpenseTracker({super.key});

  @override
  State<EnhancedExpenseTracker> createState() => _EnhancedExpenseTrackerState();
}

class _EnhancedExpenseTrackerState extends State<EnhancedExpenseTracker> {
  List<Expense> _expenses = [];
  List<Budget> _budgets = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic> _spendingSummary = {};
  Map<String, dynamic> _financialHealth = {};

  final List<String> _categories = [
    'All',
    'Food & Dining',
    'Transport',
    'Shopping',
    'Bills & Utilities',
    'Entertainment',
    'Healthcare',
    'Education',
    'Coffee',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load expenses
      final expenses = await DatabaseService.getExpenses();
      
      // Load budgets
      final budgets = await DatabaseService.getBudgets();
      
      // Load analytics
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final spendingSummary = await AnalyticsService.getSpendingSummary(
        startDate: monthStart,
        endDate: now,
      );
      
      final financialHealth = await AnalyticsService.getFinancialHealthScore();
      
      setState(() {
        _expenses = expenses;
        _budgets = budgets;
        _spendingSummary = spendingSummary;
        _financialHealth = financialHealth;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load data: $e');
    }
  }

  Future<void> _addExpense() async {
    final result = await showDialog<Expense>(
      context: context,
      builder: (context) => const AddExpenseDialog(),
    );

    if (result != null) {
      try {
        // Validate expense
        final validation = ValidationService.validateExpense(result);
        if (!validation.isValid) {
          _showErrorSnackBar(validation.errorMessage);
          return;
        }

        // Add to database
        await DatabaseService.addExpense(result);
        
        // Reload data
        await _loadData();
        
        _showSuccessSnackBar('Expense added successfully!');
      } catch (e) {
        _showErrorSnackBar('Failed to add expense: $e');
      }
    }
  }

  Future<void> _addBudget() async {
    final result = await showDialog<Budget>(
      context: context,
      builder: (context) => const AddBudgetDialog(),
    );

    if (result != null) {
      try {
        // Validate budget
        final validation = ValidationService.validateBudget(result);
        if (!validation.isValid) {
          _showErrorSnackBar(validation.errorMessage);
          return;
        }

        // Add to database
        await DatabaseService.addBudget(result);
        
        // Reload data
        await _loadData();
        
        _showSuccessSnackBar('Budget created successfully!');
      } catch (e) {
        _showErrorSnackBar('Failed to create budget: $e');
      }
    }
  }

  Future<void> _syncData() async {
    try {
      await DatabaseService.syncData();
      await _loadData();
      _showSuccessSnackBar('Data synced successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to sync data: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  List<Expense> get _filteredExpenses {
    var filtered = _expenses;
    
    if (_selectedCategory != 'All') {
      filtered = filtered.where((e) => e.category == _selectedCategory).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _syncData,
            tooltip: 'Sync Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Financial Health Card
                _buildFinancialHealthCard(),
                
                // Spending Summary
                _buildSpendingSummaryCard(),
                
                // Filters
                _buildFilters(),
                
                // Expenses List
                Expanded(
                  child: _buildExpensesList(),
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'budget',
            onPressed: _addBudget,
            child: const Icon(Icons.account_balance_wallet),
            tooltip: 'Add Budget',
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'expense',
            onPressed: _addExpense,
            child: const Icon(Icons.add),
            tooltip: 'Add Expense',
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialHealthCard() {
    final score = _financialHealth['overallScore'] ?? 0;
    final recommendations = _financialHealth['recommendations'] as List<dynamic>? ?? [];
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.health_and_safety, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Financial Health Score',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '$score/100',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: _getScoreColor(score),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score)),
                  ),
                ),
              ],
            ),
            if (recommendations.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Recommendations:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...recommendations.take(2).map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $rec',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingSummaryCard() {
    final totalSpending = _spendingSummary['totalSpending'] ?? 0.0;
    final averageDaily = _spendingSummary['averageDailySpending'] ?? 0.0;
    final topCategory = _spendingSummary['topCategory'] ?? 'None';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Month',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'KSh ${totalSpending.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Average',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    'KSh ${averageDaily.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Category',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    topCategory,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
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

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
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
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              controller: TextEditingController(
                text: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList() {
    final filteredExpenses = _filteredExpenses;
    
    if (filteredExpenses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No expenses found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Tap + to add your first expense',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredExpenses.length,
      itemBuilder: (context, index) {
        final expense = filteredExpenses[index];
        return _buildExpenseCard(expense);
      },
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(expense.category),
          child: Text(
            expense.category[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(expense.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(expense.category),
            if (expense.note != null) Text(expense.note!),
            Text(
              '${expense.date.day}/${expense.date.month}/${expense.date.year}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Text(
          'KSh ${expense.amount.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        onTap: () => _showExpenseDetails(expense),
      ),
    );
  }

  void _showExpenseDetails(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expense.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: KSh ${expense.amount.toStringAsFixed(0)}'),
            Text('Category: ${expense.category}'),
            Text('Date: ${expense.date.day}/${expense.date.month}/${expense.date.year}'),
            if (expense.note != null) Text('Note: ${expense.note}'),
            if (expense.location != null) Text('Location: ${expense.location}'),
            if (expense.paymentMethod != null) Text('Payment: ${expense.paymentMethod}'),
            if (expense.isRecurring) Text('Recurring: ${expense.recurringType}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteExpense(expense);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteExpense(Expense expense) async {
    try {
      await DatabaseService.deleteExpense(expense.id);
      await _loadData();
      _showSuccessSnackBar('Expense deleted successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to delete expense: $e');
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Food & Dining': Colors.orange,
      'Transport': Colors.blue,
      'Shopping': Colors.purple,
      'Bills & Utilities': Colors.red,
      'Entertainment': Colors.pink,
      'Healthcare': Colors.green,
      'Education': Colors.indigo,
      'Coffee': Colors.brown,
      'Other': Colors.grey,
    };
    return colors[category] ?? Colors.grey;
  }
}

/// Dialog for adding new expenses
class AddExpenseDialog extends StatefulWidget {
  const AddExpenseDialog({super.key});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _locationController = TextEditingController();
  
  String _selectedCategory = 'Food & Dining';
  String _selectedPaymentMethod = 'Cash';
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  String _recurringType = 'monthly';

  final List<String> _categories = [
    'Food & Dining',
    'Transport',
    'Shopping',
    'Bills & Utilities',
    'Entertainment',
    'Healthcare',
    'Education',
    'Coffee',
    'Other',
  ];

  final List<String> _paymentMethods = [
    'Cash',
    'Card',
    'Mobile Money',
    'Bank Transfer',
    'Other',
  ];

  final List<String> _recurringTypes = [
    'daily',
    'weekly',
    'monthly',
    'yearly',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Expense'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount *',
                  border: OutlineInputBorder(),
                  prefixText: 'KSh ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Amount is required';
                  }
                  final amount = ValidationService.parseAmount(value);
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
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
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
                controller: TextEditingController(
                  text: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(),
                ),
                items: _paymentMethods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Recurring Expense'),
                value: _isRecurring,
                onChanged: (value) {
                  setState(() {
                    _isRecurring = value ?? false;
                  });
                },
              ),
              if (_isRecurring) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _recurringType,
                  decoration: const InputDecoration(
                    labelText: 'Recurring Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _recurringTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _recurringType = value!;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveExpense,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final amount = ValidationService.parseAmount(_amountController.text);
      if (amount == null) return;

      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        amount: amount,
        category: _selectedCategory,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        paymentMethod: _selectedPaymentMethod,
        isRecurring: _isRecurring,
        recurringType: _isRecurring ? _recurringType : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: DatabaseService.currentUserId ?? 'anonymous',
      );

      Navigator.pop(context, expense);
    }
  }
}

/// Dialog for adding new budgets
class AddBudgetDialog extends StatefulWidget {
  const AddBudgetDialog({super.key});

  @override
  State<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  
  String _selectedCategory = 'Food & Dining';
  String _selectedPeriod = 'monthly';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  final List<String> _categories = [
    'Food & Dining',
    'Transport',
    'Shopping',
    'Bills & Utilities',
    'Entertainment',
    'Healthcare',
    'Education',
    'Coffee',
    'Other',
  ];

  final List<String> _periods = [
    'monthly',
    'weekly',
    'yearly',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Budget'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Budget Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Budget name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Budget Amount *',
                border: OutlineInputBorder(),
                prefixText: 'KSh ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Amount is required';
                }
                final amount = ValidationService.parseAmount(value);
                if (amount == null || amount <= 0) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
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
            DropdownButtonFormField<String>(
              value: _selectedPeriod,
              decoration: const InputDecoration(
                labelText: 'Period *',
                border: OutlineInputBorder(),
              ),
              items: _periods.map((period) {
                return DropdownMenuItem(
                  value: period,
                  child: Text(period.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPeriod = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                        });
                      }
                    },
                    controller: TextEditingController(
                      text: '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'End Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate,
                        firstDate: _startDate,
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                        });
                      }
                    },
                    controller: TextEditingController(
                      text: '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveBudget,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _saveBudget() {
    if (_formKey.currentState!.validate()) {
      final amount = ValidationService.parseAmount(_amountController.text);
      if (amount == null) return;

      final budget = Budget(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        category: _selectedCategory,
        amount: amount,
        startDate: _startDate,
        endDate: _endDate,
        period: _selectedPeriod,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: DatabaseService.currentUserId ?? 'anonymous',
      );

      Navigator.pop(context, budget);
    }
  }
}
