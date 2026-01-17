import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class MyDonationsScreen extends StatelessWidget {
  static const routeName = '/my_donations';
  const MyDonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Donations'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildDonationItem(
                  'Paracetamol 500mg Tablets',
                  'Donated on: 15 Jan 2026',
                  'Status: Completed',
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildDonationItem(
                  'Vitamin C 1000mg Effervescent',
                  'Donated on: 10 Jan 2026',
                  'Status: Completed',
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildDonationItem(
                  'Insulin Injection (Human Mixtard)',
                  'Donated on: 5 Jan 2026',
                  'Status: In Progress',
                  Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildDonationItem(
                  'Asthma Inhaler (Salbutamol)',
                  'Donated on: 2 Jan 2026',
                  'Status: Collected',
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildDonationItem(
                  'Blood Pressure Medicine',
                  'Donated on: 28 Dec 2025',
                  'Status: Expired',
                  Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationItem(String name, String date, String status, Color statusColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.medication, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.grey),
              onPressed: () {
                // Navigate to donation details
              },
            ),
          ],
        ),
      ),
    );
  }
}
