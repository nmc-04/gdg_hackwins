// scan_medicine_screen.dart - FIXED VERSION (Without camera package)
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

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
    if (kIsWeb) return true;

    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isGranted) {
        setState(() {
          _errorMessage = 'Camera permission required. Enable in settings.';
        });
        return false;
      }
    }
    return true;
  }

  Future<void> _pickImage() async {
    setState(() {
      _errorMessage = '';
      _ocrDebugText = '';
      _showDebugInfo = false;
    });

    if (kIsWeb) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera OCR works only on mobile')),
      );
      return;
    }

    try {
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

      await Future.delayed(const Duration(milliseconds: 300));
      await _processImage(file);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'Camera error: $e';
      });
      debugPrint('❌ Camera error: $e');
    }
  }

  Future<void> _processImage(File file) async {
    try {
      debugPrint('🔄 Processing image...');

      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final inputImage = InputImage.fromFile(file);

      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      final rawText = recognizedText.text;

      debugPrint('📝 Extracted text length: ${rawText.length}');
      debugPrint('📝 Raw text:\n$rawText');

      setState(() {
        _ocrDebugText = rawText;
        _showDebugInfo = rawText.isNotEmpty;
      });

      String medicineName = '';
      String expiryDate = '';

      if (rawText.isNotEmpty) {
        medicineName = _extractMedicineName(rawText);
        expiryDate = _extractExpiryDate(rawText);
        
        debugPrint('✅ Medicine: $medicineName');
        debugPrint('✅ Expiry: $expiryDate');
      }

      await textRecognizer.close();

      if (!mounted) return;

      setState(() => _loading = false);

      _showExtractionResult(medicineName, expiryDate, file, rawText);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'Processing failed: $e';
      });
      debugPrint('❌ Processing error: $e');
    }
  }

  String _extractMedicineName(String text) {
    debugPrint('🔍 Extracting medicine name...');
    
    final lines = text.split('\n');
    String? bestCandidate;
    
    for (var line in lines) {
      line = line.trim();
      
      if (line.length < 3 || RegExp(r'^[\d\s\-\.\/]+$').hasMatch(line)) {
        continue;
      }
      
      if (RegExp(r'^[A-Z]{2,4}\d{5,8}$').hasMatch(line)) {
        debugPrint('⏭️ Skipping batch number: $line');
        continue;
      }
      
      if (line.toLowerCase().contains('mfg') ||
          line.toLowerCase().contains('expiry') ||
          line.toLowerCase().contains('batch') ||
          line.toLowerCase().contains('composition') ||
          line.toLowerCase().contains('dosage') ||
          line.toLowerCase().contains('storage') ||
          line.toLowerCase().contains('schedule') ||
          line.toLowerCase().contains('prescription')) {
        continue;
      }
      
      if (RegExp(r'[A-Z]+-\d+|[A-Za-z]+\s+\d+\s*mg', caseSensitive: false).hasMatch(line)) {
        if (line.length >= 5 && line.length <= 50) {
          debugPrint('✅ Found medicine name (pattern match): $line');
          return line;
        }
      }
      
      if (bestCandidate == null && line.length >= 5 && line.length <= 50) {
        if (RegExp(r'[A-Za-z]{3,}').hasMatch(line)) {
          bestCandidate = line;
        }
      }
    }
    
    if (bestCandidate != null) {
      debugPrint('✅ Found medicine name (best candidate): $bestCandidate');
      return bestCandidate;
    }
    
    debugPrint('⚠️ No medicine name found');
    return lines.isNotEmpty ? lines[0].trim() : '';
  }

  String _extractExpiryDate(String text) {
    debugPrint('🔍 Extracting expiry date...');
    debugPrint('Full OCR text:\n$text');
    
    final monthMap = {
      'JAN': '01', 'JANUARY': '01',
      'FEB': '02', 'FEBRUARY': '02',
      'MAR': '03', 'MARCH': '03',
      'APR': '04', 'APRIL': '04',
      'MAY': '05',
      'JUN': '06', 'JUNE': '06',
      'JUL': '07', 'JULY': '07',
      'AUG': '08', 'AUGUST': '08',
      'SEP': '09', 'SEPT': '09', 'SEPTEMBER': '09',
      'OCT': '10', 'OCTOBER': '10',
      'NOV': '11', 'NOVEMBER': '11',
      'DEC': '12', 'DECEMBER': '12',
    };
    
    final lines = text.split('\n');
    
    // Strategy 1: Look for lines with "EXP" or "EXPIRY"
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lowerLine = line.toLowerCase();
      
      debugPrint('Line $i: $line');
      
      if (lowerLine.contains('exp') || lowerLine.contains('mfg')) {
        debugPrint('  ✓ Found exp/mfg keyword');
        
        // Check current and next line
        for (int j = i; j <= i + 1 && j < lines.length; j++) {
          final checkLine = lines[j];
          debugPrint('  Checking line $j: $checkLine');
          
          // Pattern 1: Month name followed by year (AUG 2027, AUG-2027, AUG.2027)
          for (var entry in monthMap.entries) {
            final monthPattern = RegExp(
              '${entry.key}[\\s\\.\\-]*(\\d{4})',
              caseSensitive: false
            );
            final match = monthPattern.firstMatch(checkLine);
            if (match != null) {
              String year = match.group(1)!;
              int yearNum = int.tryParse(year) ?? 0;
              if (yearNum >= 2024 && yearNum <= 2035) {
                String formattedDate = '${entry.value}/$year';
                debugPrint('✅ Found expiry (month name): $formattedDate');
                return formattedDate;
              }
            }
          }
          
          // Pattern 2: MM/YYYY, MM-YYYY, MM.YYYY, MM YYYY
          var numMatch = RegExp(r'(\d{1,2})[\s\/\.\-]+(\d{4})').firstMatch(checkLine);
          if (numMatch != null) {
            String month = numMatch.group(1)!;
            String year = numMatch.group(2)!;
            int? monthNum = int.tryParse(month);
            int yearNum = int.tryParse(year) ?? 0;
            
            if (monthNum != null && monthNum >= 1 && monthNum <= 12 && yearNum >= 2024 && yearNum <= 2035) {
              String formattedDate = '${month.padLeft(2, '0')}/$year';
              debugPrint('✅ Found expiry (numeric): $formattedDate');
              return formattedDate;
            }
          }
          
          // Pattern 3: DD/MM/YYYY or MM/DD/YYYY
          var fullMatch = RegExp(r'(\d{1,2})[\s\/\.\-](\d{1,2})[\s\/\.\-](\d{2,4})').firstMatch(checkLine);
          if (fullMatch != null) {
            String part1 = fullMatch.group(1)!;
            String part2 = fullMatch.group(2)!;
            String year = fullMatch.group(3)!;
            
            if (year.length == 2) {
              year = '20$year';
            }
            
            int? num1 = int.tryParse(part1);
            int? num2 = int.tryParse(part2);
            int yearNum = int.tryParse(year) ?? 0;
            
            if (num1 != null && num2 != null && yearNum >= 2024 && yearNum <= 2035) {
              String month = '';
              
              if (num1 > 12 && num2 <= 12) {
                month = part2.padLeft(2, '0');
              } else if (num2 > 12 && num1 <= 12) {
                month = part1.padLeft(2, '0');
              } else if (num1 <= 12) {
                month = part1.padLeft(2, '0');
              }
              
              if (month.isNotEmpty) {
                String formattedDate = '$month/$year';
                debugPrint('✅ Found expiry (full date): $formattedDate');
                return formattedDate;
              }
            }
          }
        }
      }
    }
    
    // Strategy 2: Fallback - search entire text without keyword requirement
    debugPrint('Fallback: searching entire text...');
    
    for (var entry in monthMap.entries) {
      final monthPattern = RegExp(
        '${entry.key}[\\s\\.\\-]*(\\d{4})',
        caseSensitive: false
      );
      final match = monthPattern.firstMatch(text);
      if (match != null) {
        String year = match.group(1)!;
        int yearNum = int.tryParse(year) ?? 0;
        if (yearNum >= 2024 && yearNum <= 2035) {
          String formattedDate = '${entry.value}/$year';
          debugPrint('✅ Found expiry (fallback month): $formattedDate');
          return formattedDate;
        }
      }
    }
    
    var anyNumMatch = RegExp(r'(\d{1,2})[\s\/\.\-](\d{4})').firstMatch(text);
    if (anyNumMatch != null) {
      String month = anyNumMatch.group(1)!;
      String year = anyNumMatch.group(2)!;
      int? monthNum = int.tryParse(month);
      int yearNum = int.tryParse(year) ?? 0;
      
      if (monthNum != null && monthNum >= 1 && monthNum <= 12 && yearNum >= 2024 && yearNum <= 2035) {
        String formattedDate = '${month.padLeft(2, '0')}/$year';
        debugPrint('✅ Found expiry (fallback numeric): $formattedDate');
        return formattedDate;
      }
    }
    
    debugPrint('⚠️ No expiry date found');
    return '';
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
                Text(name, style: const TextStyle(fontSize: 16)),
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
                Text(expiry, style: const TextStyle(fontSize: 16)),
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
              // FIXED: Properly return data to calling screen
              Navigator.pop(context, {
                'name': name,
                'expiry': expiry,
                'image': _image,
                'from_scan': true,
              });
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
      debugPrint('❌ Gallery error: $e');
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
    final primaryColor = Colors.blue;
    
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
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
                                'Position medicine label in frame with good lighting for best results.',
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
                      
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb_outline, color: primaryColor),
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
                            _buildTip('• Use natural or bright indoor light'),
                            _buildTip('• Hold camera steady'),
                            _buildTip('• Focus on name & expiry date'),
                            _buildTip('• Keep label flat, avoid shadows'),
                            _buildTip('• Ensure text is clear'),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
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
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              
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
                        style: TextStyle(fontSize: 16, color: primaryColor),
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
                      Navigator.pop(context, {
                        'name': '',
                        'expiry': '',
                        'image': null,
                        'from_scan': false,
                      });
                    },
                    child: Text(
                      'Enter details manually instead',
                      style: TextStyle(fontSize: 14, color: primaryColor),
                    ),
                  ),
                ],
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
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, height: 1.4),
      ),
    );
  }
}