import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class OcrService {
  /// Scans the given image file with preprocessing for better accuracy
  static Future<String> scanImage(File imageFile) async {
    try {
      // Do preprocessing in main thread (it's fast)
      final preprocessedFile = await _preprocessImage(imageFile);
      
      // OCR must run on main thread (needs platform channels)
      final inputImage = InputImage.fromFile(preprocessedFile);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();
      
      // Clean up temp file
      if (preprocessedFile.path != imageFile.path) {
        try {
          await preprocessedFile.delete();
        } catch (_) {}
      }
      
      return recognizedText.text;
    } catch (e) {
      print('OCR Error: $e');
      return '';
    }
  }

  /// Preprocess image to improve OCR accuracy
  static Future<File> _preprocessImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      
      if (image == null) return imageFile;

      // 1. Resize if too small (bigger is better for OCR)
      if (image.width < 1500) {
        final scale = 2000.0 / image.width;
        image = img.copyResize(
          image,
          width: (image.width * scale).round(),
          height: (image.height * scale).round(),
          interpolation: img.Interpolation.cubic,
        );
      }

      // 2. Convert to grayscale
      image = img.grayscale(image);

      // 3. BOOST contrast and brightness
      image = img.adjustColor(
        image,
        contrast: 1.6,
        brightness: 1.2,
      );

      final tempPath = '${imageFile.parent.path}/ocr_temp_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(img.encodeJpg(image, quality: 100));
      
      return tempFile;
    } catch (e) {
      print('Preprocessing error: $e');
      return imageFile;
    }
  }

  /// Extract medicine details from OCR text with improved patterns
  static Map<String, String> extractMedicineDetails(String ocrText) {
    if (ocrText.isEmpty) {
      return {'name': '', 'expiry': ''};
    }

    print('\n========== FULL OCR TEXT ==========');
    print(ocrText);
    print('===================================\n');

    final name = _extractMedicineName(ocrText);
    final expiry = _extractExpiryDate(ocrText);

    print('📦 Extracted Name: ${name.isEmpty ? "NOT FOUND" : name}');
    print('📅 Extracted Expiry: ${expiry.isEmpty ? "NOT FOUND" : expiry}');

    return {
      'name': name,
      'expiry': expiry,
    };
  }

  /// Extract medicine name with multiple strategies
  static String _extractMedicineName(String text) {
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    // Strategy 1: Look for product name patterns (TRANOSTAT-750, CROCIN, etc.)
    final productNamePattern = RegExp(
      r'^([A-Z][A-Z\-]+(?:\-\d+)?)\s*$',
      caseSensitive: true,
    );
    
    for (final line in lines) {
      final match = productNamePattern.firstMatch(line);
      if (match != null && match.group(1) != null) {
        final name = match.group(1)!;
        // Make sure it's not a common word
        if (!_isCommonWord(name) && name.length >= 4) {
          return name;
        }
      }
    }

    // Strategy 2: Look for medicine name with dosage
    final nameWithDosage = RegExp(
      r'([A-Z][a-zA-Z]+(?:\s+[A-Z]?[a-zA-Z]+)*)\s*\d+\s*(?:mg|ML|ml|G|g|MCG|mcg|IU|iu)',
      caseSensitive: false,
    );
    
    for (final line in lines) {
      final match = nameWithDosage.firstMatch(line);
      if (match != null && match.group(0) != null) {
        return match.group(0)!.trim();
      }
    }

    // Strategy 3: First meaningful line
    for (final line in lines) {
      if (line.length >= 4 && 
          line.length <= 50 && 
          RegExp(r'^[A-Z]').hasMatch(line) &&
          !_isCommonWord(line)) {
        return line;
      }
    }

    return lines.isNotEmpty ? lines.first : '';
  }

  /// FIXED: Extract expiry date with MONTH NAME support
  static String _extractExpiryDate(String text) {
    print('\n🔍 Searching for date in text...');
    
    // Normalize text variations
    String normalizedText = text.replaceAll(RegExp(r'\s+'), ' ');
    String noSpaceText = text.replaceAll(RegExp(r'\s+'), '');
    List<String> textsToTry = [text, normalizedText, noSpaceText];

    for (String searchText in textsToTry) {
      // ===== STRATEGY: Find the date that comes AFTER "Expiry Date" label =====
      // Look for "Expiry Date" label first, then find the nearest date after it
      final expiryLabelPos = searchText.toLowerCase().indexOf('expiry date');
      
      if (expiryLabelPos != -1) {
        // Extract text AFTER "Expiry Date:" label (next 50 characters should contain the date)
        final textAfterLabel = searchText.substring(expiryLabelPos, 
          (expiryLabelPos + 50).clamp(0, searchText.length));
        
        // Look for month name pattern in this section
        final monthYearPattern = RegExp(
          r'(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC|'
          r'Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)'
          r'\.?\s*'  // Optional dot and spaces
          r'(\d{4})',  // 4-digit year
          caseSensitive: false,
        );
        
        final match = monthYearPattern.firstMatch(textAfterLabel);
        if (match != null && match.group(1) != null && match.group(2) != null) {
          final monthStr = match.group(1)!;
          final year = match.group(2)!;
          final monthNum = _monthNameToNumber(monthStr);
          if (monthNum != null) {
            final result = '$monthNum/$year';
            print('✅ Found AFTER "Expiry Date:" label: $result (from "$monthStr.$year")');
            return result;
          }
        }
      }

      // ===== FALLBACK: Find ALL dates and use the LAST one (usually expiry) =====
      final monthYearPattern = RegExp(
        r'(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC|'
        r'Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)'
        r'\.?\s*'  // Optional dot and spaces
        r'(\d{4})',  // 4-digit year
        caseSensitive: false,
      );
      
      final allMatches = monthYearPattern.allMatches(searchText).toList();
      if (allMatches.length >= 2) {
        // If we have 2+ dates, the LAST one is usually the expiry date
        final lastMatch = allMatches.last;
        final monthStr = lastMatch.group(1)!;
        final year = lastMatch.group(2)!;
        final monthNum = _monthNameToNumber(monthStr);
        if (monthNum != null) {
          final result = '$monthNum/$year';
          print('✅ Found LAST date (likely expiry): $result (from "$monthStr.$year")');
          return result;
        }
      } else if (allMatches.isNotEmpty) {
        // Only one date found, use it
        final match = allMatches.first;
        final monthStr = match.group(1)!;
        final year = match.group(2)!;
        final monthNum = _monthNameToNumber(monthStr);
        if (monthNum != null) {
          final result = '$monthNum/$year';
          print('✅ Found single date: $result (from "$monthStr.$year")');
          return result;
        }
      }

      // ===== PATTERN 2: "Expiry Date : MM/YYYY" format =====
      final expDatePattern = RegExp(
        r'(?:EXP|Exp|EXPIRY|Expiry|exp)[\s:\.]*(\d{1,2})[\s\/\-\.:]+(\d{2,4})',
        caseSensitive: false,
      );
      final expMatch = expDatePattern.firstMatch(searchText);
      if (expMatch != null && expMatch.group(1) != null && expMatch.group(2) != null) {
        final date = '${expMatch.group(1)}/${expMatch.group(2)}';
        print('✅ Found with EXP: pattern: $date');
        return _normalizeDate(date);
      }

      // ===== PATTERN 3: MFG/EXP dual format =====
      final mfgExpPattern = RegExp(
        r'(?:MFG|Mfg)[\s:\.]*\d{1,2}[\s\/\-\.]\d{2,4}[\s,]*(?:EXP|Exp)[\s:\.]*(\d{1,2}[\s\/\-\.]\d{2,4})',
        caseSensitive: false,
      );
      final mfgExpMatch = mfgExpPattern.firstMatch(searchText);
      if (mfgExpMatch != null && mfgExpMatch.group(1) != null) {
        print('✅ Found with MFG/EXP pattern: ${mfgExpMatch.group(1)}');
        return _normalizeDate(mfgExpMatch.group(1)!);
      }

      // ===== PATTERN 4: Standalone MM/YYYY =====
      final standaloneDatePattern = RegExp(r'\b(0[1-9]|1[0-2])[\s\/\-\.](\d{4})\b');
      final standaloneMatch = standaloneDatePattern.firstMatch(searchText);
      if (standaloneMatch != null) {
        final date = '${standaloneMatch.group(1)}/${standaloneMatch.group(2)}';
        print('✅ Found standalone date: $date');
        return date;
      }

      // ===== PATTERN 5: MM/YY (2-digit year) =====
      final shortYearPattern = RegExp(r'\b(0[1-9]|1[0-2])[\s\/\-\.](\d{2})\b');
      final shortYearMatch = shortYearPattern.firstMatch(searchText);
      if (shortYearMatch != null) {
        final month = shortYearMatch.group(1)!;
        final year = int.parse(shortYearMatch.group(2)!);
        final fullYear = year < 50 ? 2000 + year : 1900 + year;
        print('✅ Found with short year: $month/$fullYear');
        return '$month/$fullYear';
      }

      // ===== PATTERN 6: Loose date pattern (last resort) =====
      final loosePattern = RegExp(r'(\d{1,2})[\s\/\-\.](\d{2,4})');
      final matches = loosePattern.allMatches(searchText);
      for (final match in matches) {
        final month = int.tryParse(match.group(1)!);
        final year = match.group(2)!;
        
        if (month != null && month >= 1 && month <= 12) {
          String fullYear = year;
          if (year.length == 2) {
            final y = int.parse(year);
            fullYear = (y < 50 ? 2000 + y : 1900 + y).toString();
          }
          
          final yearNum = int.tryParse(fullYear);
          if (yearNum != null && yearNum >= 2024 && yearNum <= 2035) {
            final result = '${month.toString().padLeft(2, '0')}/$fullYear';
            print('✅ Found with loose pattern: $result');
            return result;
          }
        }
      }
    }

    print('❌ No date found in text');
    return '';
  }

  /// Convert month name/abbreviation to number
  static String? _monthNameToNumber(String monthName) {
    final months = {
      // 3-letter abbreviations
      'jan': '01', 'feb': '02', 'mar': '03', 'apr': '04',
      'may': '05', 'jun': '06', 'jul': '07', 'aug': '08',
      'sep': '09', 'oct': '10', 'nov': '11', 'dec': '12',
      // Full names
      'january': '01', 'february': '02', 'march': '03', 'april': '04',
      'june': '06', 'july': '07', 'august': '08', 'september': '09',
      'october': '10', 'november': '11', 'december': '12',
      // Common variations
      'sept': '09',
    };
    return months[monthName.toLowerCase()];
  }

  /// Normalize date format to MM/YYYY
  static String _normalizeDate(String date) {
    date = date.replaceAll(' ', '');
    date = date.replaceAll(RegExp(r'[\-\.\:]'), '/');
    
    final parts = date.split('/');
    if (parts.length == 2) {
      String month = parts[0].padLeft(2, '0');
      String yearStr = parts[1];
      
      final monthNum = int.tryParse(month);
      if (monthNum == null || monthNum < 1 || monthNum > 12) {
        return date;
      }
      
      if (yearStr.length == 2) {
        final year = int.parse(yearStr);
        final fullYear = year < 50 ? 2000 + year : 1900 + year;
        return '$month/$fullYear';
      } else if (yearStr.length == 4) {
        return '$month/$yearStr';
      }
    }
    
    return date;
  }

  /// Check if a word is too common to be a medicine name
  static bool _isCommonWord(String word) {
    final commonWords = {
      'THE', 'AND', 'FOR', 'WITH', 'THIS', 'THAT',
      'PRESCRIPTION', 'MEDICINE', 'TABLET', 'CAPSULE', 'TABLETS',
      'STRIP', 'PACKAGE', 'WARNING', 'CAUTION',
      'INSTRUCTIONS', 'DOSE', 'DOSAGE', 'ONLY',
      'STORE', 'KEEP', 'AWAY', 'FROM', 'CHILDREN',
      'COMPOSITION', 'SCHEDULE', 'DRUG', 'SUSTAINED', 'RELEASE',
      'EACH', 'CONTAINS', 'FORM', 'IMMEDIATE', 'ACID',
    };
    return commonWords.contains(word.toUpperCase());
  }
}

