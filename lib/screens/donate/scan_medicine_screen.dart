import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/ocr_service.dart';
import '../../core/medicine_parser.dart'; // ✅ UPDATED PATH

class ScanMedicineScreen extends StatefulWidget {
  static const String routeName = '/scan-medicine';

  const ScanMedicineScreen({super.key});

  @override
  State<ScanMedicineScreen> createState() => _ScanMedicineScreenState();
}

class _ScanMedicineScreenState extends State<ScanMedicineScreen> {
  File? _image;
  bool _loading = false;

  Future<void> _pickImage() async {
    // ❌ Camera OCR does not work on Web
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera OCR works only on mobile devices'),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    setState(() {
      _image = file;
      _loading = true;
    });

    // 🔍 OCR SCAN
    final rawText = await OcrService.scanImage(file);

    // 🧠 PARSE TEXT
    final medicineName =
        MedicineParser.extractMedicineName(rawText);

    final expiryDate =
        MedicineParser.extractExpiryDate(rawText);

    setState(() {
      _loading = false;
    });

    // 🚀 Navigate with extracted data
    Navigator.pushNamed(
      context,
      '/add-medicine',
      arguments: {
        'name': medicineName,
        'expiry': expiryDate,
        'image': file,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Medicine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize: 80,
              icon: const Icon(Icons.camera_alt),
              onPressed: _pickImage,
            ),
            const SizedBox(height: 20),
            if (_loading) const CircularProgressIndicator(),
            if (_image != null && !_loading)
              Image.file(
                _image!,
                height: 200,
                fit: BoxFit.contain,
              ),
          ],
        ),
      ),
    );
  }
}