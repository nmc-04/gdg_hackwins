// screens/request/medicine_list_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/medicine_card.dart';
import '../../models/medicine_model.dart';
import '../../core/app_theme.dart';

class MedicineListScreen extends StatefulWidget {
  static const routeName = '/medicine_list';
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  List<MedicineModel> _medicines = [];
  bool _loading = true;
  String _searchQuery = '';
  String _selectedFilter = 'all';
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    setState(() => _loading = true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Demo data
    final demoMeds = [
      MedicineModel(
        id: '1',
        name: 'Paracetamol 500mg Tablets',
        expiry: '12/2026',
        quantity: 2,
        latitude: 18.5204,
        longitude: 73.8567,
        type: 'donation',
        verified: true,
        status: 'available',
        donatedBy: 'user1',
        createdAt: DateTime.now(),
        donorName: 'Rahul Sharma',
        distance: '2.5 km away',
        urgent: false,
        donorRating: '4.8',
        description: 'Unopened strip of 10 tablets',
        manufacturer: 'Cipla',
      ),
      MedicineModel(
        id: '2',
        name: 'Insulin Injection (Human Mixtard)',
        expiry: '06/2025',
        quantity: 1,
        latitude: 18.5304,
        longitude: 73.8667,
        type: 'donation',
        verified: false,
        status: 'available',
        donatedBy: 'user2',
        createdAt: DateTime.now(),
        donorName: 'Priya Patel',
        distance: '5.1 km away',
        urgent: true,
        donorRating: '4.5',
        description: 'Refrigerated, unopened vial',
        manufacturer: 'Novo Nordisk',
      ),
      MedicineModel(
        id: '3',
        name: 'Vitamin C 1000mg Effervescent',
        expiry: '03/2027',
        quantity: 3,
        latitude: 18.5404,
        longitude: 73.8767,
        type: 'donation',
        verified: true,
        status: 'available',
        donatedBy: 'user3',
        createdAt: DateTime.now(),
        donorName: 'Amit Kumar',
        distance: '1.8 km away',
        urgent: false,
        donorRating: '4.9',
        description: 'Box of 20 tablets',
        manufacturer: 'Bayer',
      ),
      MedicineModel(
        id: '4',
        name: 'Asthma Inhaler (Salbutamol)',
        expiry: '09/2026',
        quantity: 1,
        latitude: 18.5104,
        longitude: 73.8467,
        type: 'donation',
        verified: true,
        status: 'available',
        donatedBy: 'user4',
        createdAt: DateTime.now(),
        donorName: 'Neha Singh',
        distance: '3.2 km away',
        urgent: false,
        donorRating: '4.7',
        description: 'Unused, sealed inhaler',
        manufacturer: 'GSK',
      ),
      MedicineModel(
        id: '5',
        name: 'Blood Pressure Medicine (Amlodipine)',
        expiry: '01/2025',
        quantity: 2,
        latitude: 18.5504,
        longitude: 73.8867,
        type: 'donation',
        verified: false,
        status: 'available',
        donatedBy: 'user5',
        createdAt: DateTime.now(),
        donorName: 'Raj Mehta',
        distance: '7.5 km away',
        urgent: true,
        donorRating: '4.2',
        description: 'Monthly dose available',
        manufacturer: 'Sun Pharma',
      ),
    ];
    
    setState(() {
      _medicines = demoMeds;
      _loading = false;
    });
  }

  List<MedicineModel> get _filteredMedicines {
    List<MedicineModel> filtered = List.from(_medicines);
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((med) {
        final nameMatch = med.name.toLowerCase().contains(_searchQuery.toLowerCase());
        final manufacturerMatch = med.manufacturer?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
        final donorNameMatch = med.donorName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
        return nameMatch || manufacturerMatch || donorNameMatch;
      }).toList();
    }
    
    // Apply category filter
    if (_selectedCategory == 'urgent') {
      filtered = filtered.where((med) => med.urgent).toList();
    } else if (_selectedCategory == 'verified') {
      filtered = filtered.where((med) => med.verified).toList();
    } else if (_selectedCategory == 'expiring') {
      filtered = filtered.where((med) => med.isExpiringSoon).toList();
    } else if (_selectedCategory == 'nearby') {
      filtered.sort((a, b) {
        final distanceA = double.tryParse(a.distance?.split(' ').first ?? '999') ?? 999;
        final distanceB = double.tryParse(b.distance?.split(' ').first ?? '999') ?? 999;
        return distanceA.compareTo(distanceB);
      });
    }
    
    // Apply status filter
    if (_selectedFilter == 'available') {
      filtered = filtered.where((med) => med.isAvailable).toList();
    } else if (_selectedFilter == 'booked') {
      filtered = filtered.where((med) => med.isBooked).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Find Medicines'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMedicines,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Search medicines, brands, or donors...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          
          // Quick Filters
          Container(
            height: 60,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Filter:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip('All', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Urgent', 'urgent'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Verified', 'verified'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Nearby', 'nearby'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Expiring Soon', 'expiring'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Status Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                const Text(
                  'Status:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildStatusChip('Available', 'available'),
                    _buildStatusChip('Booked', 'booked'),
                    _buildStatusChip('Completed', 'completed'),
                  ],
                ),
              ],
            ),
          ),
          
          // Results Counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  '${_filteredMedicines.length} medicines found',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (_selectedCategory != 'all' || _selectedFilter != 'all')
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = 'all';
                        _selectedFilter = 'all';
                      });
                    },
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Clear all'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.primaryColor,
                    ),
                  ),
              ],
            ),
          ),
          
          // Medicines List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMedicines.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadMedicines,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredMedicines.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            return MedicineCard(
                              medicine: _filteredMedicines[index],
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/medicine_detail',
                                  arguments: _filteredMedicines[index],
                                );
                              },
                              showDistance: _selectedCategory != 'nearby',
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      
      // Emergency Request Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showEmergencyRequestDialog(context);
        },
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.warning),
        label: const Text('Emergency Request'),
        elevation: 4,
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedCategory == value;
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedCategory = selected ? value : 'all');
      },
      selectedColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildStatusChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = selected ? value : 'all');
      },
      selectedColor: _getStatusColor(value),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'booked':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication_outlined,
            size: 72,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'No medicines found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _searchQuery.isNotEmpty
                  ? 'Try searching with different keywords'
                  : 'Check back later for available donations',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = 'all';
                  _selectedFilter = 'all';
                });
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear all filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
        ],
      ),
    );
  }

  void _showEmergencyRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Emergency Medicine Request'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Need medicine urgently? Post an emergency request that will be visible to all donors in your area.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Medicine Name *',
                  hintText: 'e.g., Insulin, Ventolin Inhaler',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medication),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Required Quantity',
                  hintText: 'e.g., 2 strips, 1 vial',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Where do you need it?',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Urgency Details *',
                  hintText: 'Explain why this is urgent...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  hintText: 'For donors to reach you',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Emergency request posted successfully'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Post Emergency Request'),
          ),
        ],
      ),
    );
  }
}