import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/ocr_service.dart';
import '../../core/medicine_parser.dart';

class ScanMedicineScreen extends StatefulWidget {
  static const String routeName = '/scan-medicine';

  const ScanMedicineScreen({super.key});

  @override
  State<ScanMedicineScreen> createState() => _ScanMedicineScreenState();
}

class _ScanMedicineScreenState extends State<ScanMedicineScreen> {
  File? _image;
  bool _loading = false;
  String _errorMessage = '';
  String _ocrDebugText = '';
  bool _showDebugInfo = false;

  Future<bool> _checkCameraPermission() async {
    if (kIsWeb) return true; // Web doesn't need camera permissions

    // Check camera permission status
    var status = await Permission.camera.status;
    
    if (!status.isGranted) {
      // Request permission
      status = await Permission.camera.request();
      
      if (!status.isGranted) {
        setState(() {
          _errorMessage = 'Camera permission is required to scan medicines. '
                          'Please enable it in app settings.';
        });
        return false;
      }
    }
    
    return true;
  }

  Future<void> _pickImage() async {
    // Reset previous state
    setState(() {
      _errorMessage = '';
      _ocrDebugText = '';
      _showDebugInfo = false;
    });

    // Camera doesn't work on Web for OCR
    if (kIsWeb) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera OCR works only on mobile devices'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      // Check permissions first
      final hasPermission = await _checkCameraPermission();
      if (!hasPermission) return;

      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);

      setState(() {
        _image = file;
        _loading = true;
        _errorMessage = '';
      });

      // Small delay to show loading state
      await Future.delayed(const Duration(milliseconds: 300));

      // Process the image
      await _processImage(file);

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'Error: $e';
      });
      debugPrint('Camera error: $e');
    }
  }

  Future<void> _processImage(File file) async {
    try {
      // OCR SCAN
      String rawText;
      try {
        rawText = await OcrService.scanImage(file);
        
        // Store for debugging
        _ocrDebugText = rawText;
        
        // Show debug info if text is extracted
        if (rawText.isNotEmpty) {
          _showDebugInfo = true;
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _errorMessage = 'Failed to process image. Please try again.\nError: $e';
        });
        return;
      }

      // Parse the text
      String medicineName = '';
      String expiryDate = '';

      if (rawText.isNotEmpty) {
        try {
          medicineName = MedicineParser.extractMedicineName(rawText);
          expiryDate = MedicineParser.extractExpiryDate(rawText);
        } catch (e) {
          debugPrint('Parser error: $e');
          // Fallback
          final lines = rawText.split('\n');
          if (lines.isNotEmpty) {
            medicineName = lines.first.trim();
            if (medicineName.length > 50) {
              medicineName = '${medicineName.substring(0, 50)}...';
            }
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      // Show results
      _showExtractionResult(medicineName, expiryDate, file, rawText);

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'Processing failed: $e';
      });
    }
  }

  void _showExtractionResult(String name, String expiry, File image, String rawText) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Extraction Complete'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (name.isNotEmpty) ...[
                Text(
                  'Medicine Name:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  name,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
              ],
              
              if (expiry.isNotEmpty) ...[
                Text(
                  'Expiry Date:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  expiry,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
              ],
              
              if (name.isEmpty && expiry.isEmpty) ...[
                const Text(
                  'Could not extract information automatically.',
                  style: TextStyle(color: Colors.orange),
                ),
                const SizedBox(height: 8),
                const Text('You can enter details manually.'),
              ],
              
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.file(
                  image,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDebugDialog(rawText);
            },
            child: const Text('View Raw Text'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to add medicine screen
              Navigator.pushNamed(
                context,
                '/add-medicine',
                arguments: {
                  'name': name,
                  'expiry': expiry,
                  'image': _image,
                  'from_scan': true,
                },
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showDebugDialog(String rawText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('OCR Raw Text'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              rawText.isEmpty ? 'No text detected' : rawText,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy),
            onPressed: () {
              // Copy to clipboard
              // Clipboard.setData(ClipboardData(text: rawText));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
              Navigator.pop(context);
            },
            label: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);

      setState(() {
        _image = file;
        _loading = true;
        _errorMessage = '';
      });

      await _processImage(file);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'Gallery error: $e';
      });
    }
  }

  void _resetScan() {
    setState(() {
      _image = null;
      _loading = false;
      _errorMessage = '';
      _ocrDebugText = '';
      _showDebugInfo = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get theme colors
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final backgroundColor = theme.scaffoldBackgroundColor;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Medicine'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_showDebugInfo && _ocrDebugText.isNotEmpty)
            IconButton(
              onPressed: () => _showDebugDialog(_ocrDebugText),
              icon: const Icon(Icons.bug_report),
              tooltip: 'Debug Info',
            ),
          if (_image != null)
            IconButton(
              onPressed: _resetScan,
              icon: const Icon(Icons.refresh),
              tooltip: 'New Scan',
            ),
        ],
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Section - Instructions
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Scan Instructions Card
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.medical_services,
                                  size: 64,
                                  color: primaryColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Scan Medicine Label',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Position the medicine label within the frame and ensure good lighting for best results.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Tips Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Color.alphaBlend(
                              primaryColor.withAlpha(20),
                              Colors.white,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color.alphaBlend(
                                primaryColor.withAlpha(100),
                                Colors.white,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline, 
                                    color: primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Scanning Tips',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildTip('• Use natural daylight or bright indoor light', primaryColor),
                              _buildTip('• Hold camera steady to avoid blur', primaryColor),
                              _buildTip('• Focus on medicine name and expiry date', primaryColor),
                              _buildTip('• Keep the label flat and avoid shadows', primaryColor),
                              _buildTip('• Ensure text is clear and not reflective', primaryColor),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Image Preview
                        if (_image != null && !_loading)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Captured Image',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _image!,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Loading Indicator
                if (_loading)
                  Column(
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Processing image...',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                
                // Error Message
                if (_errorMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Action Buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text(
                          'Open Camera & Scan',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: _openGallery,
                        icon: Icon(Icons.photo_library, color: primaryColor),
                        label: Text(
                          'Choose from Gallery',
                          style: TextStyle(
                            fontSize: 16,
                            color: primaryColor,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/add-medicine',
                          arguments: {
                            'name': '',
                            'expiry': '',
                            'image': null,
                            'from_scan': false,
                          },
                        );
                      },
                      child: Text(
                        'Enter details manually instead',
                        style: TextStyle(
                          fontSize: 14,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: color,
          height: 1.4,
        ),
      ),
    );
  }
}