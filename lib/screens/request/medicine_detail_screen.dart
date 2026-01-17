// screens/request/medicine_detail_screen.dart
import 'package:flutter/material.dart';
import '../../models/medicine_model.dart';
import '../../core/app_theme.dart';

class MedicineDetailScreen extends StatelessWidget {
  static const routeName = '/medicine_detail';
  const MedicineDetailScreen({super.key});

  void _shareMedicine(BuildContext context, MedicineModel medicine) {
    // Implement share functionality
    final shareText = 'Check out this medicine: ${medicine.name} - Available for donation!';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: ${medicine.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // For actual sharing, you would use a package like share_plus:
    // await Share.share(shareText);
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isWarning ? Colors.orange[800] : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isWarning)
                      Icon(
                        Icons.warning,
                        size: 16,
                        color: Colors.orange[800],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final medicine = ModalRoute.of(context)!.settings.arguments as MedicineModel;
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor; // Fixed: Remove MaterialColor cast
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Medicine Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _shareMedicine(context, medicine);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medicine Header
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1), // Fixed
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.medical_services,
                          size: 40,
                          color: primaryColor, // Fixed
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medicine.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              medicine.manufacturer ?? 'Generic',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (medicine.urgent)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.warning,
                                      size: 14,
                                      color: Colors.red.shade700,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Urgent Need',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Stats Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildStatItem(
                        icon: Icons.calendar_today,
                        label: 'Expiry Date',
                        value: medicine.expiry,
                        color: medicine.isExpiringSoon ? Colors.orange : Colors.blue,
                        isWarning: medicine.isExpiringSoon,
                      ),
                      _buildStatItem(
                        icon: Icons.numbers,
                        label: 'Quantity',
                        value: '${medicine.quantity} units',
                        color: Colors.green,
                      ),
                      _buildStatItem(
                        icon: Icons.location_on,
                        label: 'Distance',
                        value: medicine.distance ?? 'Not specified',
                        color: Colors.purple,
                      ),
                      _buildStatItem(
                        icon: medicine.verified
                            ? Icons.verified
                            : Icons.pending,
                        label: 'Status',
                        value: medicine.verified ? 'Verified' : 'Pending',
                        color: medicine.verified ? Colors.green : Colors.amber,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Donor Information
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Donor Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: primaryColor.withOpacity(0.1), // Fixed
                      child: Icon(
                        Icons.person,
                        size: 24,
                        color: primaryColor, // Fixed
                      ),
                    ),
                    title: Text(
                      medicine.donorName ?? 'Anonymous Donor',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (medicine.donorRating != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${medicine.donorRating!}/5',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '• 12 donations',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 4),
                        if (medicine.distance != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_pin,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                medicine.distance!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    trailing: TextButton(
                      onPressed: () {
                        // Navigate to donor profile
                      },
                      child: const Text('View Profile'),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Medicine Description
            if (medicine.description != null && medicine.description!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      medicine.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Save to favorites
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added to favorites'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.bookmark_border),
                      label: const Text('Save'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Request medicine
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Request sent to donor'),
                              ],
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.message),
                      label: Text(
                        medicine.urgent ? 'Request Urgently' : 'Request Medicine',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: medicine.urgent ? Colors.red : primaryColor, // Fixed
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}