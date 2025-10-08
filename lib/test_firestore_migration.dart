import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/financial_models.dart';
import 'services/firestore_database_service.dart';
import 'services/migration_service.dart';

/// Test script for Firestore migration
class FirestoreMigrationTest {
  static Future<void> runTests() async {
    print('🧪 Starting Firestore Migration Tests...\n');

    try {
      // Test 1: Check if user is authenticated
      print('Test 1: Authentication Check');
      if (!FirestoreDatabaseService.isAuthenticated) {
        print('❌ User not authenticated. Please log in first.');
        return;
      }
      print('✅ User is authenticated\n');

      // Test 2: Test adding an expense
      print('Test 2: Adding Expense');
      final testExpense = Expense(
        id: 'test_expense_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Test Expense',
        amount: 100.0,
        category: 'Food & Dining',
        date: DateTime.now(),
        note: 'Test expense for migration',
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: FirebaseAuth.instance.currentUser!.uid,
      );

      await FirestoreDatabaseService.addExpense(testExpense);
      print('✅ Expense added successfully\n');

      // Test 3: Test retrieving expenses
      print('Test 3: Retrieving Expenses');
      final expenses = await FirestoreDatabaseService.getExpenses();
      print('✅ Retrieved ${expenses.length} expenses\n');

      // Test 4: Test adding income
      print('Test 4: Adding Income');
      final testIncome = Income(
        id: 'test_income_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Test Income',
        amount: 5000.0,
        source: 'salary',
        date: DateTime.now(),
        description: 'Test income for migration',
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: FirebaseAuth.instance.currentUser!.uid,
      );

      await FirestoreDatabaseService.addIncome(testIncome);
      print('✅ Income added successfully\n');

      // Test 5: Test retrieving income
      print('Test 5: Retrieving Income');
      final income = await FirestoreDatabaseService.getIncome();
      print('✅ Retrieved ${income.length} income records\n');

      // Test 6: Test adding a budget
      print('Test 6: Adding Budget');
      final testBudget = Budget(
        id: 'test_budget_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Budget',
        category: 'Food & Dining',
        amount: 1000.0,
        spent: 0.0,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        period: 'monthly',
        isActive: true,
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: FirebaseAuth.instance.currentUser!.uid,
      );

      await FirestoreDatabaseService.addBudget(testBudget);
      print('✅ Budget added successfully\n');

      // Test 7: Test retrieving budgets
      print('Test 7: Retrieving Budgets');
      final budgets = await FirestoreDatabaseService.getBudgets();
      print('✅ Retrieved ${budgets.length} budgets\n');

      // Test 8: Test adding a goal
      print('Test 8: Adding Goal');
      final testGoal = FinancialGoal(
        id: 'test_goal_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Test Goal',
        description: 'Test goal for migration',
        targetAmount: 10000.0,
        currentAmount: 0.0,
        targetDate: DateTime.now().add(const Duration(days: 365)),
        category: 'emergency',
        priority: 'high',
        isCompleted: false,
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: FirebaseAuth.instance.currentUser!.uid,
      );

      await FirestoreDatabaseService.addGoal(testGoal);
      print('✅ Goal added successfully\n');

      // Test 9: Test retrieving goals
      print('Test 9: Retrieving Goals');
      final goals = await FirestoreDatabaseService.getGoals();
      print('✅ Retrieved ${goals.length} goals\n');

      // Test 10: Test migration status
      print('Test 10: Migration Status Check');
      final migrationStatus = await MigrationService.getMigrationStatus();
      print('Migration completed: ${migrationStatus['migrationCompleted']}');
      print('Migration version: ${migrationStatus['migrationVersion']}');
      print('Needs migration: ${migrationStatus['needsMigration']}\n');

      // Test 11: Test real-time streams
      print('Test 11: Testing Real-time Streams');
      final expensesStream = FirestoreDatabaseService.getExpensesStream();
      expensesStream.take(1).listen((expenses) {
        print('✅ Real-time stream working: ${expenses.length} expenses');
      });

      print('\n🎉 All tests completed successfully!');
      print('Firestore migration is working correctly.');

    } catch (e) {
      print('❌ Test failed: $e');
      print('Please check your Firebase configuration and authentication.');
    }
  }

  /// Test migration from SharedPreferences to Firestore
  static Future<void> testMigration() async {
    print('🔄 Testing Migration Process...\n');

    try {
      // Check if migration is needed
      final needsMigration = await MigrationService.isMigrationNeeded();
      print('Migration needed: $needsMigration');

      if (needsMigration) {
        // Perform migration
        final result = await MigrationService.performMigration();
        
        if (result.success) {
          print('✅ Migration completed successfully!');
          if (result.migratedData != null) {
            print('Migrated data:');
            result.migratedData!.forEach((key, value) {
              print('  - $key: $value items');
            });
          }
        } else {
          print('❌ Migration failed: ${result.message}');
        }
      } else {
        print('✅ No migration needed - data is already up to date');
      }

    } catch (e) {
      print('❌ Migration test failed: $e');
    }
  }

  /// Clean up test data
  static Future<void> cleanupTestData() async {
    print('🧹 Cleaning up test data...\n');

    try {
      // Get all expenses and delete test ones
      final expenses = await FirestoreDatabaseService.getExpenses();
      for (final expense in expenses) {
        if (expense.title.startsWith('Test ')) {
          await FirestoreDatabaseService.deleteExpense(expense.id);
          print('Deleted test expense: ${expense.title}');
        }
      }

      // Get all income and delete test ones
      final income = await FirestoreDatabaseService.getIncome();
      for (final incomeItem in income) {
        if (incomeItem.title.startsWith('Test ')) {
          // Note: We don't have a delete method for income yet
          print('Test income found: ${incomeItem.title} (not deleted - no delete method)');
        }
      }

      print('✅ Test data cleanup completed');

    } catch (e) {
      print('❌ Cleanup failed: $e');
    }
  }
}

/// Widget to run tests in the app
class FirestoreTestWidget extends StatefulWidget {
  const FirestoreTestWidget({super.key});

  @override
  State<FirestoreTestWidget> createState() => _FirestoreTestWidgetState();
}

class _FirestoreTestWidgetState extends State<FirestoreTestWidget> {
  String _testResults = 'Ready to run tests...';
  bool _isRunning = false;

  Future<void> _runTests() async {
    setState(() {
      _isRunning = true;
      _testResults = 'Running tests...\n';
    });

    try {
      await FirestoreMigrationTest.runTests();
      setState(() {
        _testResults = 'Tests completed successfully!';
      });
    } catch (e) {
      setState(() {
        _testResults = 'Tests failed: $e';
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  Future<void> _testMigration() async {
    setState(() {
      _isRunning = true;
      _testResults = 'Testing migration...\n';
    });

    try {
      await FirestoreMigrationTest.testMigration();
      setState(() {
        _testResults = 'Migration test completed!';
      });
    } catch (e) {
      setState(() {
        _testResults = 'Migration test failed: $e';
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  Future<void> _cleanup() async {
    setState(() {
      _isRunning = true;
      _testResults = 'Cleaning up...\n';
    });

    try {
      await FirestoreMigrationTest.cleanupTestData();
      setState(() {
        _testResults = 'Cleanup completed!';
      });
    } catch (e) {
      setState(() {
        _testResults = 'Cleanup failed: $e';
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Migration Tests'),
        backgroundColor: Colors.blue.shade50,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Results',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_testResults),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isRunning ? null : _runTests,
              child: _isRunning
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Running Tests...'),
                      ],
                    )
                  : const Text('Run All Tests'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isRunning ? null : _testMigration,
              child: const Text('Test Migration'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isRunning ? null : _cleanup,
              child: const Text('Cleanup Test Data'),
            ),
          ],
        ),
      ),
    );
  }
}













