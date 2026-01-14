import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';
import '../../models/medicine_model.dart';
import '../../services/firestore_service.dart';
import '../../core/utils.dart';

class AddMedicineScreen extends StatefulWidget {
  static const routeName = '/add_medicine';
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _name = TextEditingController();
  final _expiry = TextEditingController();
  final _qty = TextEditingController(text: '1');
  final _firestore = FirestoreService();
  bool _loading = false;

  void _onDonate() async {
    if (_name.text.isEmpty) {
      showSnack(context, 'Enter medicine name');
      return;
    }
    setState(() => _loading = true);
    final med = MedicineModel(id: DateTime.now().millisecondsSinceEpoch.toString(), name: _name.text, expiry: _expiry.text.isEmpty ? 'N/A' : _expiry.text, quantity: int.tryParse(_qty.text) ?? 1);
    await _firestore.addMedicine(med);
    setState(() => _loading = false);
    showSnack(context, 'Added (prototype)');
    Navigator.pushNamed(context, '/donate_success');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text('Add Medicine', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Medicine name')),
            const SizedBox(height: 10),
            TextField(controller: _expiry, decoration: const InputDecoration(labelText: 'Expiry (MM/YYYY)')),
            const SizedBox(height: 10),
            TextField(controller: _qty, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
            const SizedBox(height: 18),
            _loading ? const CircularProgressIndicator() : PrimaryButton(label: 'Donate', onPressed: _onDonate),
          ],
        ),
      ),
    );
  }
}
