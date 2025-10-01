import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'transaction_fee_tracking_service.dart';
import 'coaching_intervention_service.dart';
import 'financial_personality_service.dart';

class FeeCoachingService {
  static const String _feeInsightsKey = 'fee_insights';
  static const String _feeGoalsKey = 'fee_goals';

  // Generate fee-based coaching interventions
  static Future<CoachingIntervention?> generateFeeIntervention(
    double amount,
    PaymentMethod paymentMethod,
    String transactionType,
  ) async {
    final fee = TransactionFeeTrackingService.calculateFee(amount, paymentMethod, transactionType);
    final personality = await FinancialPersonalityService.getCurrentPersonality();
    
    // Only generate intervention if fee is significant
    if (fee < 10.0) return null;
    
    // Check if user has been paying high fees recently
    final recentFees = await TransactionFeeTrackingService.getCurrentWeekFees();
    final weeklyFeeTotal = recentFees.fold(0.0, (sum, fee) => sum + fee.feeAmount);
    
    // Generate intervention based on fee patterns
    if (weeklyFeeTotal > 500) {
      return _createHighFeeIntervention(fee, paymentMethod, personality);
    } else if (fee > 100) {
      return _createExpensiveTransactionIntervention(fee, paymentMethod, personality);
    } else if (_isInefficientPaymentMethod(paymentMethod, amount)) {
      return _createInefficientMethodIntervention(paymentMethod, personality);
    }
    
    return null;
  }

  // Create high fee intervention
  static CoachingIntervention _createHighFeeIntervention(
    double fee,
    PaymentMethod paymentMethod,
    FinancialPersonality? personality,
  ) {
    final personalityType = personality?.type ?? FinancialPersonalityType.spender;
    
    String title;
    String message;
    List<String> actions;
    
    switch (personalityType) {
      case FinancialPersonalityType.spender:
        title = "Those fees are adding up! 💅";
        message = "I noticed you've paid Ksh ${fee.toStringAsFixed(0)} in fees this week. That's money that could go toward your goals! Want to explore some fee-saving strategies?";
        actions = ["Show me alternatives", "Set fee budget", "Learn about fees", "Continue anyway"];
        break;
        
      case FinancialPersonalityType.saver:
        title = "Fee Optimization Alert";
        message = "You've accumulated Ksh ${fee.toStringAsFixed(0)} in transaction fees this week. Let's find ways to reduce these costs.";
        actions = ["Analyze fee patterns", "Find cheaper methods", "Set fee limits", "Review spending"];
        break;
        
      case FinancialPersonalityType.avoider:
        title = "Gentle Fee Reminder 🌸";
        message = "I noticed some transaction fees that might be higher than necessary. No pressure, but I can help you save money if you'd like.";
        actions = ["Learn about fees", "See alternatives", "Maybe later", "Not now"];
        break;
        
      default:
        title = "High Transaction Fees";
        message = "You've paid Ksh ${fee.toStringAsFixed(0)} in fees recently. Consider using alternative payment methods to save money.";
        actions = ["Explore options", "Set limits", "Continue", "Dismiss"];
    }
    
    return CoachingIntervention(
      id: _generateId(),
      type: InterventionType.warning,
      trigger: InterventionTrigger.riskBehavior,
      title: title,
      message: message,
      actions: actions,
      context: {
        'fee_amount': fee,
        'payment_method': paymentMethod.toString(),
        'intervention_type': 'high_fees',
      },
      createdAt: DateTime.now(),
      priority: 6,
    );
  }

  // Create expensive transaction intervention
  static CoachingIntervention _createExpensiveTransactionIntervention(
    double fee,
    PaymentMethod paymentMethod,
    FinancialPersonality? personality,
  ) {
    final personalityType = personality?.type ?? FinancialPersonalityType.spender;
    
    String title;
    String message;
    List<String> actions;
    
    switch (personalityType) {
      case FinancialPersonalityType.spender:
        title = "That's a pricey transaction! 💸";
        message = "This ${_getPaymentMethodName(paymentMethod)} transaction will cost you Ksh ${fee.toStringAsFixed(0)} in fees. Want to explore a cheaper option?";
        actions = ["Find cheaper method", "Split the payment", "Use cash instead", "Proceed anyway"];
        break;
        
      case FinancialPersonalityType.saver:
        title = "Expensive Transaction Fee";
        message = "This transaction will incur Ksh ${fee.toStringAsFixed(0)} in fees. Consider using a more cost-effective payment method.";
        actions = ["Calculate alternatives", "Use different method", "Proceed with fee", "Cancel transaction"];
        break;
        
      default:
        title = "High Transaction Fee";
        message = "This transaction will cost Ksh ${fee.toStringAsFixed(0)} in fees. You might want to consider alternatives.";
        actions = ["See alternatives", "Proceed anyway", "Cancel"];
    }
    
    return CoachingIntervention(
      id: _generateId(),
      type: InterventionType.warning,
      trigger: InterventionTrigger.impulsiveBehavior,
      title: title,
      message: message,
      actions: actions,
      context: {
        'fee_amount': fee,
        'payment_method': paymentMethod.toString(),
        'intervention_type': 'expensive_transaction',
      },
      createdAt: DateTime.now(),
      priority: 7,
    );
  }

  // Create inefficient method intervention
  static CoachingIntervention _createInefficientMethodIntervention(
    PaymentMethod paymentMethod,
    FinancialPersonality? personality,
  ) {
    final personalityType = personality?.type ?? FinancialPersonalityType.spender;
    final alternative = _getCheaperAlternative(paymentMethod);
    
    String title;
    String message;
    List<String> actions;
    
    switch (personalityType) {
      case FinancialPersonalityType.spender:
        title = "There's a cheaper way! 💡";
        message = "I noticed you're using ${_getPaymentMethodName(paymentMethod)}. You could save money by using $alternative for some transactions.";
        actions = ["Show me how", "Learn about methods", "Keep using this", "Maybe later"];
        break;
        
      case FinancialPersonalityType.saver:
        title = "Payment Method Optimization";
        message = "Consider using $alternative instead of ${_getPaymentMethodName(paymentMethod)} to reduce transaction fees.";
        actions = ["Compare methods", "Switch to alternative", "Keep current method", "Learn more"];
        break;
        
      default:
        title = "Fee-Saving Opportunity";
        message = "You could save money by using $alternative instead of ${_getPaymentMethodName(paymentMethod)} for some transactions.";
        actions = ["See alternatives", "Learn more", "Continue", "Dismiss"];
    }
    
    return CoachingIntervention(
      id: _generateId(),
      type: InterventionType.educational,
      trigger: InterventionTrigger.learningOpportunity,
      title: title,
      message: message,
      actions: actions,
      context: {
        'current_method': paymentMethod.toString(),
        'suggested_alternative': alternative,
        'intervention_type': 'inefficient_method',
      },
      createdAt: DateTime.now(),
      priority: 4,
    );
  }

  // Check if payment method is inefficient for the amount
  static bool _isInefficientPaymentMethod(PaymentMethod method, double amount) {
    switch (method) {
      case PaymentMethod.cardPayment:
        return amount < 1000; // Cards have high fees for small amounts
      case PaymentMethod.bankTransfer:
        return amount < 500; // Bank transfers have minimum fees
      case PaymentMethod.mpesa:
        return amount > 50000; // M-Pesa gets expensive for large amounts
      default:
        return false;
    }
  }

  // Get cheaper alternative for payment method
  static String _getCheaperAlternative(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cardPayment:
        return 'M-Pesa or bank transfer';
      case PaymentMethod.bankTransfer:
        return 'M-Pesa for small amounts';
      case PaymentMethod.mpesa:
        return 'bank transfer for large amounts';
      case PaymentMethod.mobileBanking:
        return 'M-Pesa or PesaLink';
      default:
        return 'alternative payment methods';
    }
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

  // Generate fee insights for dashboard
  static Future<Map<String, dynamic>> generateFeeInsights() async {
    final analytics = await TransactionFeeTrackingService.calculateFeeAnalytics();
    final insights = <String>[];
    final recommendations = <String>[];
    
    // Analyze fee patterns
    if (analytics.totalFees > 0) {
      // High fee percentage
      if (analytics.averageFeePercentage > 3.0) {
        insights.add('Your transaction fees are ${analytics.averageFeePercentage.toStringAsFixed(1)}% of your total spending');
        recommendations.add('Consider using cash or bank transfers for larger amounts');
      }
      
      // Most expensive payment method
      final mostExpensive = analytics.mostExpensiveMethod;
      final mostExpensiveFees = analytics.feesByPaymentMethod[mostExpensive] ?? 0.0;
      if (mostExpensiveFees > analytics.totalFees * 0.6) {
        insights.add('${_getPaymentMethodName(mostExpensive)} accounts for ${((mostExpensiveFees / analytics.totalFees) * 100).toStringAsFixed(0)}% of your fees');
        recommendations.add('Try using ${_getCheaperAlternative(mostExpensive)} for some transactions');
      }
      
      // High frequency of small transactions
      final smallTransactionFees = analytics.feesByType[FeeType.transactionFee] ?? 0.0;
      if (smallTransactionFees > analytics.totalFees * 0.4) {
        insights.add('You have many small transaction fees that add up');
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
      
      // Fee trends
      if (analytics.feesByPeriod.length > 14) {
        final recentFees = analytics.feesByPeriod.values.take(7).fold(0.0, (sum, fee) => sum + fee);
        final olderFees = analytics.feesByPeriod.values.skip(7).take(7).fold(0.0, (sum, fee) => sum + fee);
        
        if (recentFees > olderFees * 1.2) {
          insights.add('Your transaction fees have increased recently');
          recommendations.add('Review your payment methods and transaction patterns');
        } else if (recentFees < olderFees * 0.8) {
          insights.add('Great job! Your transaction fees have decreased');
          recommendations.add('Keep up the good work with fee optimization');
        }
      }
    }
    
    return {
      'insights': insights,
      'recommendations': recommendations,
      'totalFees': analytics.totalFees,
      'averageFeePercentage': analytics.averageFeePercentage,
      'mostExpensiveMethod': _getPaymentMethodName(analytics.mostExpensiveMethod),
    };
  }

  // Set fee goals
  static Future<void> setFeeGoal(double monthlyFeeLimit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_feeGoalsKey, monthlyFeeLimit);
  }

  // Get fee goal
  static Future<double?> getFeeGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_feeGoalsKey);
  }

  // Check if fee goal is exceeded
  static Future<bool> isFeeGoalExceeded() async {
    final goal = await getFeeGoal();
    if (goal == null) return false;
    
    final currentMonthFees = await TransactionFeeTrackingService.getCurrentMonthFees();
    final monthlyTotal = currentMonthFees.fold(0.0, (sum, fee) => sum + fee.feeAmount);
    
    return monthlyTotal > goal;
  }

  // Generate fee goal intervention
  static Future<CoachingIntervention?> generateFeeGoalIntervention() async {
    final isExceeded = await isFeeGoalExceeded();
    if (!isExceeded) return null;
    
    final goal = await getFeeGoal();
    final currentMonthFees = await TransactionFeeTrackingService.getCurrentMonthFees();
    final monthlyTotal = currentMonthFees.fold(0.0, (sum, fee) => sum + fee.feeAmount);
    final overage = monthlyTotal - (goal ?? 0);
    
    return CoachingIntervention(
      id: _generateId(),
      type: InterventionType.warning,
      trigger: InterventionTrigger.budgetExceeded,
      title: 'Fee Goal Exceeded! ⚠️',
      message: 'You\'ve exceeded your monthly fee goal by Ksh ${overage.toStringAsFixed(0)}. Consider using cheaper payment methods for the rest of the month.',
      actions: ['Adjust goal', 'See alternatives', 'Review spending', 'Dismiss'],
      context: {
        'goal_amount': goal,
        'actual_amount': monthlyTotal,
        'overage': overage,
        'intervention_type': 'fee_goal_exceeded',
      },
      createdAt: DateTime.now(),
      priority: 8,
    );
  }

  // Get fee optimization tips
  static Future<List<String>> getFeeOptimizationTips() async {
    final analytics = await TransactionFeeTrackingService.calculateFeeAnalytics();
    final tips = <String>[];
    
    // Analyze user's payment patterns
    final mpesaFees = analytics.feesByPaymentMethod[PaymentMethod.mpesa] ?? 0.0;
    final cardFees = analytics.feesByPaymentMethod[PaymentMethod.cardPayment] ?? 0.0;
    final bankFees = analytics.feesByPaymentMethod[PaymentMethod.bankTransfer] ?? 0.0;
    
    if (mpesaFees > analytics.totalFees * 0.5) {
      tips.add('Consider using bank transfers for amounts over Ksh 50,000 to reduce M-Pesa fees');
    }
    
    if (cardFees > analytics.totalFees * 0.3) {
      tips.add('Use M-Pesa or bank transfers instead of cards for small transactions');
    }
    
    if (bankFees < analytics.totalFees * 0.2) {
      tips.add('Try using bank transfers more often - they often have lower fees for larger amounts');
    }
    
    // General tips
    tips.addAll([
      'Batch small transactions together to reduce total fees',
      'Use cash for very small amounts (under Ksh 100)',
      'Plan large transactions to avoid multiple fee charges',
      'Consider PesaLink for bank-to-bank transfers',
      'Check if your bank offers fee-free transactions for certain amounts',
    ]);
    
    return tips.take(5).toList();
  }

  // Generate unique ID
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(1000).toString();
  }
}
