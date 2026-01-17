import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  donor,
  patient,
  pharmacy,
  ngo,
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  // Location for map & nearby alerts
  final double latitude;
  final double longitude;

  // Optional
  final String phone;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.latitude,
    required this.longitude,
    this.phone = '',
    this.isVerified = false,
  });

  /// Convert user to Firestore map
  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role.name,
        'latitude': latitude,
        'longitude': longitude,
        'phone': phone,
        'isVerified': isVerified,
      };

  /// Create user from Firestore snapshot
  factory UserModel.fromSnapshot(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.donor,
      ),
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      phone: map['phone'] ?? '',
      isVerified: map['isVerified'] ?? false,
    );
  }
}
