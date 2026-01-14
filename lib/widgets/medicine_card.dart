import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import '../widgets/status_badge.dart';
import '../core/app_theme.dart';

class MedicineCard extends StatelessWidget {
  final MedicineModel medicine;
  final VoidCallback? onTap;

  const MedicineCard({super.key, required this.medicine, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppTheme.lightTheme.primaryColor,
          child: const Icon(Icons.medication, color: Colors.white),
        ),
        title: Text(medicine.name),
        subtitle: Text('Expiry: ${medicine.expiry} • Qty: ${medicine.quantity}'),
        trailing: StatusBadge(
          text: medicine.verified ? 'Verified' : 'Unverified',
          color: medicine.verified ? AppTheme.lightTheme.primaryColor! : Colors.orange,
        ),
      ),
    );
  }
}
