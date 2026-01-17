// ============================================
// FIXED VERSION - All errors resolved
// ============================================

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

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

  final FirestoreService _firestore = FirestoreService();
  final ImagePicker _picker = ImagePicker();

  File? _image;
  bool _loading = false;
  bool _scanning = false;
  String _debugOcrText = '';

  Future<void> _scanMedicine() async {
    if (kIsWeb) {
      if (!mounted) return;
      showSnack(context, 'OCR scanning works on mobile only for now');
      return;
    }

    try {
      // Request camera permission
      final PermissionStatus cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        final PermissionStatus permission = await Permission.camera.request();
        if (!permission.isGranted) {
          if (!mounted) return;
          showSnack(context, 'Camera permission is required to scan medicines');
          return;
        }
      }

      setState(() => _scanning = true);

      final XFile? picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (picked == null) {
        setState(() => _scanning = false);
        return;
      }

      final File file = File(picked.path);
      
      setState(() {
        _image = file;
        _loading = true;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      try {
        final String ocrText = await OcrService.scanImage(file);
        
        if (!mounted) return;
        
        setState(() {
          _debugOcrText = ocrText;
        });

        await _extractMedicineDetails(ocrText);
      } catch (e) {
        if (!mounted) return;
        showSnack(context, 'OCR failed. Please try again or enter manually.');
        debugPrint('OCR Error: $e');
      }
    } catch (e) {
      if (!mounted) return;
      showSnack(context, 'Camera error. Please try again.');
      debugPrint('Camera Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _scanning = false;
        });
      }
    }
  }

  Future<void> _extractMedicineDetails(String text) async {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const AlertDialog(
        title: Text('Processing Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Extracting medicine details...'),
          ],
        ),
      ),
    );

    try {
      final Map<String, String> details = OcrService.extractMedicineDetails(text);
      
      if (!mounted) return;
      Navigator.pop(context);

      bool foundName = false;
      bool foundExpiry = false;

      // FIXED: Use setState to update the UI
      setState(() {
        if (details['name']!.isNotEmpty && _name.text.isEmpty) {
          _name.text = details['name']!;
          foundName = true;
        }
        
        if (details['expiry']!.isNotEmpty && _expiry.text.isEmpty) {
          _expiry.text = details['expiry']!;
          foundExpiry = true;
        }
      });
      
      if (details['name']!.isEmpty && details['expiry']!.isEmpty) {
        showSnack(context, 'Could not extract info. Please enter manually.');
      } else {
        final List<String> extracted = [];
        if (foundName) extracted.add('Medicine Name');
        if (foundExpiry) extracted.add('Expiry Date');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Successfully extracted ${extracted.join(" & ")}'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      showSnack(context, 'Error processing results');
    }
  }

  Future<void> _onDonate() async {
    if (_name.text.trim().isEmpty) {
      showSnack(context, 'Please enter medicine name');
      return;
    }

    if (_expiry.text.trim().isNotEmpty) {
      final RegExp expiryRegex = RegExp(r'^(0[1-9]|1[0-2])/\d{4}$');
      if (!expiryRegex.hasMatch(_expiry.text.trim())) {
        showSnack(context, 'Please enter expiry date in MM/YYYY format');
        return;
      }
    }

    final int? quantity = int.tryParse(_qty.text);
    if (quantity == null || quantity <= 0) {
      showSnack(context, 'Please enter valid quantity');
      return;
    }

    setState(() => _loading = true);

    // FIXED: Create MedicineModel object with all required fields
    final MedicineModel med = MedicineModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _name.text.trim(),
      expiry: _expiry.text.trim().isEmpty ? 'N/A' : _expiry.text.trim(),
      quantity: quantity,
      latitude: 18.5204,
      longitude: 73.8567,
      type: 'donation',
      verified: false,
      createdAt: DateTime.now(), // ADDED: Required createdAt field
    );

    try {
      // Save to Firestore - pass the model directly
      await _firestore.addMedicine(med);

      if (!mounted) return;

      setState(() => _loading = false);

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Thank you!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your medicine donation has been recorded.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      if (mounted) {
        _name.clear();
        _expiry.clear();
        _qty.text = '1';
        setState(() {
          _image = null;
          _debugOcrText = '';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showSnack(context, 'Error: ${e.toString()}');
      debugPrint('Donate Error: $e');
    }
  }

  void _showDebugDialog() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.bug_report, color: Colors.blue),
            SizedBox(width: 8),
            Text('OCR Debug - Raw Text'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_debugOcrText.isEmpty)
                  const Text('No OCR text available. Scan a medicine first.')
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: SelectableText(
                      _debugOcrText,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 16),
                if (_debugOcrText.isNotEmpty)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showExtractedDetails();
                    },
                    child: const Text('View Extracted Details'),
                  ),
              ],
            ),
          ),
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

  void _showExtractedDetails() {
    final Map<String, String> details = OcrService.extractMedicineDetails(_debugOcrText);
    
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Extracted Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Medicine Name:', details['name'] ?? 'Not found'),
            const SizedBox(height: 8),
            _buildDetailRow('Expiry Date:', details['expiry'] ?? 'Not found'),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Current Form Values:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            _buildDetailRow('Name field:', _name.text),
            _buildDetailRow('Expiry field:', _expiry.text),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: value.isEmpty ? Colors.grey : Colors.black,
                fontFamily: value.isEmpty ? null : 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.blue.shade800;
    final Color hintColor = Colors.grey.shade600;
    final Color blue50 = Colors.blue.shade50;
    final Color blue200 = Colors.blue.shade200;
    final Color blue700 = Colors.blue.shade700;
    final Color amber700 = Colors.amber.shade700;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Donate Medicine',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 1,
        actions: [
          if (_debugOcrText.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.bug_report),
              onPressed: _showDebugDialog,
              tooltip: 'View OCR debug info',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: blue50,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Text(
                    'Scan Medicine Label',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                      onPressed: _scanning ? null : _scanMedicine,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      icon: _scanning
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.camera_alt, size: 20),
                      label: Text(
                        _scanning ? 'Scanning...' : 'Use Camera',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_image != null) ...[
                      Container(
                        height: 200,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: blue200, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              Image.file(
                                _image!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              if (_loading)
                                Container(
                                  color: Colors.black.withAlpha(128),
                                  child: const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(color: Colors.white),
                                        SizedBox(height: 12),
                                        Text(
                                          'Processing Image...',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb_outline, color: amber700),
                                const SizedBox(width: 8),
                                const Text(
                                  'Scanning Tips',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildTip('📸 Hold camera steady, avoid blur'),
                            _buildTip('💡 Good lighting improves accuracy'),
                            _buildTip('🎯 Focus on medicine name & expiry'),
                            _buildTip('📄 Keep medicine label flat'),
                            _buildTip('⚡ Avoid shadows and reflections'),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Medicine Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enter details manually or scan to auto-fill',
                      style: TextStyle(
                        fontSize: 13,
                        color: hintColor,
                      ),
                    ),

                    const SizedBox(height: 20),
                    TextField(
                      controller: _name,
                      decoration: InputDecoration(
                        labelText: 'Medicine Name *',
                        hintText: 'e.g., Paracetamol 500mg',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.medication, color: Colors.blue),
                        suffixIcon: _name.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _name.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 16),
                    TextField(
                      controller: _expiry,
                      decoration: InputDecoration(
                        labelText: 'Expiry Date (MM/YYYY)',
                        hintText: 'e.g., 12/2026',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.calendar_today, color: Colors.blue),
                        suffixIcon: _expiry.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _expiry.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      keyboardType: TextInputType.datetime,
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 16),
                    TextField(
                      controller: _qty,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        hintText: 'Number of tablets/strips',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.numbers, color: Colors.blue),
                        suffixIcon: _qty.text != '1'
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _qty.text = '1';
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 32),
                    Card(
                      color: Colors.green.shade50,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.green.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.green.shade700),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Your donated medicine will appear in the "Available Medicines" section for others to request.',
                                style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    _loading
                        ? Center(
                            child: Column(
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(
                                  'Submitting donation...',
                                  style: TextStyle(
                                    color: hintColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _onDonate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.medical_services, size: 22),
                                  SizedBox(width: 10),
                                  Text(
                                    'DONATE MEDICINE',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Fields marked with * are required',
                        style: TextStyle(
                          fontSize: 12,
                          color: hintColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 28),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
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