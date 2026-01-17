class MedicineParser {
  /// Extract medicine name from OCR text
  static String extractMedicineName(String text) {
    final lines = text.split('\n');

    for (final line in lines) {
      final clean = line.trim();

      // Skip useless lines
      if (clean.isEmpty) continue;
      if (clean.length < 4) continue;
      if (clean.contains(RegExp(r'\d{2}/\d{2}'))) continue;
      if (clean.toLowerCase().contains('expiry')) continue;
      if (clean.toLowerCase().contains('exp')) continue;

      // Return first valid-looking name
      return clean;
    }

    return '';
  }

  /// Extract expiry date (MM/YY or MM/YYYY)
  static String extractExpiryDate(String text) {
    final regExp = RegExp(
      r'(0[1-9]|1[0-2])[\/\-](\d{2}|\d{4})',
    );

    final match = regExp.firstMatch(text);
    if (match != null) {
      return match.group(0)!;
    }

    return '';
  }
}