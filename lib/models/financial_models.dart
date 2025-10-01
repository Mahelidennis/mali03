import 'package:cloud_firestore/cloud_firestore.dart';

/// Enhanced Expense model with Firestore integration
class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;
  final String? location;
  final String? paymentMethod;
  final bool isRecurring;
  final String? recurringType; // 'daily', 'weekly', 'monthly', 'yearly'
  final String status; // 'active', 'archived', 'deleted'
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    this.location,
    this.paymentMethod,
    this.isRecurring = false,
    this.recurringType,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'note': note,
      'location': location,
      'paymentMethod': paymentMethod,
      'isRecurring': isRecurring,
      'recurringType': recurringType,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'userId': userId,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      note: json['note'],
      location: json['location'],
      paymentMethod: json['paymentMethod'],
      isRecurring: json['isRecurring'] ?? false,
      recurringType: json['recurringType'],
      status: json['status'] ?? 'active',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      userId: json['userId'] ?? '',
    );
  }

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
    String? location,
    String? paymentMethod,
    bool? isRecurring,
    String? recurringType,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      location: location ?? this.location,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringType: recurringType ?? this.recurringType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }
}

/// Income model for tracking income sources
class Income {
  final String id;
  final String title;
  final double amount;
  final String source; // 'salary', 'freelance', 'business', 'investment', 'gift', 'bonus', 'other'
  final DateTime date;
  final String? description;
  final String? category;
  final bool isRecurring;
  final String? recurringType; // 'monthly', 'weekly', 'yearly'
  final String status; // 'active', 'archived', 'deleted'
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

  Income({
    required this.id,
    required this.title,
    required this.amount,
    required this.source,
    required this.date,
    this.description,
    this.category,
    this.isRecurring = false,
    this.recurringType,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'source': source,
      'date': Timestamp.fromDate(date),
      'description': description,
      'category': category,
      'isRecurring': isRecurring,
      'recurringType': recurringType,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'userId': userId,
    };
  }

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      source: json['source'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      description: json['description'],
      category: json['category'],
      isRecurring: json['isRecurring'] ?? false,
      recurringType: json['recurringType'],
      status: json['status'] ?? 'active',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      userId: json['userId'] ?? '',
    );
  }

  Income copyWith({
    String? id,
    String? title,
    double? amount,
    String? source,
    DateTime? date,
    String? description,
    String? category,
    bool? isRecurring,
    String? recurringType,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return Income(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      source: source ?? this.source,
      date: date ?? this.date,
      description: description ?? this.description,
      category: category ?? this.category,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringType: recurringType ?? this.recurringType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }
}

/// Budget model for financial planning
class Budget {
  final String id;
  final String name;
  final String category;
  final double amount;
  final double spent;
  final DateTime startDate;
  final DateTime endDate;
  final String period; // 'monthly', 'weekly', 'yearly'
  final bool isActive;
  final String status; // 'active', 'archived', 'deleted'
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

  Budget({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    this.spent = 0.0,
    required this.startDate,
    required this.endDate,
    required this.period,
    this.isActive = true,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  double get remainingAmount => amount - spent;
  double get spentPercentage => amount > 0 ? (spent / amount) * 100 : 0;
  bool get isOverBudget => spent > amount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'amount': amount,
      'spent': spent,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'period': period,
      'isActive': isActive,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'userId': userId,
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      spent: (json['spent'] ?? 0).toDouble(),
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      period: json['period'] ?? 'monthly',
      isActive: json['isActive'] ?? true,
      status: json['status'] ?? 'active',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      userId: json['userId'] ?? '',
    );
  }

  Budget copyWith({
    String? id,
    String? name,
    String? category,
    double? amount,
    double? spent,
    DateTime? startDate,
    DateTime? endDate,
    String? period,
    bool? isActive,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      period: period ?? this.period,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }
}

/// Financial Goal model for savings targets
class FinancialGoal {
  final String id;
  final String title;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final String category; // 'emergency', 'vacation', 'house', 'car', 'education', 'other'
  final String priority; // 'low', 'medium', 'high'
  final bool isCompleted;
  final String status; // 'active', 'archived', 'deleted'
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

  FinancialGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetDate,
    required this.category,
    this.priority = 'medium',
    this.isCompleted = false,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  double get progressPercentage => targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0;
  double get remainingAmount => targetAmount - currentAmount;
  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;
  bool get isOverdue => DateTime.now().isAfter(targetDate) && !isCompleted;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': Timestamp.fromDate(targetDate),
      'category': category,
      'priority': priority,
      'isCompleted': isCompleted,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'userId': userId,
    };
  }

  factory FinancialGoal.fromJson(Map<String, dynamic> json) {
    return FinancialGoal(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      targetAmount: (json['targetAmount'] ?? 0).toDouble(),
      currentAmount: (json['currentAmount'] ?? 0).toDouble(),
      targetDate: (json['targetDate'] as Timestamp).toDate(),
      category: json['category'] ?? '',
      priority: json['priority'] ?? 'medium',
      isCompleted: json['isCompleted'] ?? false,
      status: json['status'] ?? 'active',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      userId: json['userId'] ?? '',
    );
  }

  FinancialGoal copyWith({
    String? id,
    String? title,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? category,
    String? priority,
    bool? isCompleted,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }
}

/// User Profile model with enhanced features
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String gender; // 'male', 'female', 'other'
  final double monthlyIncome;
  final String currency; // 'KES', 'USD', 'EUR'
  final List<String> interests;
  final String preferredLanguage; // 'en', 'sw', 'sh'
  final String primaryGoal;
  final DateTime joinDate;
  final DateTime lastActive;
  final bool notificationsEnabled;
  final String? profileImageUrl;
  final Map<String, dynamic> preferences;
  final String status; // 'active', 'archived', 'deleted'

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.gender,
    required this.monthlyIncome,
    this.currency = 'KES',
    required this.interests,
    required this.preferredLanguage,
    required this.primaryGoal,
    required this.joinDate,
    required this.lastActive,
    this.notificationsEnabled = true,
    this.profileImageUrl,
    this.preferences = const {},
    this.status = 'active',
  });

  String get genderPronoun => gender == 'female' ? 'sister' : 'brother';
  String get genderEmoji => gender == 'female' ? '👧' : '👦';
  String get genderGreeting => gender == 'female' ? 'Girl' : 'Bro';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'monthlyIncome': monthlyIncome,
      'currency': currency,
      'interests': interests,
      'preferredLanguage': preferredLanguage,
      'primaryGoal': primaryGoal,
      'joinDate': Timestamp.fromDate(joinDate),
      'lastActive': Timestamp.fromDate(lastActive),
      'notificationsEnabled': notificationsEnabled,
      'profileImageUrl': profileImageUrl,
      'preferences': preferences,
      'status': status,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      gender: json['gender'] ?? 'female',
      monthlyIncome: (json['monthlyIncome'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'KES',
      interests: List<String>.from(json['interests'] ?? []),
      preferredLanguage: json['preferredLanguage'] ?? 'en',
      primaryGoal: json['primaryGoal'] ?? 'Save money',
      joinDate: (json['joinDate'] as Timestamp).toDate(),
      lastActive: (json['lastActive'] as Timestamp).toDate(),
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      profileImageUrl: json['profileImageUrl'],
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      status: json['status'] ?? 'active',
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? gender,
    double? monthlyIncome,
    String? currency,
    List<String>? interests,
    String? preferredLanguage,
    String? primaryGoal,
    DateTime? joinDate,
    DateTime? lastActive,
    bool? notificationsEnabled,
    String? profileImageUrl,
    Map<String, dynamic>? preferences,
    String? status,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      currency: currency ?? this.currency,
      interests: interests ?? this.interests,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      joinDate: joinDate ?? this.joinDate,
      lastActive: lastActive ?? this.lastActive,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferences: preferences ?? this.preferences,
      status: status ?? this.status,
    );
  }
}

/// Financial Summary model for analytics
class FinancialSummary {
  final String id;
  final String userId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double totalIncome;
  final double totalExpenses;
  final double totalSavings;
  final Map<String, double> expensesByCategory;
  final Map<String, double> incomeBySource;
  final List<String> topCategories;
  final double averageDailySpending;
  final int totalTransactions;
  final DateTime lastUpdated;
  final String status; // 'active', 'archived', 'deleted'

  FinancialSummary({
    required this.id,
    required this.userId,
    required this.periodStart,
    required this.periodEnd,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalSavings,
    required this.expensesByCategory,
    required this.incomeBySource,
    required this.topCategories,
    required this.averageDailySpending,
    required this.totalTransactions,
    required this.lastUpdated,
    this.status = 'active',
  });

  double get savingsRate => totalIncome > 0 ? (totalSavings / totalIncome) * 100 : 0;
  double get expenseRate => totalIncome > 0 ? (totalExpenses / totalIncome) * 100 : 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'periodStart': Timestamp.fromDate(periodStart),
      'periodEnd': Timestamp.fromDate(periodEnd),
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'totalSavings': totalSavings,
      'expensesByCategory': expensesByCategory,
      'incomeBySource': incomeBySource,
      'topCategories': topCategories,
      'averageDailySpending': averageDailySpending,
      'totalTransactions': totalTransactions,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'status': status,
    };
  }

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    return FinancialSummary(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      periodStart: (json['periodStart'] as Timestamp).toDate(),
      periodEnd: (json['periodEnd'] as Timestamp).toDate(),
      totalIncome: (json['totalIncome'] ?? 0).toDouble(),
      totalExpenses: (json['totalExpenses'] ?? 0).toDouble(),
      totalSavings: (json['totalSavings'] ?? 0).toDouble(),
      expensesByCategory: Map<String, double>.from(json['expensesByCategory'] ?? {}),
      incomeBySource: Map<String, double>.from(json['incomeBySource'] ?? {}),
      topCategories: List<String>.from(json['topCategories'] ?? []),
      averageDailySpending: (json['averageDailySpending'] ?? 0).toDouble(),
      totalTransactions: json['totalTransactions'] ?? 0,
      lastUpdated: (json['lastUpdated'] as Timestamp).toDate(),
      status: json['status'] ?? 'active',
    );
  }
}
