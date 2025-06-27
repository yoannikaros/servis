class DepositedItem {
  final int? id;
  final int customerId;
  final String itemName;
  final String? brand;
  final String? model;
  final String? serialNumber;
  final String receivedDate;
  final String? complaint;
  final String status;
  final double? estimatedCost;
  final double? finalCost;
  final String? pickupDate;
  final String? technician;
  final String? notes;

  DepositedItem({
    this.id,
    required this.customerId,
    required this.itemName,
    this.brand,
    this.model,
    this.serialNumber,
    required this.receivedDate,
    this.complaint,
    this.status = 'waiting',
    this.estimatedCost,
    this.finalCost,
    this.pickupDate,
    this.technician,
    this.notes,
  });

  factory DepositedItem.fromMap(Map<String, dynamic> map) {
    return DepositedItem(
      id: map['id'],
      customerId: map['customer_id'],
      itemName: map['item_name'],
      brand: map['brand'],
      model: map['model'],
      serialNumber: map['serial_number'],
      receivedDate: map['received_date'],
      complaint: map['complaint'],
      status: map['status'],
      estimatedCost: map['estimated_cost'],
      finalCost: map['final_cost'],
      pickupDate: map['pickup_date'],
      technician: map['technician'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'item_name': itemName,
      'brand': brand,
      'model': model,
      'serial_number': serialNumber,
      'received_date': receivedDate,
      'complaint': complaint,
      'status': status,
      'estimated_cost': estimatedCost,
      'final_cost': finalCost,
      'pickup_date': pickupDate,
      'technician': technician,
      'notes': notes,
    };
  }
}
