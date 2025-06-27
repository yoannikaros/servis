class Purchase {
  final int? id;
  final String itemName;
  final String? category;
  final double? quantity;
  final double? unitPrice;
  final double? totalPrice;
  final String purchaseDate;
  final String? notes;

  Purchase({
    this.id,
    required this.itemName,
    this.category,
    this.quantity,
    this.unitPrice,
    this.totalPrice,
    required this.purchaseDate,
    this.notes,
  });

  factory Purchase.fromMap(Map<String, dynamic> map) {
    return Purchase(
      id: map['id'],
      itemName: map['item_name'],
      category: map['category'],
      quantity: map['quantity'],
      unitPrice: map['unit_price'],
      totalPrice: map['total_price'],
      purchaseDate: map['purchase_date'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_name': itemName,
      'category': category,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'purchase_date': purchaseDate,
      'notes': notes,
    };
  }
}
