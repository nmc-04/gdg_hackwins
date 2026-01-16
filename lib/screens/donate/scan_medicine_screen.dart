import 'dart:io';
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final file = File(pickedFile.path);

      setState(() {
        _image = file;
        _recognizedText = "Processing...";
      });

      final text = await OcrService.recognizeText(file);

      setState(() {
        _recognizedText = text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Medicine")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Scan Medicine Image"),
            ),
            const SizedBox(height: 20),
            if (_image != null)
              Image.file(_image!, height: 200),
            const SizedBox(height: 20),
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
