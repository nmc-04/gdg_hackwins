class ParsedMedicine {
  final String name;
  final String expiryDate;

  ParsedMedicine({
    required this.name,
    required this.expiryDate,
  });
}

class MedicineParser {
  /// Extract medicine name + expiry date from OCR text
  static ParsedMedicine parse(String ocrText) {
    final lines = ocrText
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    String medicineName = 'Unknown Medicine';
    String expiryDate = 'Not Found';

    // Medicine name → first meaningful long line
    for (final line in lines) {
      if (line.length > 5 &&
          !line.toLowerCase().contains('mg') &&
          !line.toLowerCase().contains('exp') &&
          !line.toLowerCase().contains('mfg')) {
        medicineName = line;
        break;
      }
    }

    // Expiry date patterns
    final expiryRegex =
        RegExp(r'(exp|expiry|use before)[^0-9]*(\d{2}[/\-]\d{2,4})',
            caseSensitive: false);

    for (final line in lines) {
      final match = expiryRegex.firstMatch(line);
      if (match != null) {
        expiryDate = match.group(2)!;
        break;
      }
    }

    return ParsedMedicine(
      name: medicineName,
      expiryDate: expiryDate,
    );
  }
}
