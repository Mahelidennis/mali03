import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/financial_models.dart';

/// Main database service that handles both local and cloud storage
class DatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collection names
  static const String _expensesCollection = 'expenses';
  static const String _budgetsCollection = 'budgets';
  static const String _goalsCollection = 'goals';
  static const String _profilesCollection = 'profiles';
  static const String _summariesCollection = 'summaries';

  // Local storage keys
  static const String _localExpensesKey = 'local_expenses';
  static const String _localBudgetsKey = 'local_budgets';
  static const String _localGoalsKey = 'local_goals';
  static const String _localProfileKey = 'local_profile';
  static const String _lastSyncKey = 'last_sync_timestamp';

  /// Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is authenticated
  static bool get isAuthenticated => _auth.currentUser != null;

  /// Get current user email
  static String? get currentUserEmail => _auth.currentUser?.email;

  // ==================== EXPENSE OPERATIONS ====================

  /// Add expense to both local and cloud storage
  static Future<void> addExpense(Expense expense) async {
    try {
      // Add to local storage first for immediate UI update
      await _addExpenseLocally(expense);
      
      // Add to Firestore if authenticated
      if (isAuthenticated) {
        await _firestore
            .collection(_expensesCollection)
            .doc(expense.id)
            .set(expense.toJson());
      }
    } catch (e) {
      print('Error adding expense: $e');
      rethrow;
    }
  }

  /// Get expenses with local fallback
  static Future<List<Expense>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) async {
    try {
      List<Expense> expenses = [];

      if (isAuthenticated) {
        // Try to get from Firestore first
        Query query = _firestore.collection(_expensesCollection);
        
        if (currentUserId != null) {
          query = query.where('userId', isEqualTo: currentUserId);
        }
        
        if (startDate != null) {
          query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
        }
        
        if (endDate != null) {
          query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
        }
        
        if (category != null) {
          query = query.where('category', isEqualTo: category);
        }

        final snapshot = await query.orderBy('date', descending: true).get();
        expenses = snapshot.docs
            .map((doc) => Expense.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      }

      // If no cloud data or not authenticated, get from local storage
      if (expenses.isEmpty) {
        expenses = await _getExpensesLocally();
        
        // Apply filters to local data
        if (startDate != null) {
          expenses = expenses.where((e) => e.date.isAfter(startDate)).toList();
        }
        if (endDate != null) {
          expenses = expenses.where((e) => e.date.isBefore(endDate)).toList();
        }
        if (category != null) {
          expenses = expenses.where((e) => e.category == category).toList();
        }
      }

      return expenses;
    } catch (e) {
      print('Error getting expenses: $e');
      // Fallback to local storage
      return await _getExpensesLocally();
    }
  }

  /// Update expense
  static Future<void> updateExpense(Expense expense) async {
    try {
      // Update local storage
      await _updateExpenseLocally(expense);
      
      // Update Firestore if authenticated
      if (isAuthenticated) {
        await _firestore
            .collection(_expensesCollection)
            .doc(expense.id)
            .update(expense.toJson());
      }
    } catch (e) {
      print('Error updating expense: $e');
      rethrow;
    }
  }

  /// Delete expense
  static Future<void> deleteExpense(String expenseId) async {
    try {
      // Delete from local storage
      await _deleteExpenseLocally(expenseId);
      
      // Delete from Firestore if authenticated
      if (isAuthenticated) {
        await _firestore
            .collection(_expensesCollection)
            .doc(expenseId)
            .delete();
      }
    } catch (e) {
      print('Error deleting expense: $e');
      rethrow;
    }
  }

  // ==================== BUDGET OPERATIONS ====================

  /// Add budget
  static Future<void> addBudget(Budget budget) async {
    try {
      await _addBudgetLocally(budget);
      
      if (isAuthenticated) {
        await _firestore
            .collection(_budgetsCollection)
            .doc(budget.id)
            .set(budget.toJson());
      }
    } catch (e) {
      print('Error adding budget: $e');
      rethrow;
    }
  }

  /// Get budgets
  static Future<List<Budget>> getBudgets({bool activeOnly = true}) async {
    try {
      List<Budget> budgets = [];

      if (isAuthenticated) {
        Query query = _firestore.collection(_budgetsCollection);
        
        if (currentUserId != null) {
          query = query.where('userId', isEqualTo: currentUserId);
        }
        
        if (activeOnly) {
          query = query.where('isActive', isEqualTo: true);
        }

        final snapshot = await query.orderBy('createdAt', descending: true).get();
        budgets = snapshot.docs
            .map((doc) => Budget.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      }

      if (budgets.isEmpty) {
        budgets = await _getBudgetsLocally();
        if (activeOnly) {
          budgets = budgets.where((b) => b.isActive).toList();
        }
      }

      return budgets;
    } catch (e) {
      print('Error getting budgets: $e');
      return await _getBudgetsLocally();
    }
  }

  /// Update budget
  static Future<void> updateBudget(Budget budget) async {
    try {
      await _updateBudgetLocally(budget);
      
      if (isAuthenticated) {
        await _firestore
            .collection(_budgetsCollection)
            .doc(budget.id)
            .update(budget.toJson());
      }
    } catch (e) {
      print('Error updating budget: $e');
      rethrow;
    }
  }

  // ==================== GOAL OPERATIONS ====================

  /// Add financial goal
  static Future<void> addGoal(FinancialGoal goal) async {
    try {
      await _addGoalLocally(goal);
      
      if (isAuthenticated) {
        await _firestore
            .collection(_goalsCollection)
            .doc(goal.id)
            .set(goal.toJson());
      }
    } catch (e) {
      print('Error adding goal: $e');
      rethrow;
    }
  }

  /// Get financial goals
  static Future<List<FinancialGoal>> getGoals({bool activeOnly = true}) async {
    try {
      List<FinancialGoal> goals = [];

      if (isAuthenticated) {
        Query query = _firestore.collection(_goalsCollection);
        
        if (currentUserId != null) {
          query = query.where('userId', isEqualTo: currentUserId);
        }
        
        if (activeOnly) {
          query = query.where('isCompleted', isEqualTo: false);
        }

        final snapshot = await query.orderBy('priority', descending: true).get();
        goals = snapshot.docs
            .map((doc) => FinancialGoal.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      }

      if (goals.isEmpty) {
        goals = await _getGoalsLocally();
        if (activeOnly) {
          goals = goals.where((g) => !g.isCompleted).toList();
        }
      }

      return goals;
    } catch (e) {
      print('Error getting goals: $e');
      return await _getGoalsLocally();
    }
  }

  /// Update financial goal
  static Future<void> updateGoal(FinancialGoal goal) async {
    try {
      await _updateGoalLocally(goal);
      
      if (isAuthenticated) {
        await _firestore
            .collection(_goalsCollection)
            .doc(goal.id)
            .update(goal.toJson());
      }
    } catch (e) {
      print('Error updating goal: $e');
      rethrow;
    }
  }

  // ==================== PROFILE OPERATIONS ====================

  /// Save user profile
  static Future<void> saveProfile(UserProfile profile) async {
    try {
      await _saveProfileLocally(profile);
      
      if (isAuthenticated) {
        await _firestore
            .collection(_profilesCollection)
            .doc(profile.id)
            .set(profile.toJson());
      }
    } catch (e) {
      print('Error saving profile: $e');
      rethrow;
    }
  }

  /// Get user profile
  static Future<UserProfile?> getProfile() async {
    try {
      if (isAuthenticated && currentUserId != null) {
        final doc = await _firestore
            .collection(_profilesCollection)
            .doc(currentUserId)
            .get();
        
        if (doc.exists) {
          return UserProfile.fromJson(doc.data()!);
        }
      }

      // Fallback to local storage
      return await _getProfileLocally();
    } catch (e) {
      print('Error getting profile: $e');
      return await _getProfileLocally();
    }
  }

  // ==================== SYNC OPERATIONS ====================

  /// Sync local data with Firestore
  static Future<void> syncData() async {
    if (!isAuthenticated) return;

    try {
      // Sync expenses
      await _syncExpenses();
      
      // Sync budgets
      await _syncBudgets();
      
      // Sync goals
      await _syncGoals();
      
      // Update last sync timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
      
    } catch (e) {
      print('Error syncing data: $e');
    }
  }

  /// Get last sync timestamp
  static Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getString(_lastSyncKey);
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  // ==================== LOCAL STORAGE METHODS ====================

  static Future<void> _addExpenseLocally(Expense expense) async {
    final prefs = await SharedPreferences.getInstance();
    final expenses = await _getExpensesLocally();
    expenses.add(expense);
    
    final expensesJson = expenses.map((e) => e.toJson()).toList();
    await prefs.setString(_localExpensesKey, jsonEncode(expensesJson));
  }

  static Future<List<Expense>> _getExpensesLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesString = prefs.getString(_localExpensesKey);
    
    if (expensesString == null) return [];
    
    final expensesJson = jsonDecode(expensesString) as List;
    return expensesJson.map((json) => Expense.fromJson(json)).toList();
  }

  static Future<void> _updateExpenseLocally(Expense expense) async {
    final prefs = await SharedPreferences.getInstance();
    final expenses = await _getExpensesLocally();
    final index = expenses.indexWhere((e) => e.id == expense.id);
    
    if (index != -1) {
      expenses[index] = expense;
      final expensesJson = expenses.map((e) => e.toJson()).toList();
      await prefs.setString(_localExpensesKey, jsonEncode(expensesJson));
    }
  }

  static Future<void> _deleteExpenseLocally(String expenseId) async {
    final prefs = await SharedPreferences.getInstance();
    final expenses = await _getExpensesLocally();
    expenses.removeWhere((e) => e.id == expenseId);
    
    final expensesJson = expenses.map((e) => e.toJson()).toList();
    await prefs.setString(_localExpensesKey, jsonEncode(expensesJson));
  }

  static Future<void> _addBudgetLocally(Budget budget) async {
    final prefs = await SharedPreferences.getInstance();
    final budgets = await _getBudgetsLocally();
    budgets.add(budget);
    
    final budgetsJson = budgets.map((b) => b.toJson()).toList();
    await prefs.setString(_localBudgetsKey, jsonEncode(budgetsJson));
  }

  static Future<List<Budget>> _getBudgetsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final budgetsString = prefs.getString(_localBudgetsKey);
    
    if (budgetsString == null) return [];
    
    final budgetsJson = jsonDecode(budgetsString) as List;
    return budgetsJson.map((json) => Budget.fromJson(json)).toList();
  }

  static Future<void> _updateBudgetLocally(Budget budget) async {
    final prefs = await SharedPreferences.getInstance();
    final budgets = await _getBudgetsLocally();
    final index = budgets.indexWhere((b) => b.id == budget.id);
    
    if (index != -1) {
      budgets[index] = budget;
      final budgetsJson = budgets.map((b) => b.toJson()).toList();
      await prefs.setString(_localBudgetsKey, jsonEncode(budgetsJson));
    }
  }

  static Future<void> _addGoalLocally(FinancialGoal goal) async {
    final prefs = await SharedPreferences.getInstance();
    final goals = await _getGoalsLocally();
    goals.add(goal);
    
    final goalsJson = goals.map((g) => g.toJson()).toList();
    await prefs.setString(_localGoalsKey, jsonEncode(goalsJson));
  }

  static Future<List<FinancialGoal>> _getGoalsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsString = prefs.getString(_localGoalsKey);
    
    if (goalsString == null) return [];
    
    final goalsJson = jsonDecode(goalsString) as List;
    return goalsJson.map((json) => FinancialGoal.fromJson(json)).toList();
  }

  static Future<void> _updateGoalLocally(FinancialGoal goal) async {
    final prefs = await SharedPreferences.getInstance();
    final goals = await _getGoalsLocally();
    final index = goals.indexWhere((g) => g.id == goal.id);
    
    if (index != -1) {
      goals[index] = goal;
      final goalsJson = goals.map((g) => g.toJson()).toList();
      await prefs.setString(_localGoalsKey, jsonEncode(goalsJson));
    }
  }

  static Future<void> _saveProfileLocally(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localProfileKey, jsonEncode(profile.toJson()));
  }

  static Future<UserProfile?> _getProfileLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final profileString = prefs.getString(_localProfileKey);
    
    if (profileString == null) return null;
    
    final profileJson = jsonDecode(profileString) as Map<String, dynamic>;
    return UserProfile.fromJson(profileJson);
  }

  // ==================== SYNC METHODS ====================

  static Future<void> _syncExpenses() async {
    final localExpenses = await _getExpensesLocally();
    
    for (final expense in localExpenses) {
      try {
        await _firestore
            .collection(_expensesCollection)
            .doc(expense.id)
            .set(expense.toJson(), SetOptions(merge: true));
      } catch (e) {
        print('Error syncing expense ${expense.id}: $e');
      }
    }
  }

  static Future<void> _syncBudgets() async {
    final localBudgets = await _getBudgetsLocally();
    
    for (final budget in localBudgets) {
      try {
        await _firestore
            .collection(_budgetsCollection)
            .doc(budget.id)
            .set(budget.toJson(), SetOptions(merge: true));
      } catch (e) {
        print('Error syncing budget ${budget.id}: $e');
      }
    }
  }

  static Future<void> _syncGoals() async {
    final localGoals = await _getGoalsLocally();
    
    for (final goal in localGoals) {
      try {
        await _firestore
            .collection(_goalsCollection)
            .doc(goal.id)
            .set(goal.toJson(), SetOptions(merge: true));
      } catch (e) {
        print('Error syncing goal ${goal.id}: $e');
      }
    }
  }
}
