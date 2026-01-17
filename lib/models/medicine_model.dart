class MedicineModel {
  final String id;
  final String name;
  final String expiry;
  final int quantity;

  /// Map-related (future use)
  final double latitude;
  final double longitude;

  /// donation / request
  final String type;

  MedicineModel({
    required this.id,
    required this.name,
    required this.expiry,
    required this.quantity,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.type = 'donation',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'expiry': expiry,
      'quantity': quantity,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
    };
  }

  factory MedicineModel.fromMap(Map<String, dynamic> map) {
    return MedicineModel(
      id: map['id'],
      name: map['name'],
      expiry: map['expiry'],
      quantity: map['quantity'],
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      type: map['type'] ?? 'donation',
    );
  }
}