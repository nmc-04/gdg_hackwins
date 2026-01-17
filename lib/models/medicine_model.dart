// models/medicine_model.dart
class MedicineModel {
  final String id;
  final String name;
  final String expiry;
  final int quantity;
  
  /// Map-related
  final double latitude;
  final double longitude;
  
  /// donation / request / booked
  final String type;
  
  /// Verification status
  final bool verified;
  
  /// Status field
  final String status; // 'available', 'booked', 'completed'
  
  /// User references
  final String? donatedBy;
  final String? requestedBy;
  final String? bookedBy;
  
  /// Timestamps
  final DateTime createdAt;
  final DateTime? bookedAt;
  
  /// Image URL for scanned medicine
  final String? imageUrl;
  
  /// New fields for UI enhancements
  final String? donorName;
  final String? distance;
  final bool urgent;
  final String? donorRating;
  final String? description;
  final String? manufacturer;
  final String? dosage;
  final List<String>? images;

  MedicineModel({
    required this.id,
    required this.name,
    required this.expiry,
    required this.quantity,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.type = 'donation',
    this.verified = false,
    this.status = 'available',
    this.donatedBy,
    this.requestedBy,
    this.bookedBy,
    required this.createdAt,
    this.bookedAt,
    this.imageUrl,
    
    // New fields
    this.donorName,
    this.distance,
    this.urgent = false,
    this.donorRating,
    this.description,
    this.manufacturer,
    this.dosage,
    this.images,
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
      'verified': verified,
      'status': status,
      'donatedBy': donatedBy,
      'requestedBy': requestedBy,
      'bookedBy': bookedBy,
      'createdAt': createdAt.toIso8601String(),
      'bookedAt': bookedAt?.toIso8601String(),
      'imageUrl': imageUrl,
      'donorName': donorName,
      'distance': distance,
      'urgent': urgent,
      'donorRating': donorRating,
      'description': description,
      'manufacturer': manufacturer,
      'dosage': dosage,
      'images': images,
    };
  }

  factory MedicineModel.fromMap(Map<String, dynamic> map) {
    return MedicineModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      expiry: map['expiry'] ?? '',
      quantity: map['quantity'] ?? 0,
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      type: map['type'] ?? 'donation',
      verified: map['verified'] ?? false,
      status: map['status'] ?? 'available',
      donatedBy: map['donatedBy'],
      requestedBy: map['requestedBy'],
      bookedBy: map['bookedBy'],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      bookedAt: map['bookedAt'] != null 
          ? DateTime.parse(map['bookedAt']) 
          : null,
      imageUrl: map['imageUrl'],
      donorName: map['donorName'],
      distance: map['distance'],
      urgent: map['urgent'] ?? false,
      donorRating: map['donorRating'],
      description: map['description'],
      manufacturer: map['manufacturer'],
      dosage: map['dosage'],
      images: map['images'] != null 
          ? List<String>.from(map['images'])
          : null,
    );
  }
  
  /// Helper methods for easy access
  bool get isAvailable => status == 'available';
  bool get isBooked => status == 'booked';
  bool get isCompleted => status == 'completed';
  bool get isDonation => type == 'donation';
  bool get isRequest => type == 'request';
  
  /// Check if medicine is expiring soon (within 3 months)
  bool get isExpiringSoon {
    try {
      final parts = expiry.split('/');
      if (parts.length == 2) {
        final month = int.tryParse(parts[0]);
        final year = int.tryParse(parts[1]);
        if (month != null && year != null) {
          final expiryDate = DateTime(year, month);
          final now = DateTime.now();
          final threeMonthsFromNow = DateTime(now.year, now.month + 3);
          return expiryDate.isBefore(threeMonthsFromNow);
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Copy with method for immutability
  MedicineModel copyWith({
    String? id,
    String? name,
    String? expiry,
    int? quantity,
    double? latitude,
    double? longitude,
    String? type,
    bool? verified,
    String? status,
    String? donatedBy,
    String? requestedBy,
    String? bookedBy,
    DateTime? createdAt,
    DateTime? bookedAt,
    String? imageUrl,
    String? donorName,
    String? distance,
    bool? urgent,
    String? donorRating,
    String? description,
    String? manufacturer,
    String? dosage,
    List<String>? images,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      expiry: expiry ?? this.expiry,
      quantity: quantity ?? this.quantity,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      verified: verified ?? this.verified,
      status: status ?? this.status,
      donatedBy: donatedBy ?? this.donatedBy,
      requestedBy: requestedBy ?? this.requestedBy,
      bookedBy: bookedBy ?? this.bookedBy,
      createdAt: createdAt ?? this.createdAt,
      bookedAt: bookedAt ?? this.bookedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      donorName: donorName ?? this.donorName,
      distance: distance ?? this.distance,
      urgent: urgent ?? this.urgent,
      donorRating: donorRating ?? this.donorRating,
      description: description ?? this.description,
      manufacturer: manufacturer ?? this.manufacturer,
      dosage: dosage ?? this.dosage,
      images: images ?? this.images,
    );
  }
}