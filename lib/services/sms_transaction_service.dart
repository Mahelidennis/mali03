import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_advanced/sms_advanced.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/financial_models.dart';
import '../models/transaction_model.dart';

/// Service to handle SMS-based transaction tracking
class SmsTransactionService {
  static const String _permissionKey = 'sms_permission_granted';
  static const String _lastSyncKey = 'last_sms_sync';
  static const String _mpesaSender = 'MPESA';
  
  // M-PESA SMS patterns
  static final Map<String, RegExp> _mpesaPatterns = {
    'received': RegExp(r'You have received Ksh([0-9,]+\.?[0-9]*) from ([A-Z0-9\s]+) on (\d{1,2}/\d{1,2}/\d{4}) at (\d{1,2}:\d{2} [AP]M)'),
    'sent': RegExp(r'You sent Ksh([0-9,]+\.?[0-9]*) to ([A-Z0-9\s]+) on (\d{1,2}/\d{1,2}/\d{4}) at (\d{1,2}:\d{2} [AP]M)'),
    'withdraw': RegExp(r'You withdrew Ksh([0-9,]+\.?[0-9]*) from ([A-Z0-9\s]+) on (\d{1,2}/\d{1,2}/\d{4}) at (\d{1,2}:\d{2} [AP]M)'),
    'buy_goods': RegExp(r'You bought goods worth Ksh([0-9,]+\.?[0-9]*) from ([A-Z0-9\s]+) on (\d{1,2}/\d{1,2}/\d{4}) at (\d{1,2}:\d{2} [AP]M)'),
    'pay_bill': RegExp(r'You paid Ksh([0-9,]+\.?[0-9]*) to ([A-Z0-9\s]+) on (\d{1,2}/\d{1,2}/\d{4}) at (\d{1,2}:\d{2} [AP]M)'),
    'deposit': RegExp(r'You deposited Ksh([0-9,]+\.?[0-9]*) to ([A-Z0-9\s]+) on (\d{1,2}/\d{1,2}/\d{4}) at (\d{1,2}:\d{2} [AP]M)'),
    'balance': RegExp(r'Your M-PESA balance is Ksh([0-9,]+\.?[0-9]*)'),
  };

  /// Check if SMS permission is granted
  static Future<bool> hasSmsPermission() async {
    final status = await Permission.sms.status;
    return status.isGranted;
  }

  /// Request SMS permission with explanation
  static Future<bool> requestSmsPermission() async {
    final status = await Permission.sms.request();
    
    if (status.isGranted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_permissionKey, true);
      return true;
    }
    
    return false;
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

  /// Scan SMS messages for M-PESA transactions
  static Future<List<Transaction>> scanMpesaTransactions() async {
    if (!await hasSmsPermission()) {
      throw Exception('SMS permission not granted');
    }

    try {
      // TODO: Fix SMS Advanced package integration
      // For now, return empty list to prevent build errors
      print('SMS scanning temporarily disabled - package integration in progress');
      return [];
      
      // Original code commented out until SMS package is properly configured
      /*
      final messages = await SmsAdvanced.getSms(
        query: SmsQuery(
          limit: 100, // Get last 100 M-PESA messages
        ),
      );

      final transactions = <Transaction>[];
      final lastSync = await _getLastSyncTime();

      for (final message in messages) {
        // Filter for M-PESA messages
        if (message.address != _mpesaSender) {
          continue;
        }
        
        // Skip if message is older than last sync
        if (lastSync != null && (message.date?.isBefore(lastSync) ?? false)) {
          continue;
        }

        final transaction = _parseMpesaMessage(message);
        if (transaction != null) {
          transactions.add(transaction);
        }
      }

      // Update last sync time
      await _updateLastSyncTime();

      return transactions;
      */
    } catch (e) {
      print('Error scanning M-PESA transactions: $e');
      return [];
    }
  }

  /// Parse individual M-PESA SMS message
  static Transaction? _parseMpesaMessage(dynamic message) {
    // TODO: Fix SMS Advanced package integration
    // For now, return null to prevent build errors
    return null;
    
    // Original code commented out until SMS package is properly configured
    /*
    final body = message.body ?? '';
    
    for (final entry in _mpesaPatterns.entries) {
      final pattern = entry.value;
      final match = pattern.firstMatch(body);
      
      if (match != null) {
        return _createTransactionFromMatch(entry.key, match, message.date ?? DateTime.now());
      }
    }
    
    return null;
    */
  }

  /// Create transaction from regex match
  static Transaction _createTransactionFromMatch(String type, RegExpMatch match, DateTime date) {
    final amount = _parseAmount(match.group(1) ?? '0');
    final recipient = match.group(2)?.trim() ?? 'Unknown';
    
    return Transaction(
      id: _generateTransactionId(),
      type: _getTransactionType(type),
      amount: amount,
      recipient: recipient,
      description: _getTransactionDescription(type, recipient, amount),
      category: _categorizeTransaction(type, recipient),
      date: date,
      source: 'M-PESA SMS',
      isProcessed: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Parse amount string to double
  static double _parseAmount(String amountStr) {
    // Remove commas and convert to double
    final cleanAmount = amountStr.replaceAll(',', '');
    return double.tryParse(cleanAmount) ?? 0.0;
  }

  /// Get transaction type from M-PESA message type
  static TransactionType _getTransactionType(String mpesaType) {
    switch (mpesaType) {
      case 'received':
      case 'deposit':
        return TransactionType.income;
      case 'sent':
      case 'withdraw':
      case 'buy_goods':
      case 'pay_bill':
        return TransactionType.expense;
      default:
        return TransactionType.expense;
    }
  }

  /// Get human-readable transaction description
  static String _getTransactionDescription(String type, String recipient, double amount) {
    switch (type) {
      case 'received':
        return 'Received Ksh ${amount.toStringAsFixed(0)} from $recipient';
      case 'sent':
        return 'Sent Ksh ${amount.toStringAsFixed(0)} to $recipient';
      case 'withdraw':
        return 'Withdrew Ksh ${amount.toStringAsFixed(0)} from $recipient';
      case 'buy_goods':
        return 'Bought goods worth Ksh ${amount.toStringAsFixed(0)} from $recipient';
      case 'pay_bill':
        return 'Paid Ksh ${amount.toStringAsFixed(0)} to $recipient';
      case 'deposit':
        return 'Deposited Ksh ${amount.toStringAsFixed(0)} to $recipient';
      default:
        return 'M-PESA transaction: Ksh ${amount.toStringAsFixed(0)}';
    }
  }

  /// Categorize transaction based on type and recipient
  static String _categorizeTransaction(String type, String recipient) {
    final recipientLower = recipient.toLowerCase();
    
    // Income categories
    if (type == 'received' || type == 'deposit') {
      return 'Income';
    }
    
    // Expense categories based on recipient patterns
    if (recipientLower.contains('supermarket') || 
        recipientLower.contains('shop') || 
        recipientLower.contains('store')) {
      return 'Shopping';
    }
    
    if (recipientLower.contains('fuel') || 
        recipientLower.contains('petrol') || 
        recipientLower.contains('gas')) {
      return 'Transportation';
    }
    
    if (recipientLower.contains('restaurant') || 
        recipientLower.contains('food') || 
        recipientLower.contains('cafe')) {
      return 'Food & Dining';
    }
    
    if (recipientLower.contains('hospital') || 
        recipientLower.contains('clinic') || 
        recipientLower.contains('pharmacy')) {
      return 'Healthcare';
    }
    
    if (recipientLower.contains('school') || 
        recipientLower.contains('university') || 
        recipientLower.contains('college')) {
      return 'Education';
    }
    
    if (recipientLower.contains('electricity') || 
        recipientLower.contains('water') || 
        recipientLower.contains('internet')) {
      return 'Utilities';
    }
    
    if (type == 'pay_bill') {
      return 'Bills & Utilities';
    }
    
    if (type == 'buy_goods') {
      return 'Shopping';
    }
    
    if (type == 'withdraw') {
      return 'Cash Withdrawal';
    }
    
    return 'Other';
  }

  /// Generate unique transaction ID
  static String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return 'sms_${timestamp}_$random';
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
}

