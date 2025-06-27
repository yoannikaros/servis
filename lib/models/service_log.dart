class ServiceLog {
  final int? id;
  final int depositedItemId;
  final String date;
  final String action;
  final String? componentUsed;
  final double? componentCost;
  final String? technician;
  final String? notes;

  ServiceLog({
    this.id,
    required this.depositedItemId,
    required this.date,
    required this.action,
    this.componentUsed,
    this.componentCost,
    this.technician,
    this.notes,
  });

  factory ServiceLog.fromMap(Map<String, dynamic> map) {
    return ServiceLog(
      id: map['id'],
      depositedItemId: map['deposited_item_id'],
      date: map['date'],
      action: map['action'],
      componentUsed: map['component_used'],
      componentCost: map['component_cost'],
      technician: map['technician'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deposited_item_id': depositedItemId,
      'date': date,
      'action': action,
      'component_used': componentUsed,
      'component_cost': componentCost,
      'technician': technician,
      'notes': notes,
    };
  }
}
