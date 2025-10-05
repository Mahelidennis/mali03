import '../models/transaction_model.dart';

/// Service to handle M-PESA transaction charges calculation and tracking
class TransactionChargesService {
  // M-PESA charges structure (as of 2024)
  static const Map<String, double> _mpesaCharges = {
    'send_0_100': 0.0,      // Free for 0-100
    'send_101_500': 7.0,    // Ksh 7 for 101-500
    'send_501_1000': 13.0,  // Ksh 13 for 501-1000
    'send_1001_1500': 23.0, // Ksh 23 for 1001-1500
    'send_1501_2500': 33.0, // Ksh 33 for 1501-2500
    'send_2501_3500': 53.0, // Ksh 53 for 2501-3500
    'send_3501_5000': 57.0, // Ksh 57 for 3501-5000
    'send_5001_7500': 78.0, // Ksh 78 for 5001-7500
    'send_7501_10000': 90.0, // Ksh 90 for 7501-10000
    'send_10001_15000': 100.0, // Ksh 100 for 10001-15000
    'send_15001_20000': 110.0, // Ksh 110 for 15001-20000
    'send_20001_25000': 120.0, // Ksh 120 for 20001-25000
    'send_25001_30000': 130.0, // Ksh 130 for 25001-30000
    'send_30001_35000': 140.0, // Ksh 140 for 30001-35000
    'send_35001_40000': 150.0, // Ksh 150 for 35001-40000
    'send_40001_45000': 160.0, // Ksh 160 for 40001-45000
    'send_45001_50000': 170.0, // Ksh 170 for 45001-50000
    'send_50001_60000': 180.0, // Ksh 180 for 50001-60000
    'send_60001_70000': 190.0, // Ksh 190 for 60001-70000
    'send_70001_80000': 200.0, // Ksh 200 for 70001-80000
    'send_80001_90000': 210.0, // Ksh 210 for 80001-90000
    'send_90001_100000': 220.0, // Ksh 220 for 90001-100000
    'send_100001_150000': 230.0, // Ksh 230 for 100001-150000
    'send_150001_200000': 240.0, // Ksh 240 for 150001-200000
    'send_200001_250000': 250.0, // Ksh 250 for 200001-250000
    'send_250001_300000': 260.0, // Ksh 260 for 250001-300000
    'send_300001_350000': 270.0, // Ksh 270 for 300001-350000
    'send_350001_400000': 280.0, // Ksh 280 for 350001-400000
    'send_400001_450000': 290.0, // Ksh 290 for 400001-450000
    'send_450001_500000': 300.0, // Ksh 300 for 450001-500000
    'send_500001_plus': 330.0,   // Ksh 330 for 500001+
    
    // Withdraw charges
    'withdraw_0_100': 0.0,       // Free for 0-100
    'withdraw_101_500': 7.0,     // Ksh 7 for 101-500
    'withdraw_501_1000': 13.0,   // Ksh 13 for 501-1000
    'withdraw_1001_1500': 23.0,  // Ksh 23 for 1001-1500
    'withdraw_1501_2500': 33.0,  // Ksh 33 for 1501-2500
    'withdraw_2501_3500': 53.0,  // Ksh 53 for 2501-3500
    'withdraw_3501_5000': 57.0,  // Ksh 57 for 3501-5000
    'withdraw_5001_7500': 78.0,  // Ksh 78 for 5001-7500
    'withdraw_7501_10000': 90.0, // Ksh 90 for 7501-10000
    'withdraw_10001_15000': 100.0, // Ksh 100 for 10001-15000
    'withdraw_15001_20000': 110.0, // Ksh 110 for 15001-20000
    'withdraw_20001_25000': 120.0, // Ksh 120 for 20001-25000
    'withdraw_25001_30000': 130.0, // Ksh 130 for 25001-30000
    'withdraw_30001_35000': 140.0, // Ksh 140 for 30001-35000
    'withdraw_35001_40000': 150.0, // Ksh 150 for 35001-40000
    'withdraw_40001_45000': 160.0, // Ksh 160 for 40001-45000
    'withdraw_45001_50000': 170.0, // Ksh 170 for 45001-50000
    'withdraw_50001_60000': 180.0, // Ksh 180 for 50001-60000
    'withdraw_60001_70000': 190.0, // Ksh 190 for 60001-70000
    'withdraw_70001_80000': 200.0, // Ksh 200 for 70001-80000
    'withdraw_80001_90000': 210.0, // Ksh 210 for 80001-90000
    'withdraw_90001_100000': 220.0, // Ksh 220 for 90001-100000
    'withdraw_100001_150000': 230.0, // Ksh 230 for 100001-150000
    'withdraw_150001_200000': 240.0, // Ksh 240 for 150001-200000
    'withdraw_200001_250000': 250.0, // Ksh 250 for 200001-250000
    'withdraw_250001_300000': 260.0, // Ksh 260 for 250001-300000
    'withdraw_300001_350000': 270.0, // Ksh 270 for 300001-350000
    'withdraw_350001_400000': 280.0, // Ksh 280 for 350001-400000
    'withdraw_400001_450000': 290.0, // Ksh 290 for 400001-450000
    'withdraw_450001_500000': 300.0, // Ksh 300 for 450001-500000
    'withdraw_500001_plus': 330.0,   // Ksh 330 for 500001+
    
    // Buy goods charges
    'buy_goods_0_100': 0.0,      // Free for 0-100
    'buy_goods_101_500': 7.0,    // Ksh 7 for 101-500
    'buy_goods_501_1000': 13.0,  // Ksh 13 for 501-1000
    'buy_goods_1001_1500': 23.0, // Ksh 23 for 1001-1500
    'buy_goods_1501_2500': 33.0, // Ksh 33 for 1501-2500
    'buy_goods_2501_3500': 53.0, // Ksh 53 for 2501-3500
    'buy_goods_3501_5000': 57.0, // Ksh 57 for 3501-5000
    'buy_goods_5001_7500': 78.0, // Ksh 78 for 5001-7500
    'buy_goods_7501_10000': 90.0, // Ksh 90 for 7501-10000
    'buy_goods_10001_15000': 100.0, // Ksh 100 for 10001-15000
    'buy_goods_15001_20000': 110.0, // Ksh 110 for 15001-20000
    'buy_goods_20001_25000': 120.0, // Ksh 120 for 20001-25000
    'buy_goods_25001_30000': 130.0, // Ksh 130 for 25001-30000
    'buy_goods_30001_35000': 140.0, // Ksh 140 for 30001-35000
    'buy_goods_35001_40000': 150.0, // Ksh 150 for 35001-40000
    'buy_goods_40001_45000': 160.0, // Ksh 160 for 40001-45000
    'buy_goods_45001_50000': 170.0, // Ksh 170 for 45001-50000
    'buy_goods_50001_60000': 180.0, // Ksh 180 for 50001-60000
    'buy_goods_60001_70000': 190.0, // Ksh 190 for 60001-70000
    'buy_goods_70001_80000': 200.0, // Ksh 200 for 70001-80000
    'buy_goods_80001_90000': 210.0, // Ksh 210 for 80001-90000
    'buy_goods_90001_100000': 220.0, // Ksh 220 for 90001-100000
    'buy_goods_100001_150000': 230.0, // Ksh 230 for 100001-150000
    'buy_goods_150001_200000': 240.0, // Ksh 240 for 150001-200000
    'buy_goods_200001_250000': 250.0, // Ksh 250 for 200001-250000
    'buy_goods_250001_300000': 260.0, // Ksh 260 for 250001-300000
    'buy_goods_300001_350000': 270.0, // Ksh 270 for 300001-350000
    'buy_goods_350001_400000': 280.0, // Ksh 280 for 350001-400000
    'buy_goods_400001_450000': 290.0, // Ksh 290 for 400001-450000
    'buy_goods_450001_500000': 300.0, // Ksh 300 for 450001-500000
    'buy_goods_500001_plus': 330.0,   // Ksh 330 for 500001+
    
    // Pay bill charges
    'pay_bill_0_100': 0.0,       // Free for 0-100
    'pay_bill_101_500': 7.0,     // Ksh 7 for 101-500
    'pay_bill_501_1000': 13.0,   // Ksh 13 for 501-1000
    'pay_bill_1001_1500': 23.0,  // Ksh 23 for 1001-1500
    'pay_bill_1501_2500': 33.0,  // Ksh 33 for 1501-2500
    'pay_bill_2501_3500': 53.0,  // Ksh 53 for 2501-3500
    'pay_bill_3501_5000': 57.0,  // Ksh 57 for 3501-5000
    'pay_bill_5001_7500': 78.0,  // Ksh 78 for 5001-7500
    'pay_bill_7501_10000': 90.0, // Ksh 90 for 7501-10000
    'pay_bill_10001_15000': 100.0, // Ksh 100 for 10001-15000
    'pay_bill_15001_20000': 110.0, // Ksh 110 for 15001-20000
    'pay_bill_20001_25000': 120.0, // Ksh 120 for 20001-25000
    'pay_bill_25001_30000': 130.0, // Ksh 130 for 25001-30000
    'pay_bill_30001_35000': 140.0, // Ksh 140 for 30001-35000
    'pay_bill_35001_40000': 150.0, // Ksh 150 for 35001-40000
    'pay_bill_40001_45000': 160.0, // Ksh 160 for 40001-45000
    'pay_bill_45001_50000': 170.0, // Ksh 170 for 45001-50000
    'pay_bill_50001_60000': 180.0, // Ksh 180 for 50001-60000
    'pay_bill_60001_70000': 190.0, // Ksh 190 for 60001-70000
    'pay_bill_70001_80000': 200.0, // Ksh 200 for 70001-80000
    'pay_bill_80001_90000': 210.0, // Ksh 210 for 80001-90000
    'pay_bill_90001_100000': 220.0, // Ksh 220 for 90001-100000
    'pay_bill_100001_150000': 230.0, // Ksh 230 for 100001-150000
    'pay_bill_150001_200000': 240.0, // Ksh 240 for 150001-200000
    'pay_bill_200001_250000': 250.0, // Ksh 250 for 200001-250000
    'pay_bill_250001_300000': 260.0, // Ksh 260 for 250001-300000
    'pay_bill_300001_350000': 270.0, // Ksh 270 for 300001-350000
    'pay_bill_350001_400000': 280.0, // Ksh 280 for 350001-400000
    'pay_bill_400001_450000': 290.0, // Ksh 290 for 400001-450000
    'pay_bill_450001_500000': 300.0, // Ksh 300 for 450001-500000
    'pay_bill_500001_plus': 330.0,   // Ksh 330 for 500001+
  };

  /// Calculate M-PESA transaction charge based on amount and type
  static double calculateMpesaCharge(double amount, String transactionType) {
    final String key = _getChargeKey(amount, transactionType);
    return _mpesaCharges[key] ?? 0.0;
  }

  /// Get charge key for lookup
  static String _getChargeKey(double amount, String transactionType) {
    final String prefix = transactionType.toLowerCase().replaceAll(' ', '_');
    
    if (amount <= 100) return '${prefix}_0_100';
    if (amount <= 500) return '${prefix}_101_500';
    if (amount <= 1000) return '${prefix}_501_1000';
    if (amount <= 1500) return '${prefix}_1001_1500';
    if (amount <= 2500) return '${prefix}_1501_2500';
    if (amount <= 3500) return '${prefix}_2501_3500';
    if (amount <= 5000) return '${prefix}_3501_5000';
    if (amount <= 7500) return '${prefix}_5001_7500';
    if (amount <= 10000) return '${prefix}_7501_10000';
    if (amount <= 15000) return '${prefix}_10001_15000';
    if (amount <= 20000) return '${prefix}_15001_20000';
    if (amount <= 25000) return '${prefix}_20001_25000';
    if (amount <= 30000) return '${prefix}_25001_30000';
    if (amount <= 35000) return '${prefix}_30001_35000';
    if (amount <= 40000) return '${prefix}_35001_40000';
    if (amount <= 45000) return '${prefix}_40001_45000';
    if (amount <= 50000) return '${prefix}_45001_50000';
    if (amount <= 60000) return '${prefix}_50001_60000';
    if (amount <= 70000) return '${prefix}_60001_70000';
    if (amount <= 80000) return '${prefix}_70001_80000';
    if (amount <= 90000) return '${prefix}_80001_90000';
    if (amount <= 100000) return '${prefix}_90001_100000';
    if (amount <= 150000) return '${prefix}_100001_150000';
    if (amount <= 200000) return '${prefix}_150001_200000';
    if (amount <= 250000) return '${prefix}_200001_250000';
    if (amount <= 300000) return '${prefix}_250001_300000';
    if (amount <= 350000) return '${prefix}_300001_350000';
    if (amount <= 400000) return '${prefix}_350001_400000';
    if (amount <= 450000) return '${prefix}_400001_450000';
    if (amount <= 500000) return '${prefix}_450001_500000';
    return '${prefix}_500001_plus';
  }

  /// Get charge description
  static String getChargeDescription(double amount, String transactionType) {
    final double charge = calculateMpesaCharge(amount, transactionType);
    if (charge == 0) return 'Free transaction';
    return 'M-PESA charge: Ksh ${charge.toStringAsFixed(0)}';
  }

  /// Calculate total charges for a list of transactions
  static double calculateTotalCharges(List<Transaction> transactions) {
    return transactions.fold(0.0, (sum, transaction) {
      return sum + (transaction.transactionCharge ?? 0.0);
    });
  }

  /// Get charges summary for a period
  static Map<String, dynamic> getChargesSummary(List<Transaction> transactions, String period) {
    final double totalCharges = calculateTotalCharges(transactions);
    final int transactionCount = transactions.length;
    final double averageCharge = transactionCount > 0 ? totalCharges / transactionCount : 0.0;
    
    // Group by transaction type
    final Map<String, double> chargesByType = {};
    for (final transaction in transactions) {
      final type = transaction.category;
      chargesByType[type] = (chargesByType[type] ?? 0.0) + (transaction.transactionCharge ?? 0.0);
    }
    
    return {
      'totalCharges': totalCharges,
      'transactionCount': transactionCount,
      'averageCharge': averageCharge,
      'chargesByType': chargesByType,
      'period': period,
    };
  }
}

