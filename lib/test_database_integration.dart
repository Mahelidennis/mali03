import 'package:flutter/material.dart';
import 'models/financial_models.dart';
import 'services/database_service.dart';
import 'services/validation_service.dart';
import 'services/analytics_service.dart';
import 'services/sample_data_generator.dart';

/// Test screen for database integration
class DatabaseIntegrationTest extends StatefulWidget {
  const DatabaseIntegrationTest({super.key});

  @override
  State<DatabaseIntegrationTest> createState() => _DatabaseIntegrationTestState();
}

class _DatabaseIntegrationTestState extends State<DatabaseIntegrationTest> {
  bool _isLoading = false;
  String _status = 'Ready to test';
  List<String> _testResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Integration Test'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              color: _isLoading ? Colors.orange : Colors.green,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _isLoading ? Icons.hourglass_empty : Icons.check_circle,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTestButton(
                  'Generate Sample Data',
                  Icons.data_usage,
                  Colors.blue,
                  _generateSampleData,
                ),
                _buildTestButton(
                  'Test Expense CRUD',
                  Icons.receipt,
                  Colors.green,
                  _testExpenseCRUD,
                ),
                _buildTestButton(
                  'Test Budget CRUD',
                  Icons.account_balance_wallet,
                  Colors.purple,
                  _testBudgetCRUD,
                ),
                _buildTestButton(
                  'Test Goal CRUD',
                  Icons.flag,
                  Colors.orange,
                  _testGoalCRUD,
                ),
                _buildTestButton(
                  'Test Analytics',
                  Icons.analytics,
                  Colors.teal,
                  _testAnalytics,
                ),
                _buildTestButton(
                  'Test Validation',
                  Icons.verified,
                  Colors.red,
                  _testValidation,
                ),
                _buildTestButton(
                  'Test Sync',
                  Icons.sync,
                  Colors.indigo,
                  _testSync,
                ),
                _buildTestButton(
                  'Clear All Data',
                  Icons.delete_forever,
                  Colors.red,
                  _clearAllData,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Test Results
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.list_alt),
                          const SizedBox(width: 8),
                          Text(
                            'Test Results',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          if (_testResults.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _testResults.clear();
                                });
                              },
                              child: const Text('Clear'),
                            ),
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _testResults.length,
                          itemBuilder: (context, index) {
                            final result = _testResults[index];
                            final isError = result.startsWith('❌');
                            final isSuccess = result.startsWith('✅');
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                result,
                                style: TextStyle(
                                  color: isError 
                                      ? Colors.red 
                                      : isSuccess 
                                          ? Colors.green 
                                          : Colors.black87,
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(String title, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : onPressed,
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey,
      ),
    );
  }

  void _addResult(String result) {
    setState(() {
      _testResults.add('${DateTime.now().toString().substring(11, 19)} - $result');
    });
  }

  void _setStatus(String status) {
    setState(() {
      _status = status;
    });
  }

  Future<void> _generateSampleData() async {
    setState(() => _isLoading = true);
    _setStatus('Generating sample data...');
    
    try {
      await SampleDataGenerator.generateAllSampleData();
      _addResult('✅ Sample data generated successfully');
      _setStatus('Sample data generated');
    } catch (e) {
      _addResult('❌ Failed to generate sample data: $e');
      _setStatus('Error generating sample data');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testExpenseCRUD() async {
    setState(() => _isLoading = true);
    _setStatus('Testing expense CRUD operations...');
    
    try {
      // Create expense
      final expense = Expense(
        id: 'test_expense_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Test Expense',
        amount: 1000.0,
        category: 'Food & Dining',
        date: DateTime.now(),
        note: 'Test note',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: DatabaseService.currentUserId ?? 'test_user',
      );
      
      await DatabaseService.addExpense(expense);
      _addResult('✅ Expense created successfully');
      
      // Read expenses
      final expenses = await DatabaseService.getExpenses();
      _addResult('✅ Read ${expenses.length} expenses');
      
      // Update expense
      final updatedExpense = expense.copyWith(
        amount: 1500.0,
        note: 'Updated test note',
        updatedAt: DateTime.now(),
      );
      
      await DatabaseService.updateExpense(updatedExpense);
      _addResult('✅ Expense updated successfully');
      
      // Delete expense
      await DatabaseService.deleteExpense(expense.id);
      _addResult('✅ Expense deleted successfully');
      
      _setStatus('Expense CRUD test completed');
    } catch (e) {
      _addResult('❌ Expense CRUD test failed: $e');
      _setStatus('Expense CRUD test failed');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testBudgetCRUD() async {
    setState(() => _isLoading = true);
    _setStatus('Testing budget CRUD operations...');
    
    try {
      // Create budget
      final budget = Budget(
        id: 'test_budget_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Budget',
        category: 'Food & Dining',
        amount: 5000.0,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        period: 'monthly',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: DatabaseService.currentUserId ?? 'test_user',
      );
      
      await DatabaseService.addBudget(budget);
      _addResult('✅ Budget created successfully');
      
      // Read budgets
      final budgets = await DatabaseService.getBudgets();
      _addResult('✅ Read ${budgets.length} budgets');
      
      // Update budget
      final updatedBudget = budget.copyWith(
        amount: 6000.0,
        updatedAt: DateTime.now(),
      );
      
      await DatabaseService.updateBudget(updatedBudget);
      _addResult('✅ Budget updated successfully');
      
      _setStatus('Budget CRUD test completed');
    } catch (e) {
      _addResult('❌ Budget CRUD test failed: $e');
      _setStatus('Budget CRUD test failed');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testGoalCRUD() async {
    setState(() => _isLoading = true);
    _setStatus('Testing goal CRUD operations...');
    
    try {
      // Create goal
      final goal = FinancialGoal(
        id: 'test_goal_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Test Goal',
        description: 'Test goal description',
        targetAmount: 100000.0,
        currentAmount: 10000.0,
        targetDate: DateTime.now().add(const Duration(days: 365)),
        category: 'emergency',
        priority: 'high',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: DatabaseService.currentUserId ?? 'test_user',
      );
      
      await DatabaseService.addGoal(goal);
      _addResult('✅ Goal created successfully');
      
      // Read goals
      final goals = await DatabaseService.getGoals();
      _addResult('✅ Read ${goals.length} goals');
      
      // Update goal
      final updatedGoal = goal.copyWith(
        currentAmount: 20000.0,
        updatedAt: DateTime.now(),
      );
      
      await DatabaseService.updateGoal(updatedGoal);
      _addResult('✅ Goal updated successfully');
      
      _setStatus('Goal CRUD test completed');
    } catch (e) {
      _addResult('❌ Goal CRUD test failed: $e');
      _setStatus('Goal CRUD test failed');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testAnalytics() async {
    setState(() => _isLoading = true);
    _setStatus('Testing analytics...');
    
    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      
      // Test spending summary
      final spendingSummary = await AnalyticsService.getSpendingSummary(
        startDate: monthStart,
        endDate: now,
      );
      _addResult('✅ Spending summary: KSh ${spendingSummary['totalSpending']?.toStringAsFixed(0) ?? '0'}');
      
      // Test monthly trends
      final trends = await AnalyticsService.getMonthlyTrends(months: 3);
      _addResult('✅ Monthly trends: ${trends.length} months');
      
      // Test category insights
      final categoryInsights = await AnalyticsService.getCategoryInsights(
        startDate: monthStart,
        endDate: now,
      );
      _addResult('✅ Category insights: ${categoryInsights['categorySpending']?.keys.length ?? 0} categories');
      
      // Test financial health score
      final healthScore = await AnalyticsService.getFinancialHealthScore();
      _addResult('✅ Financial health score: ${healthScore['overallScore'] ?? 0}/100');
      
      // Test budget performance
      final budgetPerformance = await AnalyticsService.getBudgetPerformance();
      _addResult('✅ Budget performance: ${budgetPerformance.length} budgets');
      
      // Test goal insights
      final goalInsights = await AnalyticsService.getGoalInsights();
      _addResult('✅ Goal insights: ${goalInsights.length} goals');
      
      _setStatus('Analytics test completed');
    } catch (e) {
      _addResult('❌ Analytics test failed: $e');
      _setStatus('Analytics test failed');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testValidation() async {
    setState(() => _isLoading = true);
    _setStatus('Testing validation...');
    
    try {
      // Test expense validation
      final validExpense = Expense(
        id: 'test',
        title: 'Valid Expense',
        amount: 100.0,
        category: 'Food',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: 'test',
      );
      
      final expenseValidation = ValidationService.validateExpense(validExpense);
      _addResult('✅ Valid expense validation: ${expenseValidation.isValid}');
      
      // Test invalid expense
      final invalidExpense = Expense(
        id: 'test',
        title: '', // Invalid: empty title
        amount: -100.0, // Invalid: negative amount
        category: 'Food',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: 'test',
      );
      
      final invalidExpenseValidation = ValidationService.validateExpense(invalidExpense);
      _addResult('✅ Invalid expense validation: ${invalidExpenseValidation.isValid} (${invalidExpenseValidation.errors.length} errors)');
      
      // Test budget validation
      final validBudget = Budget(
        id: 'test',
        name: 'Valid Budget',
        category: 'Food',
        amount: 1000.0,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        period: 'monthly',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: 'test',
      );
      
      final budgetValidation = ValidationService.validateBudget(validBudget);
      _addResult('✅ Valid budget validation: ${budgetValidation.isValid}');
      
      // Test goal validation
      final validGoal = FinancialGoal(
        id: 'test',
        title: 'Valid Goal',
        description: 'Test goal',
        targetAmount: 10000.0,
        targetDate: DateTime.now().add(const Duration(days: 365)),
        category: 'emergency',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: 'test',
      );
      
      final goalValidation = ValidationService.validateGoal(validGoal);
      _addResult('✅ Valid goal validation: ${goalValidation.isValid}');
      
      // Test profile validation
      final validProfile = UserProfile(
        id: 'test',
        name: 'Test User',
        email: 'test@example.com',
        gender: 'female',
        monthlyIncome: 50000.0,
        interests: ['finance'],
        preferredLanguage: 'en',
        primaryGoal: 'Save money',
        joinDate: DateTime.now(),
        lastActive: DateTime.now(),
      );
      
      final profileValidation = ValidationService.validateProfile(validProfile);
      _addResult('✅ Valid profile validation: ${profileValidation.isValid}');
      
      _setStatus('Validation test completed');
    } catch (e) {
      _addResult('❌ Validation test failed: $e');
      _setStatus('Validation test failed');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testSync() async {
    setState(() => _isLoading = true);
    _setStatus('Testing sync...');
    
    try {
      // Test sync
      await DatabaseService.syncData();
      _addResult('✅ Data sync completed');
      
      // Check last sync time
      final lastSync = await DatabaseService.getLastSyncTime();
      _addResult('✅ Last sync time: ${lastSync?.toString() ?? 'Never'}');
      
      _setStatus('Sync test completed');
    } catch (e) {
      _addResult('❌ Sync test failed: $e');
      _setStatus('Sync test failed');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearAllData() async {
    setState(() => _isLoading = true);
    _setStatus('Clearing all data...');
    
    try {
      // This would need to be implemented in DatabaseService
      // For now, just show a message
      _addResult('⚠️ Clear all data not implemented yet');
      _setStatus('Clear data not implemented');
    } catch (e) {
      _addResult('❌ Clear data failed: $e');
      _setStatus('Clear data failed');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
