import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';

/// Stub implementation for platforms that don't support SMS
class SmsTransactionServiceStub {
  static const String _permissionKey = 'sms_permission_granted';
  static const String _lastSyncKey = 'last_sms_sync';
  
  /// Check if SMS permission is granted (always false for unsupported platforms)
  static Future<bool> hasSmsPermission() async {
    return false;
  }

  /// Request SMS permission (always false for unsupported platforms)
  static Future<bool> requestSmsPermission() async {
    return false;
  }

  /// Check if user has previously granted permission
  static Future<bool> hasUserConsent() async {
    return false;
  }

  /// Set user consent for SMS tracking
  static Future<void> setUserConsent(bool consent) async {
    // No-op for unsupported platforms
  }

  /// Scan SMS messages for M-PESA transactions (returns empty list)
  static Future<List<Transaction>> scanMpesaTransactions() async {
    return [];
  }

  /// Save transactions to local storage
  static Future<void> saveTransactions(List<Transaction> transactions) async {
    // No-op for unsupported platforms
  }

  /// Get stored transactions
  static Future<List<Transaction>> getStoredTransactions() async {
    return [];
  }

  /// Clear all SMS transactions
  static Future<void> clearTransactions() async {
    // No-op for unsupported platforms
  }

  /// Get transaction statistics
  static Future<Map<String, dynamic>> getTransactionStats() async {
    return {
      'totalTransactions': 0,
      'totalIncome': 0.0,
      'totalExpenses': 0.0,
      'netAmount': 0.0,
      'categoryTotals': <String, double>{},
      'lastSync': null,
    };
  }
}

