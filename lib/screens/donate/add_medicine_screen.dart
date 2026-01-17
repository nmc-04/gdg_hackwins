// add_medicine_screen.dart - FIXED VERSION
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AddMedicineScreen extends StatefulWidget {
  static const routeName = '/add-medicine';
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _nameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');

  File? _image;
  bool _loading = false;
  bool _dataReceived = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Receive data only once
    if (!_dataReceived) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      
      if (args != null) {
        debugPrint('📦 Received scan data: $args');
        
        // Set medicine name
        if (args['name'] != null && args['name'].toString().isNotEmpty) {
          setState(() {
            _nameController.text = args['name'];
          });
          debugPrint('✅ Set medicine name: ${args['name']}');
        }
        
        // Set expiry date
        if (args['expiry'] != null && args['expiry'].toString().isNotEmpty) {
          setState(() {
            _expiryController.text = args['expiry'];
          });
          debugPrint('✅ Set expiry date: ${args['expiry']}');
        }
        
        // Set image
        if (args['image'] != null) {
          setState(() {
            _image = args['image'] as File;
          });
          debugPrint('✅ Set medicine image');
        }
        
        _dataReceived = true;
      }
    }
  }

  Future<void> _scanMedicine() async {
    if (kIsWeb) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OCR scanning works on mobile only')),
      );
      return;
    }

    try {
      // Navigate to scan screen and wait for result
      final result = await Navigator.pushNamed(context, '/scan-medicine');
      
      debugPrint('🔙 Returned from scan screen with result: $result');
      
      // Handle result from scan screen
      if (result != null && result is Map<String, dynamic>) {
        debugPrint('📦 Processing scan result: $result');
        
        if (result['name'] != null && result['name'].toString().isNotEmpty) {
          setState(() {
            _nameController.text = result['name'];
          });
          debugPrint('✅ Updated medicine name: ${result['name']}');
        }
        
        if (result['expiry'] != null && result['expiry'].toString().isNotEmpty) {
          setState(() {
            _expiryController.text = result['expiry'];
          });
          debugPrint('✅ Updated expiry date: ${result['expiry']}');
        }
        
        if (result['image'] != null) {
          setState(() {
            _image = result['image'] as File;
          });
          debugPrint('✅ Updated medicine image');
        }
        
        // Show success message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  result['name'] != null && result['name'].toString().isNotEmpty
                      ? 'Scan complete! Details auto-filled'
                      : 'Scan complete! Please enter details manually',
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
    } catch (e) {
      debugPrint('❌ Scan error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _submitForm() async {
    // Validation
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter medicine name')),
      );
      return;
    }

    if (_expiryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter expiry date')),
      );
      return;
    }

    // Validate expiry format MM/YYYY
    final expiryPattern = RegExp(r'^(0[1-9]|1[0-2])/\d{4}$');
    if (!expiryPattern.hasMatch(_expiryController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expiry date must be in MM/YYYY format')),
      );
      return;
    }

    final qty = int.tryParse(_qtyController.text);
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid quantity')),
      );
      return;
    }

    setState(() => _loading = true);

    // Simulate saving to database
    await Future.delayed(const Duration(seconds: 2));

    debugPrint('💾 Saving medicine:');
    debugPrint('Name: ${_nameController.text}');
    debugPrint('Expiry: ${_expiryController.text}');
    debugPrint('Quantity: ${_qtyController.text}');

    if (!mounted) return;

    setState(() => _loading = false);

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
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
              'Success!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your medicine donation has been recorded successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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

    // Clear form
    _nameController.clear();
    _expiryController.clear();
    _qtyController.text = '1';
    setState(() {
      _image = null;
      _dataReceived = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _expiryController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Donate Medicine',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scan Section
            Container(
              color: Colors.blue.shade50,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    size: 48,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Scan Medicine Package',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Auto-fill details by scanning medicine label',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                      onPressed: _scanMedicine,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Scan Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Form Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Preview
                    if (_image != null) ...[
                      Container(
                        height: 200,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200, width: 2),
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
                          child: Image.file(
                            _image!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],

                    // Tips Card
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
                                Icon(Icons.lightbulb_outline, color: Colors.amber.shade700),
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
                            _buildTip('💡 Use good lighting for accuracy'),
                            _buildTip('🎯 Focus on name & expiry date'),
                            _buildTip('📄 Keep label flat and clear'),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Form Fields
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
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Medicine Name
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Medicine Name *',
                        hintText: 'e.g., Paracetamol 500mg',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.medication, color: Colors.blue),
                        suffixIcon: _nameController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _nameController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 16),

                    // Expiry Date
                    TextField(
                      controller: _expiryController,
                      decoration: InputDecoration(
                        labelText: 'Expiry Date (MM/YYYY) *',
                        hintText: 'e.g., 12/2026',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.calendar_today, color: Colors.blue),
                        suffixIcon: _expiryController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _expiryController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      keyboardType: TextInputType.datetime,
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 16),

                    // Quantity
                    TextField(
                      controller: _qtyController,
                      decoration: InputDecoration(
                        labelText: 'Quantity *',
                        hintText: 'Number of tablets/strips',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.numbers, color: Colors.blue),
                      ),
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 32),

                    // Info Card
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
                                'Your donated medicine will be available for others to request.',
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

                    // Submit Button
                    _loading
                        ? const Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text(
                                  'Submitting donation...',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
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
                          color: Colors.grey.shade600,
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
}