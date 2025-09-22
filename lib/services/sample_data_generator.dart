import 'dart:math';
import '../models/financial_models.dart';
import 'database_service.dart';

/// Service for generating sample data for testing
class SampleDataGenerator {
  static final Random _random = Random();
  
  static const List<String> _expenseCategories = [
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

  static const List<String> _expenseTitles = {
    'Food & Dining': [
      'Lunch at restaurant',
      'Grocery shopping',
      'Dinner with friends',
      'Fast food',
      'Coffee break',
      'Street food',
      'Cooking ingredients',
      'Takeaway',
    ],
    'Transport': [
      'Uber ride',
      'Matatu fare',
      'Petrol',
      'Bus ticket',
      'Taxi fare',
      'Boda boda',
      'Parking fee',
      'Car maintenance',
    ],
    'Shopping': [
      'Clothes shopping',
      'Electronics',
      'Online purchase',
      'Market shopping',
      'Pharmacy',
      'Bookstore',
      'Gift shopping',
      'Household items',
    ],
    'Bills & Utilities': [
      'Electricity bill',
      'Water bill',
      'Internet subscription',
      'Phone bill',
      'Rent',
      'Insurance',
      'Bank charges',
      'Service fee',
    ],
    'Entertainment': [
      'Movie ticket',
      'Netflix subscription',
      'Concert ticket',
      'Gaming',
      'Sports event',
      'Club entry',
      'Streaming service',
      'Hobby supplies',
    ],
    'Healthcare': [
      'Doctor visit',
      'Medicine',
      'Lab test',
      'Dental checkup',
      'Eye exam',
      'Pharmacy',
      'Health insurance',
      'Medical supplies',
    ],
    'Education': [
      'Course fee',
      'Books',
      'School supplies',
      'Online course',
      'Workshop',
      'Training',
      'Certification',
      'Educational app',
    ],
    'Coffee': [
      'Morning coffee',
      'Coffee shop',
      'Espresso',
      'Cappuccino',
      'Latte',
      'Coffee beans',
      'Coffee break',
      'Specialty coffee',
    ],
    'Other': [
      'Miscellaneous',
      'Unexpected expense',
      'Emergency',
      'Donation',
      'Tip',
      'Service charge',
      'Fee',
      'Other',
    ],
  };

  static const List<String> _paymentMethods = [
    'Cash',
    'Card',
    'Mobile Money',
    'Bank Transfer',
    'Other',
  ];

  static const List<String> _goalCategories = [
    'emergency',
    'vacation',
    'house',
    'car',
    'education',
    'other',
  ];

  static const List<String> _goalTitles = {
    'emergency': [
      'Emergency Fund',
      'Rainy Day Fund',
      'Safety Net',
      'Crisis Fund',
    ],
    'vacation': [
      'Beach Holiday',
      'Safari Trip',
      'International Travel',
      'Weekend Getaway',
      'Adventure Trip',
    ],
    'house': [
      'House Deposit',
      'Home Renovation',
      'Furniture',
      'New Home',
      'Property Investment',
    ],
    'car': [
      'New Car',
      'Car Upgrade',
      'Vehicle Maintenance',
      'Car Insurance',
      'Driving Lessons',
    ],
    'education': [
      'University Fees',
      'Professional Course',
      'Certification',
      'Skills Training',
      'Online Learning',
    ],
    'other': [
      'Wedding',
      'Gadget Purchase',
      'Business Investment',
      'Retirement Fund',
      'Personal Project',
    ],
  };

  /// Generate sample expenses for the last 3 months
  static Future<void> generateSampleExpenses() async {
    final now = DateTime.now();
    final expenses = <Expense>[];

    // Generate expenses for the last 3 months
    for (int monthOffset = 2; monthOffset >= 0; monthOffset--) {
      final month = DateTime(now.year, now.month - monthOffset, 1);
      final monthEnd = DateTime(now.year, now.month - monthOffset + 1, 0);
      
      // Generate 15-25 expenses per month
      final expenseCount = 15 + _random.nextInt(11);
      
      for (int i = 0; i < expenseCount; i++) {
        final category = _expenseCategories[_random.nextInt(_expenseCategories.length)];
        final titles = _expenseTitles[category]!;
        final title = titles[_random.nextInt(titles.length)];
        
        final expense = Expense(
          id: '${DateTime.now().millisecondsSinceEpoch}_${i}_$monthOffset',
          title: title,
          amount: _generateExpenseAmount(category),
          category: category,
          date: _generateRandomDateInMonth(month, monthEnd),
          note: _random.nextBool() ? _generateRandomNote() : null,
          location: _random.nextBool() ? _generateRandomLocation() : null,
          paymentMethod: _paymentMethods[_random.nextInt(_paymentMethods.length)],
          isRecurring: _random.nextDouble() < 0.1, // 10% chance
          recurringType: _random.nextDouble() < 0.1 ? 'monthly' : null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userId: DatabaseService.currentUserId ?? 'sample_user',
        );
        
        expenses.add(expense);
      }
    }

    // Add expenses to database
    for (final expense in expenses) {
      try {
        await DatabaseService.addExpense(expense);
      } catch (e) {
        print('Error adding sample expense: $e');
      }
    }

    print('Generated ${expenses.length} sample expenses');
  }

  /// Generate sample budgets
  static Future<void> generateSampleBudgets() async {
    final budgets = <Budget>[];
    final now = DateTime.now();

    // Generate budgets for different categories
    for (final category in _expenseCategories.take(5)) {
      final budget = Budget(
        id: 'budget_${category.toLowerCase().replaceAll(' ', '_')}',
        name: '$category Budget',
        category: category,
        amount: _generateBudgetAmount(category),
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0),
        period: 'monthly',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: DatabaseService.currentUserId ?? 'sample_user',
      );
      
      budgets.add(budget);
    }

    // Add budgets to database
    for (final budget in budgets) {
      try {
        await DatabaseService.addBudget(budget);
      } catch (e) {
        print('Error adding sample budget: $e');
      }
    }

    print('Generated ${budgets.length} sample budgets');
  }

  /// Generate sample financial goals
  static Future<void> generateSampleGoals() async {
    final goals = <FinancialGoal>[];
    final now = DateTime.now();

    // Generate 3-5 goals
    final goalCount = 3 + _random.nextInt(3);
    
    for (int i = 0; i < goalCount; i++) {
      final category = _goalCategories[_random.nextInt(_goalCategories.length)];
      final titles = _goalTitles[category]!;
      final title = titles[_random.nextInt(titles.length)];
      
      final targetAmount = _generateGoalAmount(category);
      final targetDate = DateTime.now().add(Duration(days: 30 + _random.nextInt(300)));
      
      final goal = FinancialGoal(
        id: 'goal_${i}_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: _generateGoalDescription(category, title),
        targetAmount: targetAmount,
        currentAmount: _random.nextDouble() * targetAmount * 0.3, // 0-30% progress
        targetDate: targetDate,
        category: category,
        priority: ['low', 'medium', 'high'][_random.nextInt(3)],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: DatabaseService.currentUserId ?? 'sample_user',
      );
      
      goals.add(goal);
    }

    // Add goals to database
    for (final goal in goals) {
      try {
        await DatabaseService.addGoal(goal);
      } catch (e) {
        print('Error adding sample goal: $e');
      }
    }

    print('Generated ${goals.length} sample goals');
  }

  /// Generate sample user profile
  static Future<void> generateSampleProfile() async {
    final profile = UserProfile(
      id: DatabaseService.currentUserId ?? 'sample_user',
      name: _generateRandomName(),
      email: _generateRandomEmail(),
      phoneNumber: _generateRandomPhoneNumber(),
      gender: ['male', 'female'][_random.nextInt(2)],
      monthlyIncome: 30000 + _random.nextInt(70000), // 30k-100k
      currency: 'KES',
      interests: _generateRandomInterests(),
      preferredLanguage: ['en', 'sw', 'sh'][_random.nextInt(3)],
      primaryGoal: _generateRandomPrimaryGoal(),
      joinDate: DateTime.now().subtract(Duration(days: _random.nextInt(365))),
      lastActive: DateTime.now(),
      notificationsEnabled: true,
      preferences: {
        'theme': 'light',
        'currency_display': 'KES',
        'notifications': true,
        'biometric_auth': false,
      },
    );

    try {
      await DatabaseService.saveProfile(profile);
      print('Generated sample user profile');
    } catch (e) {
      print('Error adding sample profile: $e');
    }
  }

  /// Generate all sample data
  static Future<void> generateAllSampleData() async {
    print('Generating sample data...');
    
    await generateSampleProfile();
    await generateSampleExpenses();
    await generateSampleBudgets();
    await generateSampleGoals();
    
    print('Sample data generation completed!');
  }

  // ==================== HELPER METHODS ====================

  static double _generateExpenseAmount(String category) {
    // Different amount ranges for different categories
    final ranges = {
      'Food & Dining': [50, 2000],
      'Transport': [20, 500],
      'Shopping': [100, 10000],
      'Bills & Utilities': [500, 5000],
      'Entertainment': [100, 3000],
      'Healthcare': [200, 5000],
      'Education': [500, 20000],
      'Coffee': [50, 500],
      'Other': [50, 1000],
    };

    final range = ranges[category] ?? [50, 1000];
    return range[0] + _random.nextDouble() * (range[1] - range[0]);
  }

  static double _generateBudgetAmount(String category) {
    final baseAmount = _generateExpenseAmount(category) * 10; // 10x average expense
    return baseAmount + _random.nextDouble() * baseAmount;
  }

  static double _generateGoalAmount(String category) {
    final ranges = {
      'emergency': [50000, 500000],
      'vacation': [20000, 200000],
      'house': [500000, 10000000],
      'car': [300000, 3000000],
      'education': [10000, 500000],
      'other': [10000, 1000000],
    };

    final range = ranges[category] ?? [10000, 100000];
    return range[0] + _random.nextDouble() * (range[1] - range[0]);
  }

  static DateTime _generateRandomDateInMonth(DateTime monthStart, DateTime monthEnd) {
    final daysInMonth = monthEnd.day;
    final randomDay = 1 + _random.nextInt(daysInMonth);
    return DateTime(monthStart.year, monthStart.month, randomDay);
  }

  static String _generateRandomNote() {
    final notes = [
      'Quick purchase',
      'Needed this urgently',
      'Good deal',
      'Regular expense',
      'Unexpected cost',
      'Worth it',
      'Last minute',
      'Bargain',
    ];
    return notes[_random.nextInt(notes.length)];
  }

  static String _generateRandomLocation() {
    final locations = [
      'Nairobi CBD',
      'Westlands',
      'Karen',
      'Runda',
      'Kilimani',
      'Kileleshwa',
      'Lavington',
      'Online',
      'Mombasa',
      'Kisumu',
    ];
    return locations[_random.nextInt(locations.length)];
  }

  static String _generateRandomName() {
    final names = [
      'Grace Wanjiku',
      'John Mwangi',
      'Mary Akinyi',
      'Peter Kamau',
      'Jane Wanjala',
      'David Otieno',
      'Sarah Muthoni',
      'James Kiprop',
      'Faith Njeri',
      'Michael Ochieng',
    ];
    return names[_random.nextInt(names.length)];
  }

  static String _generateRandomEmail() {
    final domains = ['gmail.com', 'yahoo.com', 'outlook.com', 'hotmail.com'];
    final name = _generateRandomName().toLowerCase().replaceAll(' ', '.');
    final domain = domains[_random.nextInt(domains.length)];
    return '$name@$domain';
  }

  static String _generateRandomPhoneNumber() {
    final prefixes = ['070', '071', '072', '073', '074', '075', '076', '077', '078', '079'];
    final prefix = prefixes[_random.nextInt(prefixes.length)];
    final number = _random.nextInt(10000000).toString().padLeft(7, '0');
    return '+254$prefix$number';
  }

  static List<String> _generateRandomInterests() {
    final allInterests = [
      'Technology',
      'Finance',
      'Health',
      'Education',
      'Travel',
      'Food',
      'Sports',
      'Music',
      'Art',
      'Fashion',
    ];
    
    final count = 3 + _random.nextInt(4); // 3-6 interests
    final shuffled = List.from(allInterests)..shuffle();
    return shuffled.take(count).toList();
  }

  static String _generateRandomPrimaryGoal() {
    final goals = [
      'Save money',
      'Build emergency fund',
      'Buy a house',
      'Start a business',
      'Travel the world',
      'Pay off debt',
      'Invest for retirement',
      'Get financial freedom',
    ];
    return goals[_random.nextInt(goals.length)];
  }

  static String _generateGoalDescription(String category, String title) {
    final descriptions = {
      'emergency': 'Building a safety net for unexpected expenses and emergencies',
      'vacation': 'Saving up for a well-deserved break and travel experience',
      'house': 'Working towards homeownership and property investment',
      'car': 'Saving for vehicle purchase or upgrade',
      'education': 'Investing in personal development and learning',
      'other': 'Working towards a personal goal or milestone',
    };
    
    return descriptions[category] ?? 'Working towards achieving this important goal';
  }
}
