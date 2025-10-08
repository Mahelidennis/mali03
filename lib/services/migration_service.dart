import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../models/financial_models.dart';
import 'firestore_database_service.dart';

/// Service to handle migration from SharedPreferences to Firestore
class MigrationService {
  static const String _migrationKey = 'migration_completed';
  static const String _migrationVersionKey = 'migration_version';
  static const int _currentMigrationVersion = 1;

  /// Check if migration is needed
  static Future<bool> isMigrationNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final migrationCompleted = prefs.getBool(_migrationKey) ?? false;
    final migrationVersion = prefs.getInt(_migrationVersionKey) ?? 0;
    
    return !migrationCompleted || migrationVersion < _currentMigrationVersion;
  }

  /// Perform migration from SharedPreferences to Firestore
  static Future<MigrationResult> performMigration() async {
    try {
      // Check if user is authenticated
      if (!FirestoreDatabaseService.isAuthenticated) {
        return MigrationResult(
          success: false,
          message: 'User not authenticated. Please log in first.',
        );
      }

      // Get all data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      
      // Migrate expenses
      final expenses = await _migrateExpenses(prefs);
      
      // Migrate income
      final income = await _migrateIncome(prefs);
      
      // Migrate budgets
      final budgets = await _migrateBudgets(prefs);
      
      // Migrate goals
      final goals = await _migrateGoals(prefs);
      
      // Migrate profile
      final profile = await _migrateProfile(prefs);

      // Mark migration as completed
      await prefs.setBool(_migrationKey, true);
      await prefs.setInt(_migrationVersionKey, _currentMigrationVersion);

      return MigrationResult(
        success: true,
        message: 'Migration completed successfully!',
        migratedData: {
          'expenses': expenses,
          'income': income,
          'budgets': budgets,
          'goals': goals,
          'profile': profile != null ? 1 : 0,
        },
      );
    } catch (e) {
      return MigrationResult(
        success: false,
        message: 'Migration failed: $e',
      );
    }
  }

  /// Migrate expenses from SharedPreferences to Firestore
  static Future<int> _migrateExpenses(SharedPreferences prefs) async {
    final expensesJson = prefs.getString('user_expenses');
    if (expensesJson == null) return 0;

    final List<dynamic> expensesList = jsonDecode(expensesJson);
    int migratedCount = 0;

    for (final expenseData in expensesList) {
      try {
        // Convert old format to new format if needed
        final expense = _convertOldExpenseFormat(expenseData);
        
        // Add to Firestore
        await FirestoreDatabaseService.addExpense(expense);
        migratedCount++;
      } catch (e) {
        print('Failed to migrate expense: $e');
      }
    }

    return migratedCount;
  }

  /// Migrate income from SharedPreferences to Firestore
  static Future<int> _migrateIncome(SharedPreferences prefs) async {
    final incomeJson = prefs.getString('user_income');
    if (incomeJson == null) return 0;

    final List<dynamic> incomeList = jsonDecode(incomeJson);
    int migratedCount = 0;

    for (final incomeData in incomeList) {
      try {
        // Convert old format to new format if needed
        final income = _convertOldIncomeFormat(incomeData);
        
        // Add to Firestore
        await FirestoreDatabaseService.addIncome(income);
        migratedCount++;
      } catch (e) {
        print('Failed to migrate income: $e');
      }
    }

    return migratedCount;
  }

  /// Migrate budgets from SharedPreferences to Firestore
  static Future<int> _migrateBudgets(SharedPreferences prefs) async {
    final budgetsJson = prefs.getString('user_budgets');
    if (budgetsJson == null) return 0;

    final List<dynamic> budgetsList = jsonDecode(budgetsJson);
    int migratedCount = 0;

    for (final budgetData in budgetsList) {
      try {
        // Convert old format to new format if needed
        final budget = _convertOldBudgetFormat(budgetData);
        
        // Add to Firestore
        await FirestoreDatabaseService.addBudget(budget);
        migratedCount++;
      } catch (e) {
        print('Failed to migrate budget: $e');
      }
    }

    return migratedCount;
  }

  /// Migrate goals from SharedPreferences to Firestore
  static Future<int> _migrateGoals(SharedPreferences prefs) async {
    final goalsJson = prefs.getString('user_goals');
    if (goalsJson == null) return 0;

    final List<dynamic> goalsList = jsonDecode(goalsJson);
    int migratedCount = 0;

    for (final goalData in goalsList) {
      try {
        // Convert old format to new format if needed
        final goal = _convertOldGoalFormat(goalData);
        
        // Add to Firestore
        await FirestoreDatabaseService.addGoal(goal);
        migratedCount++;
      } catch (e) {
        print('Failed to migrate goal: $e');
      }
    }

    return migratedCount;
  }

  /// Migrate profile from SharedPreferences to Firestore
  static Future<UserProfile?> _migrateProfile(SharedPreferences prefs) async {
    final profileJson = prefs.getString('user_profile');
    if (profileJson == null) return null;

    try {
      final profileData = jsonDecode(profileJson);
      final profile = _convertOldProfileFormat(profileData);
      
      // Save to Firestore
      await FirestoreDatabaseService.saveUserProfile(profile);
      return profile;
    } catch (e) {
      print('Failed to migrate profile: $e');
      return null;
    }
  }

  /// Convert old expense format to new format
  static Expense _convertOldExpenseFormat(Map<String, dynamic> data) {
    final now = DateTime.now();
    final random = Random();
    
    return Expense(
      id: data['id'] ?? _generateId(),
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      category: data['category'] ?? 'Other',
      date: data['date'] != null 
          ? DateTime.parse(data['date']) 
          : now,
      note: data['note'],
      location: data['location'],
      paymentMethod: data['paymentMethod'],
      isRecurring: data['isRecurring'] ?? false,
      recurringType: data['recurringType'],
      status: 'active',
      createdAt: data['createdAt'] != null 
          ? DateTime.parse(data['createdAt']) 
          : now,
      updatedAt: data['updatedAt'] != null 
          ? DateTime.parse(data['updatedAt']) 
          : now,
      userId: data['userId'] ?? '',
    );
  }

  /// Convert old income format to new format
  static Income _convertOldIncomeFormat(Map<String, dynamic> data) {
    final now = DateTime.now();
    
    return Income(
      id: data['id'] ?? _generateId(),
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      source: data['source'] ?? 'salary',
      date: data['date'] != null 
          ? DateTime.parse(data['date']) 
          : now,
      description: data['description'],
      category: data['category'],
      isRecurring: data['isRecurring'] ?? false,
      recurringType: data['recurringType'],
      status: 'active',
      createdAt: data['createdAt'] != null 
          ? DateTime.parse(data['createdAt']) 
          : now,
      updatedAt: data['updatedAt'] != null 
          ? DateTime.parse(data['updatedAt']) 
          : now,
      userId: data['userId'] ?? '',
    );
  }

  /// Convert old budget format to new format
  static Budget _convertOldBudgetFormat(Map<String, dynamic> data) {
    final now = DateTime.now();
    
    return Budget(
      id: data['id'] ?? _generateId(),
      name: data['name'] ?? '',
      category: data['category'] ?? 'Other',
      amount: (data['amount'] ?? 0).toDouble(),
      spent: (data['spent'] ?? 0).toDouble(),
      startDate: data['startDate'] != null 
          ? DateTime.parse(data['startDate']) 
          : now,
      endDate: data['endDate'] != null 
          ? DateTime.parse(data['endDate']) 
          : now.add(const Duration(days: 30)),
      period: data['period'] ?? 'monthly',
      isActive: data['isActive'] ?? true,
      status: 'active',
      createdAt: data['createdAt'] != null 
          ? DateTime.parse(data['createdAt']) 
          : now,
      updatedAt: data['updatedAt'] != null 
          ? DateTime.parse(data['updatedAt']) 
          : now,
      userId: data['userId'] ?? '',
    );
  }

  /// Convert old goal format to new format
  static FinancialGoal _convertOldGoalFormat(Map<String, dynamic> data) {
    final now = DateTime.now();
    
    return FinancialGoal(
      id: data['id'] ?? _generateId(),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      targetAmount: (data['targetAmount'] ?? 0).toDouble(),
      currentAmount: (data['currentAmount'] ?? 0).toDouble(),
      targetDate: data['targetDate'] != null 
          ? DateTime.parse(data['targetDate']) 
          : now.add(const Duration(days: 365)),
      category: data['category'] ?? 'other',
      priority: data['priority'] ?? 'medium',
      isCompleted: data['isCompleted'] ?? false,
      status: 'active',
      createdAt: data['createdAt'] != null 
          ? DateTime.parse(data['createdAt']) 
          : now,
      updatedAt: data['updatedAt'] != null 
          ? DateTime.parse(data['updatedAt']) 
          : now,
      userId: data['userId'] ?? '',
    );
  }

  /// Convert old profile format to new format
  static UserProfile _convertOldProfileFormat(Map<String, dynamic> data) {
    final now = DateTime.now();
    
    return UserProfile(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      gender: data['gender'] ?? 'female',
      monthlyIncome: (data['monthlyIncome'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'KES',
      interests: List<String>.from(data['interests'] ?? []),
      preferredLanguage: data['preferredLanguage'] ?? 'en',
      primaryGoal: data['primaryGoal'] ?? 'Save money',
      joinDate: data['joinDate'] != null 
          ? DateTime.parse(data['joinDate']) 
          : now,
      lastActive: data['lastActive'] != null 
          ? DateTime.parse(data['lastActive']) 
          : now,
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      profileImageUrl: data['profileImageUrl'],
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      status: 'active',
    );
  }

  /// Generate a unique ID
  static String _generateId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNum = random.nextInt(9999);
    return '${timestamp}_$randomNum';
  }

  /// Clear migration status (for testing)
  static Future<void> clearMigrationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_migrationKey);
    await prefs.remove(_migrationVersionKey);
  }

  /// Get migration status
  static Future<Map<String, dynamic>> getMigrationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'migrationCompleted': prefs.getBool(_migrationKey) ?? false,
      'migrationVersion': prefs.getInt(_migrationVersionKey) ?? 0,
      'currentVersion': _currentMigrationVersion,
      'needsMigration': await isMigrationNeeded(),
    };
  }
}

/// Result of migration operation
class MigrationResult {
  final bool success;
  final String message;
  final Map<String, int>? migratedData;

  MigrationResult({
    required this.success,
    required this.message,
    this.migratedData,
  });
}













