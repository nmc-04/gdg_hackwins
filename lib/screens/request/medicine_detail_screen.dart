import 'package:flutter/material.dart';

class MedicineDetailScreen extends StatelessWidget {
  static const routeName = '/medicine_detail';
  const MedicineDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Paracetamol 500mg', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Expiry: 12/2026'),
          const SizedBox(height: 8),
          const Text('Quantity: 2 strips'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/request_status'), child: const Text('Request')),
        ],
      ),
    );
  }
}
