# 🗄️ Database Integration Guide

This guide explains the comprehensive database integration implemented for the Mali financial assistant app.

## 📋 Overview

The database integration provides:
- **Hybrid Storage**: Local (SharedPreferences) + Cloud (Firebase Firestore)
- **Offline Support**: Works without internet connection
- **Data Synchronization**: Automatic sync when online
- **Data Validation**: Comprehensive validation and error handling
- **Analytics**: Advanced financial insights and reporting
- **Sample Data**: Easy testing with generated sample data

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   UI Layer      │    │  Service Layer   │    │  Storage Layer  │
│                 │    │                  │    │                 │
│ • Screens       │◄───┤ • DatabaseService│◄───┤ • SharedPrefs   │
│ • Widgets       │    │ • AnalyticsService│    │ • Firestore     │
│ • Dialogs       │    │ • ValidationService│   │ • Local Storage │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 📊 Data Models

### Core Models

#### 1. Expense
```dart
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
  final String? recurringType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
}
```

#### 2. Budget
```dart
class Budget {
  final String id;
  final String name;
  final String category;
  final double amount;
  final double spent;
  final DateTime startDate;
  final DateTime endDate;
  final String period;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
}
```

#### 3. FinancialGoal
```dart
class FinancialGoal {
  final String id;
  final String title;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final String category;
  final String priority;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
}
```

#### 4. UserProfile
```dart
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String gender;
  final double monthlyIncome;
  final String currency;
  final List<String> interests;
  final String preferredLanguage;
  final String primaryGoal;
  final DateTime joinDate;
  final DateTime lastActive;
  final bool notificationsEnabled;
  final String? profileImageUrl;
  final Map<String, dynamic> preferences;
}
```

## 🔧 Services

### 1. DatabaseService

Main service for all database operations:

```dart
// Add expense
await DatabaseService.addExpense(expense);

// Get expenses with filters
final expenses = await DatabaseService.getExpenses(
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime(2024, 1, 31),
  category: 'Food & Dining',
);

// Update expense
await DatabaseService.updateExpense(updatedExpense);

// Delete expense
await DatabaseService.deleteExpense(expenseId);

// Sync data
await DatabaseService.syncData();
```

### 2. AnalyticsService

Advanced financial analytics:

```dart
// Get spending summary
final summary = await AnalyticsService.getSpendingSummary(
  startDate: monthStart,
  endDate: monthEnd,
);

// Get monthly trends
final trends = await AnalyticsService.getMonthlyTrends(months: 6);

// Get category insights
final insights = await AnalyticsService.getCategoryInsights(
  startDate: monthStart,
  endDate: monthEnd,
);

// Get financial health score
final healthScore = await AnalyticsService.getFinancialHealthScore();

// Get budget performance
final performance = await AnalyticsService.getBudgetPerformance();

// Get goal insights
final goalInsights = await AnalyticsService.getGoalInsights();
```

### 3. ValidationService

Data validation and error handling:

```dart
// Validate expense
final validation = ValidationService.validateExpense(expense);
if (!validation.isValid) {
  print(validation.errorMessage);
}

// Validate budget
final budgetValidation = ValidationService.validateBudget(budget);

// Validate goal
final goalValidation = ValidationService.validateGoal(goal);

// Validate profile
final profileValidation = ValidationService.validateProfile(profile);
```

## 🚀 Usage Examples

### 1. Basic Expense Management

```dart
// Create expense
final expense = Expense(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  title: 'Lunch at restaurant',
  amount: 1500.0,
  category: 'Food & Dining',
  date: DateTime.now(),
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  userId: DatabaseService.currentUserId ?? 'anonymous',
);

// Add to database
await DatabaseService.addExpense(expense);

// Get all expenses
final expenses = await DatabaseService.getExpenses();

// Get expenses by category
final foodExpenses = await DatabaseService.getExpenses(
  category: 'Food & Dining',
);
```

### 2. Budget Management

```dart
// Create budget
final budget = Budget(
  id: 'monthly_food_budget',
  name: 'Monthly Food Budget',
  category: 'Food & Dining',
  amount: 15000.0,
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime(2024, 1, 31),
  period: 'monthly',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  userId: DatabaseService.currentUserId ?? 'anonymous',
);

// Add budget
await DatabaseService.addBudget(budget);

// Get active budgets
final budgets = await DatabaseService.getBudgets(activeOnly: true);
```

### 3. Financial Goals

```dart
// Create goal
final goal = FinancialGoal(
  id: 'emergency_fund',
  title: 'Emergency Fund',
  description: 'Build 6 months emergency fund',
  targetAmount: 300000.0,
  currentAmount: 50000.0,
  targetDate: DateTime(2024, 12, 31),
  category: 'emergency',
  priority: 'high',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  userId: DatabaseService.currentUserId ?? 'anonymous',
);

// Add goal
await DatabaseService.addGoal(goal);

// Get active goals
final goals = await DatabaseService.getGoals(activeOnly: true);
```

### 4. Analytics and Insights

```dart
// Get spending summary for current month
final now = DateTime.now();
final monthStart = DateTime(now.year, now.month, 1);
final summary = await AnalyticsService.getSpendingSummary(
  startDate: monthStart,
  endDate: now,
);

print('Total spending: KSh ${summary['totalSpending']}');
print('Daily average: KSh ${summary['averageDailySpending']}');
print('Top category: ${summary['topCategory']}');

// Get financial health score
final healthScore = await AnalyticsService.getFinancialHealthScore();
print('Financial health: ${healthScore['overallScore']}/100');

// Get recommendations
final recommendations = healthScore['recommendations'] as List<String>;
for (final rec in recommendations) {
  print('• $rec');
}
```

## 🧪 Testing

### Generate Sample Data

```dart
// Generate all sample data
await SampleDataGenerator.generateAllSampleData();

// Generate specific data
await SampleDataGenerator.generateSampleExpenses();
await SampleDataGenerator.generateSampleBudgets();
await SampleDataGenerator.generateSampleGoals();
await SampleDataGenerator.generateSampleProfile();
```

### Test Database Integration

Use the `DatabaseIntegrationTest` screen to test all functionality:

```dart
// Navigate to test screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const DatabaseIntegrationTest(),
  ),
);
```

## 🔄 Data Synchronization

### Automatic Sync

The app automatically syncs data when:
- User logs in
- App comes back online
- Manual sync is triggered

### Manual Sync

```dart
// Trigger manual sync
await DatabaseService.syncData();

// Check last sync time
final lastSync = await DatabaseService.getLastSyncTime();
print('Last sync: $lastSync');
```

### Offline Support

- Data is stored locally using SharedPreferences
- Works without internet connection
- Syncs when connection is restored
- No data loss during offline periods

## 🛡️ Security & Privacy

### Data Protection
- User data is encrypted in transit
- Local data is stored securely
- Firebase security rules protect cloud data
- No sensitive data in logs

### User Authentication
- Firebase Authentication integration
- Anonymous users supported
- User data is isolated by userId

## 📱 Platform Support

### Supported Platforms
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

### Firebase Services Used
- Cloud Firestore (Database)
- Firebase Authentication
- Firebase Storage (Optional)
- Firebase Messaging (Optional)

## 🚨 Error Handling

### Validation Errors
```dart
try {
  final validation = ValidationService.validateExpense(expense);
  if (!validation.isValid) {
    throw ValidationException(validation.errorMessage, validation.errors);
  }
} catch (e) {
  // Handle validation error
}
```

### Database Errors
```dart
try {
  await DatabaseService.addExpense(expense);
} on DatabaseException catch (e) {
  // Handle database error
  print('Database error: ${e.message}');
} catch (e) {
  // Handle other errors
  print('Unexpected error: $e');
}
```

### Sync Errors
```dart
try {
  await DatabaseService.syncData();
} on SyncException catch (e) {
  // Handle sync error
  print('Sync error: ${e.message}');
}
```

## 🔧 Configuration

### Firebase Setup

1. Add `google-services.json` to `android/app/`
2. Add `GoogleService-Info.plist` to `ios/Runner/`
3. Configure Firebase project settings

### Local Storage

No additional configuration needed. SharedPreferences is automatically configured.

## 📈 Performance

### Optimization Features
- Lazy loading of data
- Efficient queries with filters
- Local caching for fast access
- Batch operations for bulk data
- Pagination for large datasets

### Memory Management
- Automatic cleanup of old data
- Efficient data structures
- Minimal memory footprint
- Background processing

## 🐛 Troubleshooting

### Common Issues

1. **Sync not working**
   - Check internet connection
   - Verify Firebase configuration
   - Check user authentication

2. **Data not saving**
   - Check validation errors
   - Verify required fields
   - Check database permissions

3. **Performance issues**
   - Reduce data size
   - Use filters for queries
   - Enable pagination

### Debug Mode

Enable debug logging:

```dart
// Add to main.dart
import 'package:flutter/foundation.dart';

void main() {
  if (kDebugMode) {
    // Enable debug logging
  }
  runApp(MyApp());
}
```

## 📚 Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter SharedPreferences](https://pub.dev/packages/shared_preferences)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)
- [Firebase Authentication](https://firebase.google.com/docs/auth)

## 🤝 Contributing

When adding new features:

1. Update data models if needed
2. Add validation rules
3. Update database service
4. Add analytics if applicable
5. Write tests
6. Update documentation

## 📄 License

This database integration is part of the Mali financial assistant project and follows the same license terms.
