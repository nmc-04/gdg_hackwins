import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class MyRequestsScreen extends StatelessWidget {
  static const routeName = '/my_requests';
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Requests'),
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
                _buildRequestItem(
                  'Insulin Pens - Emergency',
                  'Requested: 18 Jan 2026',
                  'Status: Pending',
                  Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildRequestItem(
                  'Blood Pressure Medicine',
                  'Requested: 12 Jan 2026',
                  'Status: Approved',
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildRequestItem(
                  'Pain Killers',
                  'Requested: 8 Jan 2026',
                  'Status: Completed',
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildRequestItem(
                  'Asthma Inhaler',
                  'Requested: 3 Jan 2026',
                  'Status: Cancelled',
                  Colors.red,
                ),
                const SizedBox(height: 12),
                _buildRequestItem(
                  'Diabetes Test Strips',
                  'Requested: 25 Dec 2025',
                  'Status: Delivered',
                  Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestItem(String name, String date, String status, Color statusColor) {
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
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.emergency, color: Colors.red),
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
                // Navigate to request details
              },
            ),
          ],
        ),
      ),
    );
  }
}