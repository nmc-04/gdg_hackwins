import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/ocr_service.dart';

class ScanMedicineScreen extends StatefulWidget {
  static const String routeName = '/scan-medicine';

  const ScanMedicineScreen({super.key});

  @override
  State<ScanMedicineScreen> createState() => _ScanMedicineScreenState();
}

class _ScanMedicineScreenState extends State<ScanMedicineScreen> {
  File? _image;
  String _recognizedText = "";
  bool _loading = false;

  Future<void> _pickImage() async {
    // ❌ OCR + Camera do NOT work on Web
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Camera OCR works only on mobile devices',
          ),
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
      _recognizedText = "Scanning...";
    });

    final text = await OcrService.scanImage(file);

    setState(() {
      _recognizedText = text;
      _loading = false;
    });

    // OPTIONAL: Navigate to AddMedicineScreen with OCR text
    Navigator.pushNamed(
      context,
      '/add_medicine',
      arguments: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Medicine")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            IconButton(
              iconSize: 80,
              icon: const Icon(Icons.camera_alt),
              onPressed: _pickImage,
            ),
            const SizedBox(height: 16),
            if (_loading) const CircularProgressIndicator(),
            if (_image != null && !_loading)
              Image.file(_image!, height: 200),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _recognizedText,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
