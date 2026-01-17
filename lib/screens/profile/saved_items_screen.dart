import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class SavedItemsScreen extends StatefulWidget {
  static const routeName = '/saved_items';
  const SavedItemsScreen({super.key});

  @override
  State<SavedItemsScreen> createState() => _SavedItemsScreenState();
}

class _SavedItemsScreenState extends State<SavedItemsScreen> {
  // Sample saved items data
  final List<Map<String, dynamic>> _savedItems = [
    {
      'id': '1',
      'name': 'Insulin Pens',
      'expiry': 'Expires: Jun 2026',
      'distance': '5 km away',
    },
    {
      'id': '2',
      'name': 'Diabetes Test Strips',
      'expiry': 'Expires: Dec 2026',
      'distance': '3.2 km away',
    },
    {
      'id': '3',
      'name': 'Vitamin D Supplements',
      'expiry': 'Expires: Mar 2027',
      'distance': '7 km away',
    },
    {
      'id': '4',
      'name': 'Multivitamin Tablets',
      'expiry': 'Expires: Aug 2026',
      'distance': '2.5 km away',
    },
    {
      'id': '5',
      'name': 'Pain Relief Gel',
      'expiry': 'Expires: Nov 2026',
      'distance': '4.1 km away',
    },
  ];

  // Function to delete an item
  void _deleteItem(String id) {
    setState(() {
      _savedItems.removeWhere((item) => item['id'] == id);
    });
    
    // Show confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Item removed from saved'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            // In a real app, you would restore the item here
            // For now, just show a message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Undo feature would restore item here'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Saved Items'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _savedItems.isEmpty
          ? _buildEmptyState()
          : ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        '${_savedItems.length} saved items',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._savedItems.map((item) => _buildSavedItem(item)).toList(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSavedItem(Map<String, dynamic> item) {
    return Card(
      key: ValueKey(item['id']),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
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
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.bookmark, color: Colors.purple),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['expiry'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['distance'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteItem(item['id']),
              tooltip: 'Remove from saved',
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.grey),
              onPressed: () {
                // Navigate to item details
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('View details of ${item['name']}'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          const Text(
            'No saved items',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Save medicines you\'re interested in for quick access later',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Browse Medicines'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}