import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets/primary_button.dart';
import '../../models/medicine_model.dart';
import '../../services/firestore_service.dart';
import '../../services/ocr_service.dart';
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
  final _picker = ImagePicker();

  File? _image;
  bool _loading = false;

  /// ---------- CAMERA + OCR ----------
  Future<void> _scanMedicine() async {
    if (kIsWeb) {
      showSnack(context, 'OCR scanning works on mobile only for now');
      return;
    }

    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;

    setState(() {
      _image = File(picked.path);
      _loading = true;
    });

    final ocrText = await OcrService.scanImage(_image!);
    _extractMedicineDetails(ocrText);

    setState(() => _loading = false);
  }

  /// ---------- SIMPLE OCR PARSER ----------
  void _extractMedicineDetails(String text) {
    final lines = text.split('\n');

    if (_name.text.isEmpty && lines.isNotEmpty) {
      _name.text = lines.first;
    }

    final expMatch =
        RegExp(r'(EXP|Exp|Expiry)[:\s]*(\d{2}/\d{2,4})')
            .firstMatch(text);

    if (expMatch != null) {
      _expiry.text = expMatch.group(2)!;
    }
  }

  /// ---------- DONATE ----------
  Future<void> _onDonate() async {
    if (_name.text.isEmpty) {
      showSnack(context, 'Enter medicine name');
      return;
    }

    setState(() => _loading = true);

    final med = MedicineModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _name.text,
      expiry: _expiry.text.isEmpty ? 'N/A' : _expiry.text,
      quantity: int.tryParse(_qty.text) ?? 1,

      /// placeholders for now
      latitude: 0.0,
      longitude: 0.0,
      type: 'donation',
    );

    await _firestore.addMedicine(med);

    if (!mounted) return;

    setState(() => _loading = false);

    showSnack(context, 'Medicine added successfully');
    Navigator.pushNamed(context, '/donate_success');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _scanMedicine,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_image != null)
                Container(
                  height: 180,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(_image!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Medicine name'),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _expiry,
                decoration:
                    const InputDecoration(labelText: 'Expiry (MM/YYYY)'),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _qty,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              const SizedBox(height: 24),

              _loading
                  ? const CircularProgressIndicator()
                  : PrimaryButton(
                      label: 'Donate',
                      onPressed: _onDonate,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}