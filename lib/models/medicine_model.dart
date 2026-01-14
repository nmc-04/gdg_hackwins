class MedicineModel {
  final String id;
  final String name;
  final String expiry;
  final int quantity;
  final bool verified;

  MedicineModel({
    required this.id,
    required this.name,
    required this.expiry,
    required this.quantity,
    this.verified = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'expiry': expiry,
        'quantity': quantity,
        'verified': verified,
      };

  factory MedicineModel.fromMap(Map<String, dynamic> map) {
    return MedicineModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      expiry: map['expiry'] ?? '',
      quantity: map['quantity'] ?? 0,
      verified: map['verified'] ?? false,
    );
  }
}
