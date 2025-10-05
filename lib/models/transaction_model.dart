/// Transaction model for SMS-based transactions
class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String recipient;
  final String description;
  final String category;
  final DateTime date;
  final String source;
  final bool isProcessed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? transactionCharge; // M-PESA transaction charge
  final String? chargeDescription; // Description of the charge

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.recipient,
    required this.description,
    required this.category,
    required this.date,
    required this.source,
    required this.isProcessed,
    required this.createdAt,
    required this.updatedAt,
    this.transactionCharge,
    this.chargeDescription,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'amount': amount,
      'recipient': recipient,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
      'source': source,
      'isProcessed': isProcessed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'transactionCharge': transactionCharge,
      'chargeDescription': chargeDescription,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => TransactionType.expense,
      ),
      amount: (json['amount'] ?? 0).toDouble(),
      recipient: json['recipient'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Other',
      date: DateTime.parse(json['date']),
      source: json['source'] ?? 'Unknown',
      isProcessed: json['isProcessed'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      transactionCharge: json['transactionCharge']?.toDouble(),
      chargeDescription: json['chargeDescription'],
    );
  }
}

/// Transaction types
enum TransactionType {
  income,
  expense,
}
