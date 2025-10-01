import 'package:flutter/material.dart';
import '../services/transaction_fee_tracking_service.dart';

class FeeCalculatorWidget extends StatefulWidget {
  final Function(double amount, PaymentMethod method, String transactionType, double fee)? onFeeCalculated;
  final bool showPaymentMethodSelector;
  final bool showTransactionTypeSelector;
  final double? initialAmount;
  final PaymentMethod? initialPaymentMethod;
  final String? initialTransactionType;

  const FeeCalculatorWidget({
    super.key,
    this.onFeeCalculated,
    this.showPaymentMethodSelector = true,
    this.showTransactionTypeSelector = true,
    this.initialAmount,
    this.initialPaymentMethod,
    this.initialTransactionType,
  });

  @override
  State<FeeCalculatorWidget> createState() => _FeeCalculatorWidgetState();
}

class _FeeCalculatorWidgetState extends State<FeeCalculatorWidget> {
  final TextEditingController _amountController = TextEditingController();
  PaymentMethod _selectedPaymentMethod = PaymentMethod.mpesa;
  String _selectedTransactionType = 'send_money';
  double _calculatedFee = 0.0;
  bool _isCalculating = false;

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod.mpesa,
    PaymentMethod.bankTransfer,
    PaymentMethod.cardPayment,
    PaymentMethod.mobileBanking,
    PaymentMethod.pesaLink,
    PaymentMethod.cash,
    PaymentMethod.airtime,
  ];

  final List<Map<String, String>> _transactionTypes = [
    {'value': 'send_money', 'label': 'Send Money'},
    {'value': 'buy_goods', 'label': 'Buy Goods'},
    {'value': 'pay_bills', 'label': 'Pay Bills'},
    {'value': 'withdraw', 'label': 'Withdraw'},
    {'value': 'airtime', 'label': 'Buy Airtime'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null) {
      _amountController.text = widget.initialAmount!.toString();
    }
    if (widget.initialPaymentMethod != null) {
      _selectedPaymentMethod = widget.initialPaymentMethod!;
    }
    if (widget.initialTransactionType != null) {
      _selectedTransactionType = widget.initialTransactionType!;
    }
    _calculateFee();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculateFee() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount > 0) {
      setState(() {
        _isCalculating = true;
      });
      
      final fee = TransactionFeeTrackingService.calculateFee(
        amount,
        _selectedPaymentMethod,
        _selectedTransactionType,
      );
      
      setState(() {
        _calculatedFee = fee;
        _isCalculating = false;
      });
      
      widget.onFeeCalculated?.call(amount, _selectedPaymentMethod, _selectedTransactionType, fee);
    } else {
      setState(() {
        _calculatedFee = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.calculate,
                  color: const Color(0xFFEE2B8D),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Fee Calculator',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF181114),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Amount Input
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Transaction Amount (Ksh)',
                hintText: 'Enter amount',
                prefixIcon: const Icon(Icons.money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEE2B8D), width: 2),
                ),
              ),
              onChanged: (value) => _calculateFee(),
            ),
            
            const SizedBox(height: 16),
            
            // Payment Method Selector
            if (widget.showPaymentMethodSelector) ...[
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF181114),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<PaymentMethod>(
                  value: _selectedPaymentMethod,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _paymentMethods.map((method) {
                    return DropdownMenuItem<PaymentMethod>(
                      value: method,
                      child: Row(
                        children: [
                          Icon(
                            _getPaymentMethodIcon(method),
                            color: _getPaymentMethodColor(method),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(_getPaymentMethodName(method)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                      _calculateFee();
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Transaction Type Selector
            if (widget.showTransactionTypeSelector && _selectedPaymentMethod == PaymentMethod.mpesa) ...[
              const Text(
                'Transaction Type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF181114),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: _selectedTransactionType,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _transactionTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type['value'],
                      child: Text(type['label']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedTransactionType = value;
                      });
                      _calculateFee();
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Fee Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _calculatedFee > 0 ? Colors.red[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _calculatedFee > 0 ? Colors.red[200]! : Colors.green[200]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _calculatedFee > 0 ? Icons.warning : Icons.check_circle,
                    color: _calculatedFee > 0 ? Colors.red : Colors.green,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _calculatedFee > 0 ? 'Transaction Fee' : 'No Fee',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _calculatedFee > 0 ? Colors.red[800] : Colors.green[800],
                          ),
                        ),
                        if (_calculatedFee > 0) ...[
                          Text(
                            'Ksh ${_calculatedFee.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${((_calculatedFee / (double.tryParse(_amountController.text) ?? 1)) * 100).toStringAsFixed(2)}% of transaction',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[600],
                            ),
                          ),
                        ] else ...[
                          Text(
                            'This transaction has no fees',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_isCalculating)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Fee Breakdown (for M-Pesa)
            if (_selectedPaymentMethod == PaymentMethod.mpesa && _calculatedFee > 0) ...[
              const Text(
                'M-Pesa Fee Structure',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF181114),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getMpesaFeeExplanation(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getMpesaFeeExplanation() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final transactionType = _selectedTransactionType;
    
    String explanation = 'M-Pesa ${_getTransactionTypeName(transactionType)} fees:\n\n';
    
    if (amount <= 100) {
      explanation += '• Ksh 0 - 100: Free';
    } else if (amount <= 500) {
      explanation += '• Ksh 101 - 500: Ksh 11';
    } else if (amount <= 1000) {
      explanation += '• Ksh 501 - 1,000: Ksh 15';
    } else if (amount <= 1500) {
      explanation += '• Ksh 1,001 - 1,500: Ksh 25';
    } else if (amount <= 2500) {
      explanation += '• Ksh 1,501 - 2,500: Ksh 29';
    } else if (amount <= 3500) {
      explanation += '• Ksh 2,501 - 3,500: Ksh 37';
    } else if (amount <= 5000) {
      explanation += '• Ksh 3,501 - 5,000: Ksh 55';
    } else if (amount <= 7500) {
      explanation += '• Ksh 5,001 - 7,500: Ksh 60';
    } else if (amount <= 10000) {
      explanation += '• Ksh 7,501 - 10,000: Ksh 75';
    } else if (amount <= 15000) {
      explanation += '• Ksh 10,001 - 15,000: Ksh 85';
    } else if (amount <= 20000) {
      explanation += '• Ksh 15,001 - 20,000: Ksh 95';
    } else if (amount <= 35000) {
      explanation += '• Ksh 20,001 - 35,000: Ksh 100';
    } else if (amount <= 50000) {
      explanation += '• Ksh 35,001 - 50,000: Ksh 110';
    } else if (amount <= 70000) {
      explanation += '• Ksh 50,001 - 70,000: Ksh 150';
    } else if (amount <= 100000) {
      explanation += '• Ksh 70,001 - 100,000: Ksh 200';
    } else if (amount <= 150000) {
      explanation += '• Ksh 100,001 - 150,000: Ksh 250';
    } else if (amount <= 200000) {
      explanation += '• Ksh 150,001 - 200,000: Ksh 300';
    } else if (amount <= 300000) {
      explanation += '• Ksh 200,001 - 300,000: Ksh 350';
    } else if (amount <= 500000) {
      explanation += '• Ksh 300,001 - 500,000: Ksh 500';
    } else if (amount <= 700000) {
      explanation += '• Ksh 500,001 - 700,000: Ksh 750';
    } else if (amount <= 1000000) {
      explanation += '• Ksh 700,001 - 1,000,000: Ksh 1,000';
    } else {
      explanation += '• Above Ksh 1,000,000: Ksh 1,500';
    }
    
    return explanation;
  }

  String _getTransactionTypeName(String type) {
    switch (type) {
      case 'send_money':
        return 'Send Money';
      case 'buy_goods':
        return 'Buy Goods';
      case 'pay_bills':
        return 'Pay Bills';
      case 'withdraw':
        return 'Withdraw';
      case 'airtime':
        return 'Airtime';
      default:
        return 'Transaction';
    }
  }

  String _getPaymentMethodName(PaymentMethod method) {
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

  Color _getPaymentMethodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.mpesa:
        return Colors.orange;
      case PaymentMethod.bankTransfer:
        return Colors.blue;
      case PaymentMethod.cardPayment:
        return Colors.purple;
      case PaymentMethod.cash:
        return Colors.green;
      case PaymentMethod.mobileBanking:
        return Colors.teal;
      case PaymentMethod.pesaLink:
        return Colors.indigo;
      case PaymentMethod.airtime:
        return Colors.pink;
      case PaymentMethod.other:
        return Colors.grey;
    }
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.mpesa:
        return Icons.phone_android;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.cardPayment:
        return Icons.credit_card;
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.mobileBanking:
        return Icons.mobile_friendly;
      case PaymentMethod.pesaLink:
        return Icons.link;
      case PaymentMethod.airtime:
        return Icons.signal_cellular_alt;
      case PaymentMethod.other:
        return Icons.payment;
    }
  }
}

