import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String id;
  final String medicineNeeded;
  final double lat;
  final double lng;
  final bool fulfilled;

  RequestModel({
    required this.id,
    required this.medicineNeeded,
    required this.lat,
    required this.lng,
    required this.fulfilled,
  });

  factory RequestModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RequestModel(
      id: doc.id,
      medicineNeeded: data['medicineNeeded'],
      lat: data['lat'],
      lng: data['lng'],
      fulfilled: data['fulfilled'],
    );
  }
}
