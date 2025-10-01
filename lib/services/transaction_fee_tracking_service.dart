import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

enum PaymentMethod {
  mpesa,
  bankTransfer,
  cardPayment,
  cash,
  mobileBanking,
  pesaLink,
  airtime,
  other,
}

enum FeeType {
  transactionFee,      // Direct transaction fees
  serviceCharge,       // Service charges
  convenienceFee,      // Convenience fees
  processingFee,       // Processing fees
  withdrawalFee,       // ATM/withdrawal fees
  transferFee,         // Transfer fees
  airtimeFee,          // Airtime purchase fees
  billPaymentFee,      // Bill payment fees
}

class TransactionFee {
  final String id;
  final String transactionId;
  final PaymentMethod paymentMethod;
  final FeeType feeType;
  final double amount;
  final double feeAmount;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  TransactionFee({
    required this.id,
    required this.transactionId,
    required this.paymentMethod,
    required this.feeType,
    required this.amount,
    required this.feeAmount,
    required this.description,
    required this.timestamp,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'transactionId': transactionId,
    'paymentMethod': paymentMethod.toString().split('.').last,
    'feeType': feeType.toString().split('.').last,
    'amount': amount,
    'feeAmount': feeAmount,
    'description': description,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };

  factory TransactionFee.fromJson(Map<String, dynamic> json) {
    return TransactionFee(
      id: json['id'],
      transactionId: json['transactionId'],
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == json['paymentMethod'],
      ),
      feeType: FeeType.values.firstWhere(
        (e) => e.toString().split('.').last == json['feeType'],
      ),
      amount: json['amount'].toDouble(),
      feeAmount: json['feeAmount'].toDouble(),
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      metadata: Map<String, dynamic>.from(json['metadata']),
    );
  }
}

class FeeAnalytics {
  final double totalFees;
  final double totalTransactions;
  final Map<PaymentMethod, double> feesByPaymentMethod;
  final Map<FeeType, double> feesByType;
  final Map<String, double> feesByPeriod;
  final double averageFeePercentage;
  final double highestFeeAmount;
  final PaymentMethod mostExpensiveMethod;
  final List<TransactionFee> recentFees;

  FeeAnalytics({
    required this.totalFees,
    required this.totalTransactions,
    required this.feesByPaymentMethod,
    required this.feesByType,
    required this.feesByPeriod,
    required this.averageFeePercentage,
    required this.highestFeeAmount,
    required this.mostExpensiveMethod,
    required this.recentFees,
  });

  Map<String, dynamic> toJson() => {
    'totalFees': totalFees,
    'totalTransactions': totalTransactions,
    'feesByPaymentMethod': feesByPaymentMethod.map((k, v) => MapEntry(k.toString().split('.').last, v)),
    'feesByType': feesByType.map((k, v) => MapEntry(k.toString().split('.').last, v)),
    'feesByPeriod': feesByPeriod,
    'averageFeePercentage': averageFeePercentage,
    'highestFeeAmount': highestFeeAmount,
    'mostExpensiveMethod': mostExpensiveMethod.toString().split('.').last,
    'recentFees': recentFees.map((f) => f.toJson()).toList(),
  };
}

class TransactionFeeTrackingService {
  static const String _feesKey = 'transaction_fees';
  static const String _analyticsKey = 'fee_analytics';
  static const String _settingsKey = 'fee_settings';

  // M-Pesa fee structure (Kenya rates as of 2024)
  static final Map<String, Map<String, double>> _mpesaFees = {
    'send_money': {
      '0-100': 0.0,
      '101-500': 11.0,
      '501-1000': 15.0,
      '1001-1500': 25.0,
      '1501-2500': 29.0,
      '2501-3500': 37.0,
      '3501-5000': 55.0,
      '5001-7500': 60.0,
      '7501-10000': 75.0,
      '10001-15000': 85.0,
      '15001-20000': 95.0,
      '20001-35000': 100.0,
      '35001-50000': 110.0,
      '50001-70000': 150.0,
      '70001-100000': 200.0,
      '100001-150000': 250.0,
      '150001-200000': 300.0,
      '200001-300000': 350.0,
      '300001-500000': 500.0,
      '500001-700000': 750.0,
      '700001-1000000': 1000.0,
      '1000001+': 1500.0,
    },
    'buy_goods': {
      '0-100': 0.0,
      '101-500': 11.0,
      '501-1000': 15.0,
      '1001-1500': 25.0,
      '1501-2500': 29.0,
      '2501-3500': 37.0,
      '3501-5000': 55.0,
      '5001-7500': 60.0,
      '7501-10000': 75.0,
      '10001-15000': 85.0,
      '15001-20000': 95.0,
      '20001-35000': 100.0,
      '35001-50000': 110.0,
      '50001-70000': 150.0,
      '70001-100000': 200.0,
      '100001-150000': 250.0,
      '150001-200000': 300.0,
      '200001-300000': 350.0,
      '300001-500000': 500.0,
      '500001-700000': 750.0,
      '700001-1000000': 1000.0,
      '1000001+': 1500.0,
    },
    'pay_bills': {
      '0-100': 0.0,
      '101-500': 11.0,
      '501-1000': 15.0,
      '1001-1500': 25.0,
      '1501-2500': 29.0,
      '2501-3500': 37.0,
      '3501-5000': 55.0,
      '5001-7500': 60.0,
      '7501-10000': 75.0,
      '10001-15000': 85.0,
      '15001-20000': 95.0,
      '20001-35000': 100.0,
      '35001-50000': 110.0,
      '50001-70000': 150.0,
      '70001-100000': 200.0,
      '100001-150000': 250.0,
      '150001-200000': 300.0,
      '200001-300000': 350.0,
      '300001-500000': 500.0,
      '500001-700000': 750.0,
      '700001-1000000': 1000.0,
      '1000001+': 1500.0,
    },
    'withdraw': {
      '0-100': 0.0,
      '101-500': 11.0,
      '501-1000': 15.0,
      '1001-1500': 25.0,
      '1501-2500': 29.0,
      '2501-3500': 37.0,
      '3501-5000': 55.0,
      '5001-7500': 60.0,
      '7501-10000': 75.0,
      '10001-15000': 85.0,
      '15001-20000': 95.0,
      '20001-35000': 100.0,
      '35001-50000': 110.0,
      '50001-70000': 150.0,
      '70001-100000': 200.0,
      '100001-150000': 250.0,
      '150001-200000': 300.0,
      '200001-300000': 350.0,
      '300001-500000': 500.0,
      '500001-700000': 750.0,
      '700001-1000000': 1000.0,
      '1000001+': 1500.0,
    },
    'airtime': {
      '0-100': 0.0,
      '101-500': 0.0,
      '501-1000': 0.0,
      '1001-1500': 0.0,
      '1501-2500': 0.0,
      '2501-3500': 0.0,
      '3501-5000': 0.0,
      '5001-7500': 0.0,
      '7501-10000': 0.0,
      '10001-15000': 0.0,
      '15001-20000': 0.0,
      '20001-35000': 0.0,
      '35001-50000': 0.0,
      '50001-70000': 0.0,
      '70001-100000': 0.0,
      '100001-150000': 0.0,
      '150001-200000': 0.0,
      '200001-300000': 0.0,
      '300001-500000': 0.0,
      '500001-700000': 0.0,
      '700001-1000000': 0.0,
      '1000001+': 0.0,
    },
  };

  // Other payment method fees (estimated)
  static final Map<PaymentMethod, Map<String, double>> _otherFees = {
    PaymentMethod.bankTransfer: {
      'percentage': 0.5, // 0.5% of transaction
      'minimum': 10.0,
      'maximum': 500.0,
    },
    PaymentMethod.cardPayment: {
      'percentage': 2.5, // 2.5% of transaction
      'minimum': 5.0,
      'maximum': 1000.0,
    },
    PaymentMethod.mobileBanking: {
      'percentage': 0.3, // 0.3% of transaction
      'minimum': 5.0,
      'maximum': 200.0,
    },
    PaymentMethod.pesaLink: {
      'percentage': 0.5, // 0.5% of transaction
      'minimum': 10.0,
      'maximum': 500.0,
    },
    PaymentMethod.cash: {
      'percentage': 0.0,
      'minimum': 0.0,
      'maximum': 0.0,
    },
    PaymentMethod.airtime: {
      'percentage': 0.0,
      'minimum': 0.0,
      'maximum': 0.0,
    },
    PaymentMethod.other: {
      'percentage': 1.0, // 1% of transaction
      'minimum': 5.0,
      'maximum': 300.0,
    },
  };

  // Calculate fee for a transaction
  static double calculateFee(
    double amount,
    PaymentMethod paymentMethod,
    String transactionType, // 'send_money', 'buy_goods', 'pay_bills', 'withdraw', 'airtime'
  ) {
    if (paymentMethod == PaymentMethod.mpesa) {
      return _calculateMpesaFee(amount, transactionType);
    } else {
      return _calculateOtherFee(amount, paymentMethod);
    }
  }

  // Calculate M-Pesa fee
  static double _calculateMpesaFee(double amount, String transactionType) {
    final fees = _mpesaFees[transactionType] ?? _mpesaFees['send_money']!;
    
    for (final entry in fees.entries) {
      final range = entry.key.split('-');
      final min = double.parse(range[0]);
      final max = range[1] == '+' ? double.infinity : double.parse(range[1]);
      
      if (amount >= min && amount <= max) {
        return entry.value;
      }
    }
    
    return 0.0;
  }

  // Calculate other payment method fees
  static double _calculateOtherFee(double amount, PaymentMethod paymentMethod) {
    final feeStructure = _otherFees[paymentMethod] ?? _otherFees[PaymentMethod.other]!;
    
    final percentage = feeStructure['percentage']! / 100;
    final minimum = feeStructure['minimum']!;
    final maximum = feeStructure['maximum']!;
    
    final calculatedFee = amount * percentage;
    
    if (calculatedFee < minimum) return minimum;
    if (calculatedFee > maximum) return maximum;
    
    return calculatedFee;
  }

  // Record a transaction fee
  static Future<void> recordTransactionFee({
    required String transactionId,
    required double amount,
    required PaymentMethod paymentMethod,
    required String transactionType,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    final feeAmount = calculateFee(amount, paymentMethod, transactionType);
    
    if (feeAmount > 0) {
      final fee = TransactionFee(
        id: _generateId(),
        transactionId: transactionId,
        paymentMethod: paymentMethod,
        feeType: _getFeeType(transactionType),
        amount: amount,
        feeAmount: feeAmount,
        description: description,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
      );
      
      await _saveTransactionFee(fee);
    }
  }

  // Get fee type from transaction type
  static FeeType _getFeeType(String transactionType) {
    switch (transactionType) {
      case 'send_money':
        return FeeType.transferFee;
      case 'buy_goods':
        return FeeType.transactionFee;
      case 'pay_bills':
        return FeeType.billPaymentFee;
      case 'withdraw':
        return FeeType.withdrawalFee;
      case 'airtime':
        return FeeType.airtimeFee;
      default:
        return FeeType.transactionFee;
    }
  }

  // Save transaction fee
  static Future<void> _saveTransactionFee(TransactionFee fee) async {
    final prefs = await SharedPreferences.getInstance();
    final feesString = prefs.getString(_feesKey) ?? '[]';
    final fees = List<Map<String, dynamic>>.from(jsonDecode(feesString));
    
    fees.add(fee.toJson());
    
    // Keep only last 1000 fees
    if (fees.length > 1000) {
      fees.removeRange(0, fees.length - 1000);
    }
    
    await prefs.setString(_feesKey, jsonEncode(fees));
  }

  // Get all transaction fees
  static Future<List<TransactionFee>> getTransactionFees() async {
    final prefs = await SharedPreferences.getInstance();
    final feesString = prefs.getString(_feesKey) ?? '[]';
    final feesJson = List<Map<String, dynamic>>.from(jsonDecode(feesString));
    
    return feesJson.map((json) => TransactionFee.fromJson(json)).toList();
  }

  // Get fees for a specific period
  static Future<List<TransactionFee>> getFeesForPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allFees = await getTransactionFees();
    
    return allFees.where((fee) {
      return fee.timestamp.isAfter(startDate) && fee.timestamp.isBefore(endDate);
    }).toList();
  }

  // Get fees for current month
  static Future<List<TransactionFee>> getCurrentMonthFees() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);
    
    return getFeesForPeriod(startOfMonth, endOfMonth);
  }

  // Get fees for current week
  static Future<List<TransactionFee>> getCurrentWeekFees() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    
    return getFeesForPeriod(startOfWeek, endOfWeek);
  }

  // Get fees for current day
  static Future<List<TransactionFee>> getCurrentDayFees() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return getFeesForPeriod(startOfDay, endOfDay);
  }

  // Calculate fee analytics
  static Future<FeeAnalytics> calculateFeeAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final now = DateTime.now();
    final start = startDate ?? DateTime(now.year, now.month, 1);
    final end = endDate ?? now;
    
    final fees = await getFeesForPeriod(start, end);
    
    if (fees.isEmpty) {
      return FeeAnalytics(
        totalFees: 0.0,
        totalTransactions: 0.0,
        feesByPaymentMethod: {},
        feesByType: {},
        feesByPeriod: {},
        averageFeePercentage: 0.0,
        highestFeeAmount: 0.0,
        mostExpensiveMethod: PaymentMethod.cash,
        recentFees: [],
      );
    }
    
    // Calculate totals
    final totalFees = fees.fold(0.0, (sum, fee) => sum + fee.feeAmount);
    final totalTransactions = fees.fold(0.0, (sum, fee) => sum + fee.amount);
    
    // Group by payment method
    final feesByPaymentMethod = <PaymentMethod, double>{};
    for (final fee in fees) {
      feesByPaymentMethod[fee.paymentMethod] = 
          (feesByPaymentMethod[fee.paymentMethod] ?? 0.0) + fee.feeAmount;
    }
    
    // Group by fee type
    final feesByType = <FeeType, double>{};
    for (final fee in fees) {
      feesByType[fee.feeType] = 
          (feesByType[fee.feeType] ?? 0.0) + fee.feeAmount;
    }
    
    // Group by period (daily)
    final feesByPeriod = <String, double>{};
    for (final fee in fees) {
      final dateKey = '${fee.timestamp.year}-${fee.timestamp.month.toString().padLeft(2, '0')}-${fee.timestamp.day.toString().padLeft(2, '0')}';
      feesByPeriod[dateKey] = (feesByPeriod[dateKey] ?? 0.0) + fee.feeAmount;
    }
    
    // Calculate averages and maximums
    final averageFeePercentage = totalTransactions > 0 ? (totalFees / totalTransactions) * 100 : 0.0;
    final highestFeeAmount = fees.fold(0.0, (max, fee) => fee.feeAmount > max ? fee.feeAmount : max);
    
    // Find most expensive payment method
    PaymentMethod mostExpensiveMethod = PaymentMethod.cash;
    double maxMethodFees = 0.0;
    for (final entry in feesByPaymentMethod.entries) {
      if (entry.value > maxMethodFees) {
        maxMethodFees = entry.value;
        mostExpensiveMethod = entry.key;
      }
    }
    
    // Get recent fees (last 10)
    final recentFees = fees.take(10).toList();
    
    return FeeAnalytics(
      totalFees: totalFees,
      totalTransactions: totalTransactions,
      feesByPaymentMethod: feesByPaymentMethod,
      feesByType: feesByType,
      feesByPeriod: feesByPeriod,
      averageFeePercentage: averageFeePercentage,
      highestFeeAmount: highestFeeAmount,
      mostExpensiveMethod: mostExpensiveMethod,
      recentFees: recentFees,
    );
  }

  // Get fee insights and recommendations
  static Future<Map<String, dynamic>> getFeeInsights() async {
    final analytics = await calculateFeeAnalytics();
    final insights = <String>[];
    final recommendations = <String>[];
    
    // Analyze fee patterns
    if (analytics.totalFees > 0) {
      // High fee percentage
      if (analytics.averageFeePercentage > 5.0) {
        insights.add('Your transaction fees are ${analytics.averageFeePercentage.toStringAsFixed(1)}% of your total spending');
        recommendations.add('Consider using cash or bank transfers for larger amounts to reduce fees');
      }
      
      // Most expensive payment method
      final mostExpensive = analytics.mostExpensiveMethod;
      final mostExpensiveFees = analytics.feesByPaymentMethod[mostExpensive] ?? 0.0;
      if (mostExpensiveFees > analytics.totalFees * 0.5) {
        insights.add('${_getPaymentMethodName(mostExpensive)} is your most expensive payment method');
        recommendations.add('Try using ${_getCheaperAlternative(mostExpensive)} for some transactions');
      }
      
      // High frequency of small transactions
      final smallTransactionFees = analytics.feesByType[FeeType.transactionFee] ?? 0.0;
      if (smallTransactionFees > analytics.totalFees * 0.3) {
        insights.add('You have many small transaction fees');
        recommendations.add('Consider batching small payments to reduce total fees');
      }
      
      // Daily fee patterns
      if (analytics.feesByPeriod.length > 7) {
        final dailyAverage = analytics.totalFees / analytics.feesByPeriod.length;
        final highFeeDays = analytics.feesByPeriod.values.where((fees) => fees > dailyAverage * 1.5).length;
        if (highFeeDays > 2) {
          insights.add('You have high fee days that could be optimized');
          recommendations.add('Plan your transactions to avoid peak fee periods');
        }
      }
    }
    
    return {
      'insights': insights,
      'recommendations': recommendations,
      'analytics': analytics.toJson(),
    };
  }

  // Get payment method name
  static String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.mpesa:
        return 'M-Pesa';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.cardPayment:
        return 'Card Payment';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.mobileBanking:
        return 'Mobile Banking';
      case PaymentMethod.pesaLink:
        return 'PesaLink';
      case PaymentMethod.airtime:
        return 'Airtime';
      case PaymentMethod.other:
        return 'Other';
    }
  }

  // Get cheaper alternative
  static String _getCheaperAlternative(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.mpesa:
        return 'bank transfers or cash';
      case PaymentMethod.cardPayment:
        return 'M-Pesa or bank transfers';
      case PaymentMethod.bankTransfer:
        return 'cash for small amounts';
      case PaymentMethod.mobileBanking:
        return 'M-Pesa or bank transfers';
      case PaymentMethod.pesaLink:
        return 'M-Pesa or bank transfers';
      default:
        return 'alternative payment methods';
    }
  }

  // Generate unique ID
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(1000).toString();
  }

  // Get fee summary for dashboard
  static Future<Map<String, dynamic>> getFeeSummary() async {
    final currentMonthFees = await getCurrentMonthFees();
    final currentWeekFees = await getCurrentWeekFees();
    final currentDayFees = await getCurrentDayFees();
    
    final currentMonthTotal = currentMonthFees.fold(0.0, (sum, fee) => sum + fee.feeAmount);
    final currentWeekTotal = currentWeekFees.fold(0.0, (sum, fee) => sum + fee.feeAmount);
    final currentDayTotal = currentDayFees.fold(0.0, (sum, fee) => sum + fee.feeAmount);
    
    return {
      'today': currentDayTotal,
      'thisWeek': currentWeekTotal,
      'thisMonth': currentMonthTotal,
      'todayCount': currentDayFees.length,
      'weekCount': currentWeekFees.length,
      'monthCount': currentMonthFees.length,
    };
  }
}

