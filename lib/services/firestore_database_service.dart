import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/financial_models.dart';

/// Comprehensive Firestore Database Service with dual write support
class FirestoreDatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection names
  static const String _usersCollection = 'users';
  static const String _expensesCollection = 'expenses';
  static const String _incomeCollection = 'income';
  static const String _budgetsCollection = 'budgets';
  static const String _goalsCollection = 'goals';
  static const String _summariesCollection = 'summaries';

  // SharedPreferences keys for dual write
  static const String _expensesKey = 'user_expenses';
  static const String _incomeKey = 'user_income';
  static const String _budgetsKey = 'user_budgets';
  static const String _goalsKey = 'user_goals';
  static const String _profileKey = 'user_profile';

  /// Get current user ID
  static String? get _currentUserId => _auth.currentUser?.uid;

  /// Check if user is authenticated
  static bool get isAuthenticated => _auth.currentUser != null;

  // ==================== EXPENSES ====================

  /// Add expense to Firestore and SharedPreferences
  static Future<void> addExpense(Expense expense) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      // Add to Firestore
      await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_expensesCollection)
          .doc(expense.id)
          .set(expense.toJson());

      // Dual write to SharedPreferences
      await _addExpenseToSharedPreferences(expense);
    } catch (e) {
      throw Exception('Failed to add expense: $e');
    }
  }

  /// Get expenses from Firestore
  static Future<List<Expense>> getExpenses({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    String status = 'active',
  }) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      Query query = _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_expensesCollection)
          .where('status', isEqualTo: status);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.orderBy('date', descending: true).get();
      return snapshot.docs.map((doc) => Expense.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback to SharedPreferences
      return await _getExpensesFromSharedPreferences(category, startDate, endDate);
    }
  }

  /// Update expense in Firestore and SharedPreferences
  static Future<void> updateExpense(Expense expense) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      // Update in Firestore
      await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_expensesCollection)
          .doc(expense.id)
          .update(expense.toJson());

      // Update in SharedPreferences
      await _updateExpenseInSharedPreferences(expense);
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  /// Delete expense from Firestore and SharedPreferences
  static Future<void> deleteExpense(String expenseId) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      // Soft delete in Firestore (update status to deleted)
      await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_expensesCollection)
          .doc(expenseId)
          .update({'status': 'deleted', 'updatedAt': Timestamp.now()});

      // Remove from SharedPreferences
      await _removeExpenseFromSharedPreferences(expenseId);
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }

  /// Get expenses stream for real-time updates
  static Stream<List<Expense>> getExpensesStream({
    String? category,
    String status = 'active',
  }) {
    if (!isAuthenticated) throw Exception('User not authenticated');

    Query query = _firestore
        .collection(_usersCollection)
        .doc(_currentUserId)
        .collection(_expensesCollection)
        .where('status', isEqualTo: status);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    return query.orderBy('date', descending: true).snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Expense.fromJson(doc.data() as Map<String, dynamic>))
          .toList(),
    );
  }

  // ==================== INCOME ====================

  /// Add income to Firestore and SharedPreferences
  static Future<void> addIncome(Income income) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      // Add to Firestore
      await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_incomeCollection)
          .doc(income.id)
          .set(income.toJson());

      // Dual write to SharedPreferences
      await _addIncomeToSharedPreferences(income);
    } catch (e) {
      throw Exception('Failed to add income: $e');
    }
  }

  /// Get income from Firestore
  static Future<List<Income>> getIncome({
    String? source,
    DateTime? startDate,
    DateTime? endDate,
    String status = 'active',
  }) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      Query query = _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_incomeCollection)
          .where('status', isEqualTo: status);

      if (source != null) {
        query = query.where('source', isEqualTo: source);
      }

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.orderBy('date', descending: true).get();
      return snapshot.docs.map((doc) => Income.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback to SharedPreferences
      return await _getIncomeFromSharedPreferences(source, startDate, endDate);
    }
  }

  /// Get income stream for real-time updates
  static Stream<List<Income>> getIncomeStream({
    String? source,
    String status = 'active',
  }) {
    if (!isAuthenticated) throw Exception('User not authenticated');

    Query query = _firestore
        .collection(_usersCollection)
        .doc(_currentUserId)
        .collection(_incomeCollection)
        .where('status', isEqualTo: status);

    if (source != null) {
      query = query.where('source', isEqualTo: source);
    }

    return query.orderBy('date', descending: true).snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Income.fromJson(doc.data() as Map<String, dynamic>))
          .toList(),
    );
  }

  // ==================== BUDGETS ====================

  /// Add budget to Firestore and SharedPreferences
  static Future<void> addBudget(Budget budget) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      // Add to Firestore
      await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_budgetsCollection)
          .doc(budget.id)
          .set(budget.toJson());

      // Dual write to SharedPreferences
      await _addBudgetToSharedPreferences(budget);
    } catch (e) {
      throw Exception('Failed to add budget: $e');
    }
  }

  /// Get budgets from Firestore
  static Future<List<Budget>> getBudgets({String status = 'active'}) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_budgetsCollection)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Budget.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback to SharedPreferences
      return await _getBudgetsFromSharedPreferences();
    }
  }

  /// Get budgets stream for real-time updates
  static Stream<List<Budget>> getBudgetsStream({String status = 'active'}) {
    if (!isAuthenticated) throw Exception('User not authenticated');

    return _firestore
        .collection(_usersCollection)
        .doc(_currentUserId)
        .collection(_budgetsCollection)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Budget.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // ==================== GOALS ====================

  /// Add goal to Firestore and SharedPreferences
  static Future<void> addGoal(FinancialGoal goal) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      // Add to Firestore
      await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_goalsCollection)
          .doc(goal.id)
          .set(goal.toJson());

      // Dual write to SharedPreferences
      await _addGoalToSharedPreferences(goal);
    } catch (e) {
      throw Exception('Failed to add goal: $e');
    }
  }

  /// Get goals from Firestore
  static Future<List<FinancialGoal>> getGoals({String status = 'active'}) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_goalsCollection)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => FinancialGoal.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback to SharedPreferences
      return await _getGoalsFromSharedPreferences();
    }
  }

  /// Get goals stream for real-time updates
  static Stream<List<FinancialGoal>> getGoalsStream({String status = 'active'}) {
    if (!isAuthenticated) throw Exception('User not authenticated');

    return _firestore
        .collection(_usersCollection)
        .doc(_currentUserId)
        .collection(_goalsCollection)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FinancialGoal.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // ==================== USER PROFILE ====================

  /// Save user profile to Firestore and SharedPreferences
  static Future<void> saveUserProfile(UserProfile profile) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      // Save to Firestore
      await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection('profile')
          .doc('main')
          .set(profile.toJson());

      // Dual write to SharedPreferences
      await _saveUserProfileToSharedPreferences(profile);
    } catch (e) {
      throw Exception('Failed to save profile: $e');
    }
  }

  /// Get user profile from Firestore
  static Future<UserProfile?> getUserProfile() async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection('profile')
          .doc('main')
          .get();

      if (doc.exists) {
        return UserProfile.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      // Fallback to SharedPreferences
      return await _getUserProfileFromSharedPreferences();
    }
  }

  /// Get user profile stream for real-time updates
  static Stream<UserProfile?> getUserProfileStream() {
    if (!isAuthenticated) throw Exception('User not authenticated');

    return _firestore
        .collection(_usersCollection)
        .doc(_currentUserId)
        .collection('profile')
        .doc('main')
        .snapshots()
        .map((snapshot) => snapshot.exists
            ? UserProfile.fromJson(snapshot.data() as Map<String, dynamic>)
            : null);
  }

  // ==================== FINANCIAL SUMMARIES ====================

  /// Save financial summary to Firestore
  static Future<void> saveFinancialSummary(FinancialSummary summary) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_summariesCollection)
          .doc(summary.id)
          .set(summary.toJson());
    } catch (e) {
      throw Exception('Failed to save financial summary: $e');
    }
  }

  /// Get financial summaries from Firestore
  static Future<List<FinancialSummary>> getFinancialSummaries({
    DateTime? startDate,
    DateTime? endDate,
    String status = 'active',
  }) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      Query query = _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_summariesCollection)
          .where('status', isEqualTo: status);

      if (startDate != null) {
        query = query.where('periodStart', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('periodEnd', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.orderBy('periodStart', descending: true).get();
      return snapshot.docs.map((doc) => FinancialSummary.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to get financial summaries: $e');
    }
  }

  // ==================== MIGRATION HELPERS ====================

  /// Migrate all SharedPreferences data to Firestore
  static Future<void> migrateDataToFirestore() async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      // Migrate expenses
      final expenses = await _getExpensesFromSharedPreferences();
      for (final expense in expenses) {
        await _firestore
            .collection(_usersCollection)
            .doc(_currentUserId)
            .collection(_expensesCollection)
            .doc(expense.id)
            .set(expense.toJson());
      }

      // Migrate income
      final income = await _getIncomeFromSharedPreferences();
      for (final incomeItem in income) {
        await _firestore
            .collection(_usersCollection)
            .doc(_currentUserId)
            .collection(_incomeCollection)
            .doc(incomeItem.id)
            .set(incomeItem.toJson());
      }

      // Migrate budgets
      final budgets = await _getBudgetsFromSharedPreferences();
      for (final budget in budgets) {
        await _firestore
            .collection(_usersCollection)
            .doc(_currentUserId)
            .collection(_budgetsCollection)
            .doc(budget.id)
            .set(budget.toJson());
      }

      // Migrate goals
      final goals = await _getGoalsFromSharedPreferences();
      for (final goal in goals) {
        await _firestore
            .collection(_usersCollection)
            .doc(_currentUserId)
            .collection(_goalsCollection)
            .doc(goal.id)
            .set(goal.toJson());
      }

      // Migrate profile
      final profile = await _getUserProfileFromSharedPreferences();
      if (profile != null) {
        await _firestore
            .collection(_usersCollection)
            .doc(_currentUserId)
            .collection('profile')
            .doc('main')
            .set(profile.toJson());
      }
    } catch (e) {
      throw Exception('Failed to migrate data to Firestore: $e');
    }
  }

  /// Clear all user data from Firestore (for account deletion)
  static Future<void> deleteAllUserData() async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      final batch = _firestore.batch();

      // Delete all expenses
      final expensesSnapshot = await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_expensesCollection)
          .get();
      for (final doc in expensesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete all income
      final incomeSnapshot = await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_incomeCollection)
          .get();
      for (final doc in incomeSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete all budgets
      final budgetsSnapshot = await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_budgetsCollection)
          .get();
      for (final doc in budgetsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete all goals
      final goalsSnapshot = await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_goalsCollection)
          .get();
      for (final doc in goalsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete all summaries
      final summariesSnapshot = await _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection(_summariesCollection)
          .get();
      for (final doc in summariesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete profile
      final profileRef = _firestore
          .collection(_usersCollection)
          .doc(_currentUserId)
          .collection('profile')
          .doc('main');
      batch.delete(profileRef);

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }

  // ==================== SHAREDPREFERENCES HELPERS ====================

  static Future<void> _addExpenseToSharedPreferences(Expense expense) async {
    final prefs = await SharedPreferences.getInstance();
    final expenses = await _getExpensesFromSharedPreferences();
    expenses.add(expense);
    final expensesJson = expenses.map((e) => e.toJson()).toList();
    await prefs.setString(_expensesKey, jsonEncode(expensesJson));
  }

  static Future<List<Expense>> _getExpensesFromSharedPreferences([
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  ]) async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = prefs.getString(_expensesKey);
    if (expensesJson == null) return [];

    final List<dynamic> expensesList = jsonDecode(expensesJson);
    List<Expense> expenses = expensesList
        .map((json) => Expense.fromJson(json as Map<String, dynamic>))
        .toList();

    // Apply filters
    if (category != null) {
      expenses = expenses.where((e) => e.category == category).toList();
    }
    if (startDate != null) {
      expenses = expenses.where((e) => e.date.isAfter(startDate) || e.date.isAtSameMomentAs(startDate)).toList();
    }
    if (endDate != null) {
      expenses = expenses.where((e) => e.date.isBefore(endDate) || e.date.isAtSameMomentAs(endDate)).toList();
    }

    return expenses;
  }

  static Future<void> _updateExpenseInSharedPreferences(Expense expense) async {
    final prefs = await SharedPreferences.getInstance();
    final expenses = await _getExpensesFromSharedPreferences();
    final index = expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      expenses[index] = expense;
      final expensesJson = expenses.map((e) => e.toJson()).toList();
      await prefs.setString(_expensesKey, jsonEncode(expensesJson));
    }
  }

  static Future<void> _removeExpenseFromSharedPreferences(String expenseId) async {
    final prefs = await SharedPreferences.getInstance();
    final expenses = await _getExpensesFromSharedPreferences();
    expenses.removeWhere((e) => e.id == expenseId);
    final expensesJson = expenses.map((e) => e.toJson()).toList();
    await prefs.setString(_expensesKey, jsonEncode(expensesJson));
  }

  static Future<void> _addIncomeToSharedPreferences(Income income) async {
    final prefs = await SharedPreferences.getInstance();
    final incomeList = await _getIncomeFromSharedPreferences();
    incomeList.add(income);
    final incomeJson = incomeList.map((i) => i.toJson()).toList();
    await prefs.setString(_incomeKey, jsonEncode(incomeJson));
  }

  static Future<List<Income>> _getIncomeFromSharedPreferences([
    String? source,
    DateTime? startDate,
    DateTime? endDate,
  ]) async {
    final prefs = await SharedPreferences.getInstance();
    final incomeJson = prefs.getString(_incomeKey);
    if (incomeJson == null) return [];

    final List<dynamic> incomeList = jsonDecode(incomeJson);
    List<Income> income = incomeList
        .map((json) => Income.fromJson(json as Map<String, dynamic>))
        .toList();

    // Apply filters
    if (source != null) {
      income = income.where((i) => i.source == source).toList();
    }
    if (startDate != null) {
      income = income.where((i) => i.date.isAfter(startDate) || i.date.isAtSameMomentAs(startDate)).toList();
    }
    if (endDate != null) {
      income = income.where((i) => i.date.isBefore(endDate) || i.date.isAtSameMomentAs(endDate)).toList();
    }

    return income;
  }

  static Future<void> _addBudgetToSharedPreferences(Budget budget) async {
    final prefs = await SharedPreferences.getInstance();
    final budgets = await _getBudgetsFromSharedPreferences();
    budgets.add(budget);
    final budgetsJson = budgets.map((b) => b.toJson()).toList();
    await prefs.setString(_budgetsKey, jsonEncode(budgetsJson));
  }

  static Future<List<Budget>> _getBudgetsFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final budgetsJson = prefs.getString(_budgetsKey);
    if (budgetsJson == null) return [];

    final List<dynamic> budgetsList = jsonDecode(budgetsJson);
    return budgetsList.map((json) => Budget.fromJson(json as Map<String, dynamic>)).toList();
  }

  static Future<void> _addGoalToSharedPreferences(FinancialGoal goal) async {
    final prefs = await SharedPreferences.getInstance();
    final goals = await _getGoalsFromSharedPreferences();
    goals.add(goal);
    final goalsJson = goals.map((g) => g.toJson()).toList();
    await prefs.setString(_goalsKey, jsonEncode(goalsJson));
  }

  static Future<List<FinancialGoal>> _getGoalsFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = prefs.getString(_goalsKey);
    if (goalsJson == null) return [];

    final List<dynamic> goalsList = jsonDecode(goalsJson);
    return goalsList.map((json) => FinancialGoal.fromJson(json as Map<String, dynamic>)).toList();
  }

  static Future<void> _saveUserProfileToSharedPreferences(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  static Future<UserProfile?> _getUserProfileFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_profileKey);
    if (profileJson == null) return null;

    final Map<String, dynamic> profileData = jsonDecode(profileJson);
    return UserProfile.fromJson(profileData);
  }
}










