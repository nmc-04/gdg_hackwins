// Stubbed Firestore service - replace with cloud_firestore later
import '../models/medicine_model.dart';

class FirestoreService {
  final List<MedicineModel> _demoStore = [];

  Future<void> addMedicine(MedicineModel med) async {
    _demoStore.add(med);
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<List<MedicineModel>> getAllMedicines() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _demoStore;
  }
}
