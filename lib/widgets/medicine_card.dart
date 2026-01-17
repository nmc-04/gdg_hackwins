// widgets/medicine_card.dart
import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import '../core/app_theme.dart';

class MedicineCard extends StatelessWidget {
  final MedicineModel medicine;
  final VoidCallback onTap;
  final bool showDistance;

  const MedicineCard({
    super.key,
    required this.medicine,
    required this.onTap,
    this.showDistance = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: medicine.urgent
              ? Colors.red.shade200
              : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Medicine Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.medical_services,
                      color: theme.primaryColor,
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Medicine Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and Badges
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                medicine.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            
                            // Urgent Badge
                            if (medicine.urgent)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.warning,
                                      size: 12,
                                      color: Colors.red.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Urgent',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 6),
                        
                        // Details Row
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _buildDetailChip(
                              icon: Icons.calendar_today,
                              text: 'Exp: ${medicine.expiry}',
                              color: medicine.isExpiringSoon ? Colors.orange : Colors.blue,
                            ),
                            _buildDetailChip(
                              icon: Icons.numbers,
                              text: 'Qty: ${medicine.quantity}',
                              color: Colors.green,
                            ),
                            if (showDistance && medicine.distance != null)
                              _buildDetailChip(
                                icon: Icons.location_on,
                                text: medicine.distance!,
                                color: Colors.purple,
                              ),
                            if (medicine.verified)
                              _buildDetailChip(
                                icon: Icons.verified,
                                text: 'Verified',
                                color: Colors.green,
                              ),
                            if (medicine.isExpiringSoon)
                              _buildDetailChip(
                                icon: Icons.warning,
                                text: 'Expiring Soon',
                                color: Colors.orange,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Donor Info and Action Button
              Row(
                children: [
                  // Donor Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (medicine.donorName != null)
                          Text(
                            'Donated by ${medicine.donorName!}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (medicine.donorRating != null)
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                medicine.donorRating!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  
                  // Request Button
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: medicine.urgent
                          ? Colors.red
                          : theme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: medicine.isDonation
                        ? const Text('Request')
                        : const Text('View Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}