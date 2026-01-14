import 'package:flutter/material.dart';
import '../../widgets/medicine_card.dart';
import '../../models/medicine_model.dart';

class MedicineListScreen extends StatelessWidget {
  static const routeName = '/medicine_list';
  const MedicineListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // demo list
    final meds = [
      MedicineModel(id: '1', name: 'Paracetamol 500mg', expiry: '12/2026', quantity: 2, verified: true),
      MedicineModel(id: '2', name: 'Insulin', expiry: '06/2025', quantity: 1, verified: false),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView.builder(
        itemCount: meds.length,
        itemBuilder: (ctx, i) => MedicineCard(
          medicine: meds[i],
          onTap: () => Navigator.pushNamed(context, '/medicine_detail'),
        ),
      ),
    );
  }
}
