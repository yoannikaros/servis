class Setting {
  final int? id;
  final String? businessName;
  final String? noteHeader;
  final String? noteFooter;
  final String? updatedAt;

  Setting({
    this.id,
    this.businessName,
    this.noteHeader,
    this.noteFooter,
    this.updatedAt,
  });

  factory Setting.fromMap(Map<String, dynamic> map) {
    return Setting(
      id: map['id'],
      businessName: map['business_name'],
      noteHeader: map['note_header'],
      noteFooter: map['note_footer'],
      updatedAt: map['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_name': businessName,
      'note_header': noteHeader,
      'note_footer': noteFooter,
      'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
    };
  }
}
