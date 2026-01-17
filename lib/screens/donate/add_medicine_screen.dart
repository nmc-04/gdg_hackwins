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
  String _debugOcrText = '';

  /// ---------- IMPROVED CAMERA + OCR ----------
  Future<void> _scanMedicine() async {
    if (kIsWeb) {
      if (!mounted) return;
      showSnack(context, 'OCR scanning works on mobile only for now');
      return;
    }

    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,        // Reduced from 100 for faster processing
      maxWidth: 1920,          // Limit image size for better performance
      maxHeight: 1920,         // Limit image size for better performance
      preferredCameraDevice: CameraDevice.rear,
    );

    if (picked == null) return;
    if (!mounted) return;

    setState(() {
      _image = File(picked.path);
      _loading = true;
    });

    try {
      final ocrText = await OcrService.scanImage(_image!);
      
      if (!mounted) return;
      
      setState(() {
        _debugOcrText = ocrText;
      });

      _extractMedicineDetails(ocrText);
    } catch (e) {
      if (!mounted) return;
      showSnack(context, 'OCR failed: ${e.toString()}');
      print('OCR Error: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  /// ---------- IMPROVED OCR EXTRACTION ----------
  void _extractMedicineDetails(String text) {
    final details = OcrService.extractMedicineDetails(text);
    
    if (details['name']!.isNotEmpty && _name.text.isEmpty) {
      _name.text = details['name']!;
    }
    
    if (details['expiry']!.isNotEmpty && _expiry.text.isEmpty) {
      _expiry.text = details['expiry']!;
    }
    
    if (details['name']!.isEmpty && details['expiry']!.isEmpty) {
      showSnack(context, 'Could not extract info. Please enter manually.');
    } else {
      List<String> extracted = [];
      if (details['name']!.isNotEmpty) extracted.add('Name');
      if (details['expiry']!.isNotEmpty) extracted.add('Expiry');
      showSnack(context, 'Extracted: ${extracted.join(' & ')}');
    }
    
    print('=== OCR RAW TEXT ===');
    print(text);
    print('=== EXTRACTED DATA ===');
    print('Name: ${details['name']}');
    print('Expiry: ${details['expiry']}');
    print('==================');
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
      latitude: 0.0,
      longitude: 0.0,
      type: 'donation',
    );

    try {
      await _firestore.addMedicine(med);

      if (!mounted) return;

      setState(() => _loading = false);

      showSnack(context, 'Medicine added successfully');
      
      if (!mounted) return;
      
      Navigator.pushNamed(
        context,
        '/donate_success',
        arguments: {
          'latitude': 0.0,
          'longitude': 0.0,
          'type': 'donation',
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showSnack(context, 'Error: ${e.toString()}');
    }
  }

  /// ---------- SHOW DEBUG OCR TEXT ----------
  void _showDebugDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('OCR Debug - Raw Text'),
        content: SingleChildScrollView(
          child: SelectableText(_debugOcrText.isEmpty 
            ? 'No OCR text available. Scan a medicine first.' 
            : _debugOcrText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
            tooltip: 'Scan medicine',
          ),
          if (_debugOcrText.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.bug_report),
              onPressed: _showDebugDialog,
              tooltip: 'View OCR text',
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
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    image: DecorationImage(
                      image: FileImage(_image!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              Card(
                color: Colors.blue.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.blue.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, 
                            color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Scanning Tips',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTip('Good lighting (natural daylight works best)'),
                      _buildTip('Hold camera steady to avoid blur'),
                      _buildTip('Focus on medicine name & expiry date'),
                      _buildTip('Keep medicine pack flat'),
                      _buildTip('Avoid shadows and reflections'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: 'Medicine Name *',
                  hintText: 'e.g., Paracetamol 500mg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.medication),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _expiry,
                decoration: InputDecoration(
                  labelText: 'Expiry Date',
                  hintText: 'MM/YYYY',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _qty,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'Number of tablets/strips',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              _loading
                  ? Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 12),
                        Text(
                          'Processing...',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: PrimaryButton(
                        label: 'Donate Medicine',
                        onPressed: _onDonate,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Colors.blue.shade700, fontSize: 16)),
          Flexible(
            child: Text(
              text,
              style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _expiry.dispose();
    _qty.dispose();
    super.dispose();
  }
}