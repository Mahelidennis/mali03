import '../models/financial_models.dart';

/// Service for data validation and error handling
class ValidationService {
  
  // ==================== EXPENSE VALIDATION ====================

  /// Validate expense data
  static ValidationResult validateExpense(Expense expense) {
    final errors = <String>[];

    // Required fields
    if (expense.title.trim().isEmpty) {
      errors.add('Title is required');
    } else if (expense.title.length > 100) {
      errors.add('Title must be less than 100 characters');
    }

    if (expense.amount <= 0) {
      errors.add('Amount must be greater than 0');
    } else if (expense.amount > 1000000) {
      errors.add('Amount seems too high. Please verify the amount');
    }

    if (expense.category.trim().isEmpty) {
      errors.add('Category is required');
    }

    if (expense.date.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      errors.add('Date cannot be in the future');
    }

    if (expense.date.isBefore(DateTime(2020))) {
      errors.add('Date seems too old. Please verify the date');
    }

    // Optional fields validation
    if (expense.note != null && expense.note!.length > 500) {
      errors.add('Note must be less than 500 characters');
    }

    if (expense.location != null && expense.location!.length > 100) {
      errors.add('Location must be less than 100 characters');
    }

    // Recurring validation
    if (expense.isRecurring && expense.recurringType == null) {
      errors.add('Recurring type is required for recurring expenses');
    }

    if (expense.recurringType != null && 
        !['daily', 'weekly', 'monthly', 'yearly'].contains(expense.recurringType)) {
      errors.add('Invalid recurring type');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  // ==================== BUDGET VALIDATION ====================

  /// Validate budget data
  static ValidationResult validateBudget(Budget budget) {
    final errors = <String>[];

    // Required fields
    if (budget.name.trim().isEmpty) {
      errors.add('Budget name is required');
    } else if (budget.name.length > 50) {
      errors.add('Budget name must be less than 50 characters');
    }

    if (budget.category.trim().isEmpty) {
      errors.add('Category is required');
    }

    if (budget.amount <= 0) {
      errors.add('Budget amount must be greater than 0');
    } else if (budget.amount > 10000000) {
      errors.add('Budget amount seems too high. Please verify the amount');
    }

    if (budget.startDate.isAfter(budget.endDate)) {
      errors.add('Start date cannot be after end date');
    }

    if (budget.endDate.isBefore(DateTime.now())) {
      errors.add('End date cannot be in the past');
    }

    if (budget.startDate.isBefore(DateTime(2020))) {
      errors.add('Start date seems too old. Please verify the date');
    }

    // Period validation
    if (!['monthly', 'weekly', 'yearly'].contains(budget.period)) {
      errors.add('Invalid budget period');
    }

    // Spent amount validation
    if (budget.spent < 0) {
      errors.add('Spent amount cannot be negative');
    }

    if (budget.spent > budget.amount * 2) {
      errors.add('Spent amount seems too high compared to budget');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  // ==================== GOAL VALIDATION ====================

  /// Validate financial goal data
  static ValidationResult validateGoal(FinancialGoal goal) {
    final errors = <String>[];

    // Required fields
    if (goal.title.trim().isEmpty) {
      errors.add('Goal title is required');
    } else if (goal.title.length > 100) {
      errors.add('Goal title must be less than 100 characters');
    }

    if (goal.description.trim().isEmpty) {
      errors.add('Goal description is required');
    } else if (goal.description.length > 500) {
      errors.add('Goal description must be less than 500 characters');
    }

    if (goal.targetAmount <= 0) {
      errors.add('Target amount must be greater than 0');
    } else if (goal.targetAmount > 100000000) {
      errors.add('Target amount seems too high. Please verify the amount');
    }

    if (goal.currentAmount < 0) {
      errors.add('Current amount cannot be negative');
    }

    if (goal.currentAmount > goal.targetAmount) {
      errors.add('Current amount cannot exceed target amount');
    }

    if (goal.targetDate.isBefore(DateTime.now())) {
      errors.add('Target date cannot be in the past');
    }

    if (goal.targetDate.isBefore(DateTime.now().add(const Duration(days: 30)))) {
      errors.add('Target date should be at least 30 days from now');
    }

    if (goal.targetDate.isAfter(DateTime.now().add(const Duration(days: 3650)))) {
      errors.add('Target date cannot be more than 10 years in the future');
    }

    // Category validation
    if (goal.category.trim().isEmpty) {
      errors.add('Goal category is required');
    }

    if (!['emergency', 'vacation', 'house', 'car', 'education', 'other'].contains(goal.category)) {
      errors.add('Invalid goal category');
    }

    // Priority validation
    if (!['low', 'medium', 'high'].contains(goal.priority)) {
      errors.add('Invalid priority level');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  // ==================== PROFILE VALIDATION ====================

  /// Validate user profile data
  static ValidationResult validateProfile(UserProfile profile) {
    final errors = <String>[];

    // Required fields
    if (profile.name.trim().isEmpty) {
      errors.add('Name is required');
    } else if (profile.name.length < 2) {
      errors.add('Name must be at least 2 characters');
    } else if (profile.name.length > 50) {
      errors.add('Name must be less than 50 characters');
    }

    if (profile.email.trim().isEmpty) {
      errors.add('Email is required');
    } else if (!_isValidEmail(profile.email)) {
      errors.add('Invalid email format');
    }

    if (profile.gender.trim().isEmpty) {
      errors.add('Gender is required');
    } else if (!['male', 'female', 'other'].contains(profile.gender)) {
      errors.add('Invalid gender selection');
    }

    if (profile.monthlyIncome <= 0) {
      errors.add('Monthly income must be greater than 0');
    } else if (profile.monthlyIncome > 10000000) {
      errors.add('Monthly income seems too high. Please verify the amount');
    }

    if (profile.currency.trim().isEmpty) {
      errors.add('Currency is required');
    } else if (profile.currency.length != 3) {
      errors.add('Currency must be a 3-letter code (e.g., KES, USD)');
    }

    if (profile.preferredLanguage.trim().isEmpty) {
      errors.add('Preferred language is required');
    } else if (!['en', 'sw', 'sh'].contains(profile.preferredLanguage)) {
      errors.add('Invalid language selection');
    }

    if (profile.primaryGoal.trim().isEmpty) {
      errors.add('Primary goal is required');
    } else if (profile.primaryGoal.length > 100) {
      errors.add('Primary goal must be less than 100 characters');
    }

    // Optional fields validation
    if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty) {
      if (!_isValidPhoneNumber(profile.phoneNumber!)) {
        errors.add('Invalid phone number format');
      }
    }

    if (profile.interests.length > 10) {
      errors.add('Too many interests selected. Please select up to 10');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  // ==================== HELPER METHODS ====================

  /// Validate email format
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  /// Validate phone number format (basic validation)
  static bool _isValidPhoneNumber(String phone) {
    // Remove all non-digit characters
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it's between 7 and 15 digits (international standard)
    return digitsOnly.length >= 7 && digitsOnly.length <= 15;
  }

  /// Sanitize string input
  static String sanitizeString(String input) {
    return input.trim().replaceAll('<', '').replaceAll('>', '').replaceAll('"', '').replaceAll('\'', '');
  }

  /// Validate amount input
  static double? parseAmount(String input) {
    try {
      final cleaned = input.replaceAll(RegExp(r'[^\d.,]'), '');
      if (cleaned.isEmpty) return null;
      
      // Handle different decimal separators
      final normalized = cleaned.replaceAll(',', '.');
      final amount = double.parse(normalized);
      
      return amount > 0 ? amount : null;
    } catch (e) {
      return null;
    }
  }

  /// Validate date input
  static DateTime? parseDate(String input) {
    try {
      final date = DateTime.parse(input);
      return date;
    } catch (e) {
      return null;
    }
  }

  // ==================== BUSINESS RULES VALIDATION ====================

  /// Check if expense is suspicious (potential duplicate)
  static Future<bool> isSuspiciousExpense(Expense expense) async {
    // This would typically check against recent expenses
    // For now, return false as a placeholder
    return false;
  }

  /// Check if budget is realistic
  static bool isRealisticBudget(Budget budget) {
    final days = budget.endDate.difference(budget.startDate).inDays;
    final dailyBudget = budget.amount / days;
    
    // Flag if daily budget is less than 100 or more than 10000
    return dailyBudget >= 100 && dailyBudget <= 10000;
  }

  /// Check if goal is achievable
  static bool isAchievableGoal(FinancialGoal goal) {
    final days = goal.targetDate.difference(DateTime.now()).inDays;
    final remainingAmount = goal.targetAmount - goal.currentAmount;
    final dailyRequired = remainingAmount / days;
    
    // Flag if daily required saving is more than 10000
    return dailyRequired <= 10000;
  }
}

/// Result class for validation
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  ValidationResult({
    required this.isValid,
    required this.errors,
    this.warnings = const [],
  });

  String get errorMessage => errors.join(', ');
  String get warningMessage => warnings.join(', ');
  
  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
}

/// Custom exceptions for database operations
class DatabaseException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  DatabaseException(this.message, {this.code, this.details});

  @override
  String toString() => 'DatabaseException: $message';
}

class ValidationException implements Exception {
  final String message;
  final List<String> errors;

  ValidationException(this.message, this.errors);

  @override
  String toString() => 'ValidationException: $message';
}

class SyncException implements Exception {
  final String message;
  final String? operation;

  SyncException(this.message, {this.operation});

  @override
  String toString() => 'SyncException: $message';
}
