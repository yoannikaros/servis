class Transaction {
  final int? id;
  final int? depositedItemId;
  final String type;
  final double amount;
  final String? category;
  final String? description;
  final String transactionDate;

  Transaction({
    this.id,
    this.depositedItemId,
    required this.type,
    required this.amount,
    this.category,
    this.description,
    required this.transactionDate,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      depositedItemId: map['deposited_item_id'],
      type: map['type'],
      amount: map['amount'],
      category: map['category'],
      description: map['description'],
      transactionDate: map['transaction_date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deposited_item_id': depositedItemId,
      'type': type,
      'amount': amount,
      'category': category,
      'description': description,
      'transaction_date': transactionDate,
    };
  }
}
