class Saving {
  final int? id;
  final String type;
  final double amount;
  final String? description;
  final String date;

  Saving({
    this.id,
    required this.type,
    required this.amount,
    this.description,
    required this.date,
  });

  factory Saving.fromMap(Map<String, dynamic> map) {
    return Saving(
      id: map['id'],
      type: map['type'],
      amount: map['amount'],
      description: map['description'],
      date: map['date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'description': description,
      'date': date,
    };
  }
}
