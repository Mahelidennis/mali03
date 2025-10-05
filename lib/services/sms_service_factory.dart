import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import 'sms_transaction_service_web.dart';

/// Factory to provide the appropriate SMS service based on platform
class SmsServiceFactory {
  /// Check if SMS permission is granted
  static Future<bool> hasSmsPermission() async {
    return await SmsTransactionServiceWeb.hasSmsPermission();
  }

  /// Request SMS permission
  static Future<bool> requestSmsPermission() async {
    return await SmsTransactionServiceWeb.requestSmsPermission();
  }

  /// Check if user has given consent
  static Future<bool> hasUserConsent() async {
    return await SmsTransactionServiceWeb.hasUserConsent();
  }

  /// Set user consent
  static Future<void> setUserConsent(bool consent) async {
    await SmsTransactionServiceWeb.setUserConsent(consent);
  }

  /// Scan for M-PESA transactions
  static Future<List<Transaction>> scanMpesaTransactions() async {
    return await SmsTransactionServiceWeb.scanMpesaTransactions();
  }

  /// Save transactions
  static Future<void> saveTransactions(List<Transaction> transactions) async {
    await SmsTransactionServiceWeb.saveTransactions(transactions);
  }

  /// Get stored transactions
  static Future<List<Transaction>> getStoredTransactions() async {
    return await SmsTransactionServiceWeb.getStoredTransactions();
  }

  /// Clear transactions
  static Future<void> clearTransactions() async {
    await SmsTransactionServiceWeb.clearTransactions();
  }

  /// Get transaction statistics
  static Future<Map<String, dynamic>> getTransactionStats() async {
    return await SmsTransactionServiceWeb.getTransactionStats();
  }
}
