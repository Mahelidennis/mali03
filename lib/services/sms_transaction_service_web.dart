import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/financial_models.dart';
import '../models/transaction_model.dart';
import 'transaction_charges_service.dart';

/// Web-compatible version of SMS transaction service
/// This provides mock data for web testing since SMS APIs don't work on web
class SmsTransactionServiceWeb {
  static const String _permissionKey = 'sms_permission_granted';
  static const String _lastSyncKey = 'last_sms_sync';
  
  /// Check if SMS permission is granted (always true for web)
  static Future<bool> hasSmsPermission() async {
    return true;
  }

  /// Request SMS permission with explanation (always true for web)
  static Future<bool> requestSmsPermission() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionKey, true);
    return true;
  }

  /// Check if user has previously granted permission
  static Future<bool> hasUserConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionKey) ?? false;
  }

  /// Set user consent for SMS tracking
  static Future<void> setUserConsent(bool consent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionKey, consent);
  }

  /// Generate mock M-PESA transactions for web testing
  static Future<List<Transaction>> scanMpesaTransactions() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Generate mock transactions
    final mockTransactions = _generateMockTransactions();
    
    // Update last sync time
    await _updateLastSyncTime();
    
    return mockTransactions;
  }

  /// Generate mock M-PESA transactions for demonstration
  static List<Transaction> _generateMockTransactions() {
    final now = DateTime.now();
    final transactions = <Transaction>[];
    
    // Generate some sample transactions
    final sampleTransactions = [
      {
        'type': 'received',
        'amount': 5000.0,
        'recipient': 'JOHN DOE',
        'description': 'Received Ksh 5,000 from JOHN DOE',
        'category': 'Income',
        'daysAgo': 1,
      },
      {
        'type': 'sent',
        'amount': 1500.0,
        'recipient': 'SUPERMARKET XYZ',
        'description': 'Sent Ksh 1,500 to SUPERMARKET XYZ',
        'category': 'Shopping',
        'daysAgo': 2,
      },
      {
        'type': 'buy_goods',
        'amount': 800.0,
        'recipient': 'FUEL STATION ABC',
        'description': 'Bought goods worth Ksh 800 from FUEL STATION ABC',
        'category': 'Transportation',
        'daysAgo': 3,
      },
      {
        'type': 'pay_bill',
        'amount': 2500.0,
        'recipient': 'KPLC',
        'description': 'Paid Ksh 2,500 to KPLC',
        'category': 'Utilities',
        'daysAgo': 4,
      },
      {
        'type': 'withdraw',
        'amount': 2000.0,
        'recipient': 'ATM 12345',
        'description': 'Withdrew Ksh 2,000 from ATM 12345',
        'category': 'Cash Withdrawal',
        'daysAgo': 5,
      },
      {
        'type': 'sent',
        'amount': 300.0,
        'recipient': 'RESTAURANT DEF',
        'description': 'Sent Ksh 300 to RESTAURANT DEF',
        'category': 'Food & Dining',
        'daysAgo': 6,
      },
      {
        'type': 'received',
        'amount': 10000.0,
        'recipient': 'SALARY PAYMENT',
        'description': 'Received Ksh 10,000 from SALARY PAYMENT',
        'category': 'Income',
        'daysAgo': 7,
      },
    ];

    for (final data in sampleTransactions) {
      final transactionType = data['type'] as String;
      final amount = data['amount'] as double;
      final transactionCharge = TransactionChargesService.calculateMpesaCharge(amount, transactionType);
      final chargeDescription = TransactionChargesService.getChargeDescription(amount, transactionType);
      
      final transaction = Transaction(
        id: 'mock_${DateTime.now().millisecondsSinceEpoch}_${transactions.length}',
        type: data['type'] == 'received' ? TransactionType.income : TransactionType.expense,
        amount: amount,
        recipient: data['recipient'] as String,
        description: data['description'] as String,
        category: data['category'] as String,
        date: now.subtract(Duration(days: data['daysAgo'] as int)),
        source: 'M-PESA SMS (Mock)',
        isProcessed: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        transactionCharge: transactionCharge,
        chargeDescription: chargeDescription,
      );
      transactions.add(transaction);
    }

    return transactions;
  }

  /// Save transactions to local storage
  static Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final existingTransactions = await getStoredTransactions();
    
    // Add new transactions to existing ones
    final allTransactions = [...existingTransactions, ...transactions];
    
    // Convert to JSON and save
    final transactionsJson = allTransactions.map((t) => t.toJson()).toList();
    await prefs.setString('sms_transactions', jsonEncode(transactionsJson));
  }

  /// Get stored transactions
  static Future<List<Transaction>> getStoredTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsStr = prefs.getString('sms_transactions');
    
    if (transactionsStr == null) return [];
    
    try {
      final List<dynamic> transactionsJson = jsonDecode(transactionsStr);
      return transactionsJson.map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      print('Error parsing stored transactions: $e');
      return [];
    }
  }

  /// Clear all SMS transactions
  static Future<void> clearTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sms_transactions');
  }

  /// Get transaction statistics
  static Future<Map<String, dynamic>> getTransactionStats() async {
    final transactions = await getStoredTransactions();
    
    double totalIncome = 0;
    double totalExpenses = 0;
    Map<String, double> categoryTotals = {};
    
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else {
        totalExpenses += transaction.amount;
        categoryTotals[transaction.category] = 
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }
    }
    
    return {
      'totalTransactions': transactions.length,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'netAmount': totalIncome - totalExpenses,
      'categoryTotals': categoryTotals,
      'lastSync': await _getLastSyncTime(),
    };
  }

  /// Get last sync time
  static Future<DateTime?> _getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncStr = prefs.getString(_lastSyncKey);
    if (lastSyncStr != null) {
      return DateTime.parse(lastSyncStr);
    }
    return null;
  }

  /// Update last sync time
  static Future<void> _updateLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }
}

