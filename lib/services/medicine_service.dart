// services/medicine_service.dart
import 'package:flutter/material.dart';
import '../models/medicine_model.dart';

class MedicineService with ChangeNotifier {
  List<MedicineModel> _medicines = [];
  List<MedicineModel> _myDonations = [];
  List<MedicineModel> _myRequests = [];

  List<MedicineModel> get medicines => _medicines;
  List<MedicineModel> get myDonations => _myDonations;
  List<MedicineModel> get myRequests => _myRequests;

  // Get available donations (not booked)
  List<MedicineModel> get availableDonations =>
      _medicines.where((m) => m.isDonation && m.isAvailable).toList();

  // Get available requests (not booked)
  List<MedicineModel> get availableRequests =>
      _medicines.where((m) => m.isRequest && m.isAvailable).toList();

  // Get booked medicines
  List<MedicineModel> get bookedMedicines =>
      _medicines.where((m) => m.isBooked).toList();

  // Initialize with dummy data
  MedicineService() {
    _initializeDummyData();
  }

  void _initializeDummyData() {
    _medicines = [
      MedicineModel(
        id: '1',
        name: 'Paracetamol 500mg',
        expiry: '12/2026',
        quantity: 2,
        latitude: 18.5204,
        longitude: 73.8567,
        type: 'donation',
        status: 'available',
        donatedBy: 'user1',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        verified: true,
      ),
      MedicineModel(
        id: '2',
        name: 'Insulin Injection',
        expiry: '06/2025',
        quantity: 1,
        latitude: 18.5304,
        longitude: 73.8667,
        type: 'donation',
        status: 'available',
        donatedBy: 'user2',
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        verified: false,
      ),
      MedicineModel(
        id: '3',
        name: 'Vitamin C 500mg',
        expiry: '08/2025',
        quantity: 3,
        latitude: 18.5404,
        longitude: 73.8767,
        type: 'donation',
        status: 'available',
        donatedBy: 'user3',
        createdAt: DateTime.now().subtract(Duration(days: 3)),
        verified: true,
      ),
      MedicineModel(
        id: '4',
        name: 'Amoxicillin 250mg',
        expiry: '11/2025',
        quantity: 5,
        latitude: 18.5504,
        longitude: 73.8867,
        type: 'request',
        status: 'available',
        requestedBy: 'patient1',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
      ),
      MedicineModel(
        id: '5',
        name: 'Metformin 500mg',
        expiry: '03/2026',
        quantity: 2,
        latitude: 18.5604,
        longitude: 73.8967,
        type: 'request',
        status: 'available',
        requestedBy: 'patient2',
        createdAt: DateTime.now().subtract(Duration(days: 2)),
      ),
    ];
    notifyListeners();
  }

  // Add a new donation (when user scans a medicine)
  Future<void> addDonation(MedicineModel medicine) async {
    // Set current user as donor (in real app, get from auth)
    final newMedicine = MedicineModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: medicine.name,
      expiry: medicine.expiry,
      quantity: medicine.quantity,
      latitude: medicine.latitude,
      longitude: medicine.longitude,
      type: 'donation',
      status: 'available',
      donatedBy: 'current_user_id', // Replace with actual user ID
      createdAt: DateTime.now(),
      verified: false,
      imageUrl: medicine.imageUrl,
    );

    _medicines.add(newMedicine);
    _myDonations.add(newMedicine);
    notifyListeners();
  }

  // Add a new request
  Future<void> addRequest(MedicineModel medicine) async {
    final newMedicine = MedicineModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: medicine.name,
      expiry: medicine.expiry,
      quantity: medicine.quantity,
      latitude: medicine.latitude,
      longitude: medicine.longitude,
      type: 'request',
      status: 'available',
      requestedBy: 'current_user_id', // Replace with actual user ID
      createdAt: DateTime.now(),
    );

    _medicines.add(newMedicine);
    _myRequests.add(newMedicine);
    notifyListeners();
  }

  // Book a medicine (patient requests a donation)
  Future<void> bookMedicine(String medicineId, String userId) async {
    final index = _medicines.indexWhere((m) => m.id == medicineId);
    if (index != -1 && _medicines[index].isAvailable) {
      _medicines[index] = MedicineModel(
        id: _medicines[index].id,
        name: _medicines[index].name,
        expiry: _medicines[index].expiry,
        quantity: _medicines[index].quantity,
        latitude: _medicines[index].latitude,
        longitude: _medicines[index].longitude,
        type: _medicines[index].type,
        status: 'booked',
        requestedBy: userId,
        donatedBy: _medicines[index].donatedBy,
        createdAt: _medicines[index].createdAt,
        bookedAt: DateTime.now(),
        verified: _medicines[index].verified,
        imageUrl: _medicines[index].imageUrl,
      );
      notifyListeners();
    }
  }

  // Complete a booking (medicine delivered)
  Future<void> completeBooking(String medicineId) async {
    final index = _medicines.indexWhere((m) => m.id == medicineId);
    if (index != -1) {
      _medicines.removeAt(index);
      notifyListeners();
    }
  }

  // Get medicines by type and status
  List<MedicineModel> getMedicinesByTypeAndStatus(String type, String status) {
    return _medicines
        .where((m) => m.type == type && m.status == status)
        .toList();
  }

  // Search medicines
  List<MedicineModel> searchMedicines(String query) {
    if (query.isEmpty) return availableDonations;
    return availableDonations
        .where((m) =>
            m.name.toLowerCase().contains(query.toLowerCase()) ||
            m.expiry.contains(query))
        .toList();
  }
}