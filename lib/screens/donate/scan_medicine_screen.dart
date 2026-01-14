import 'package:flutter/material.dart';

class ScanMedicineScreen extends StatelessWidget {
  static const routeName = '/scan_medicine';

  const ScanMedicineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Scan Medicine Screen',
        style: TextStyle(fontSize: 22),
      ),
    );
  }
}
