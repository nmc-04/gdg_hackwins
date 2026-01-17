import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/medicine_model.dart';

class MapScreen extends StatefulWidget {
  static const routeName = '/map';
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapController? _mapController;
  LatLng? _userLocation;
  bool _locationLoading = true;
  String _locationError = '';
  Position? _currentPosition;
  bool _isMapReady = false;

  List<MedicineModel> _donations = [];
  List<Map<String, dynamic>> _pharmacies = [];
  List<Map<String, dynamic>> _ngos = [];
  bool _showDonations = true;
  bool _showPharmacies = true;
  bool _showNgos = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // Wait for the widget to be built before getting location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _getCurrentLocation();
        }
      });
    });
  }

  @override
  void dispose() {
    _mapController = null;
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _locationLoading = true;
        _locationError = '';
      });

      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _locationLoading = false;
            _locationError = 'Location services are disabled. Please enable GPS.';
            _userLocation = const LatLng(18.5204, 73.8567);
          });
          _loadDummyData();
          _moveMapSafely(_userLocation!, 13.0);
        }
        return;
      }

      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _locationLoading = false;
              _locationError = 'Location permissions are denied';
              _userLocation = const LatLng(18.5204, 73.8567);
            });
            _loadDummyData();
            _moveMapSafely(_userLocation!, 13.0);
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _locationLoading = false;
            _locationError = 'Location permissions are permanently denied. Please enable in app settings.';
            _userLocation = const LatLng(18.5204, 73.8567);
          });
          _loadDummyData();
          _moveMapSafely(_userLocation!, 13.0);
        }
        return;
      }

      // Get current position with timeout
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Location request timed out');
        },
      );

      if (mounted) {
        setState(() {
          _userLocation = LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          );
          _locationLoading = false;
        });

        _loadDummyData();
        _moveMapSafely(_userLocation!, 15.0);
      }
    } catch (e) {
      print('Location error: $e');
      if (mounted) {
        setState(() {
          _locationLoading = false;
          _locationError = 'Failed to get location. Using default location.';
          _userLocation = const LatLng(18.5204, 73.8567);
        });
        _loadDummyData();
        _moveMapSafely(_userLocation!, 13.0);
      }
    }
  }

  void _moveMapSafely(LatLng location, double zoom) {
    if (!_isMapReady || _mapController == null) {
      // Wait for map to be ready
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _isMapReady && _mapController != null) {
          try {
            _mapController!.move(location, zoom);
          } catch (e) {
            print('Error moving map: $e');
          }
        }
      });
    } else {
      try {
        _mapController!.move(location, zoom);
      } catch (e) {
        print('Error moving map: $e');
      }
    }
  }

  void _loadDummyData() {
    final baseLocation = _userLocation ?? const LatLng(18.5204, 73.8567);
    
    // Medicine donations
    _donations = [
      MedicineModel(
        id: '1',
        name: 'Paracetamol 500mg',
        expiry: '12/2026',
        quantity: 10,
        latitude: baseLocation.latitude + 0.005,
        longitude: baseLocation.longitude + 0.005,
        type: 'donation',
        status: 'available',
        verified: true,
        donatedBy: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      MedicineModel(
        id: '2',
        name: 'Insulin',
        expiry: '05/2025',
        quantity: 5,
        latitude: baseLocation.latitude - 0.003,
        longitude: baseLocation.longitude + 0.008,
        type: 'donation',
        status: 'available',
        verified: false,
        donatedBy: 'user2',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      MedicineModel(
        id: '3',
        name: 'Aspirin 75mg',
        expiry: '09/2026',
        quantity: 8,
        latitude: baseLocation.latitude + 0.008,
        longitude: baseLocation.longitude - 0.002,
        type: 'donation',
        status: 'available',
        verified: true,
        donatedBy: 'user3',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      MedicineModel(
        id: '4',
        name: 'Vitamin C 1000mg',
        expiry: '08/2025',
        quantity: 15,
        latitude: baseLocation.latitude - 0.006,
        longitude: baseLocation.longitude - 0.004,
        type: 'donation',
        status: 'available',
        verified: true,
        donatedBy: 'user4',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];

    // Pharmacies
    _pharmacies = [
      {
        'name': 'Apollo Pharmacy',
        'latitude': baseLocation.latitude + 0.010,
        'longitude': baseLocation.longitude + 0.010,
        'type': 'pharmacy',
        'address': '24/7 medical store with emergency supplies',
        'phone': '+91 98765 43210',
        'hours': 'Open 24 hours',
        'distance': _calculateDistance(baseLocation, LatLng(
          baseLocation.latitude + 0.010,
          baseLocation.longitude + 0.010,
        )),
      },
      {
        'name': 'Medplus',
        'latitude': baseLocation.latitude - 0.008,
        'longitude': baseLocation.longitude - 0.008,
        'type': 'pharmacy',
        'address': 'Generic medicines at discounted rates',
        'phone': '+91 98765 43211',
        'hours': '8 AM - 10 PM',
        'distance': _calculateDistance(baseLocation, LatLng(
          baseLocation.latitude - 0.008,
          baseLocation.longitude - 0.008,
        )),
      },
      {
        'name': 'Wellness Forever',
        'latitude': baseLocation.latitude + 0.012,
        'longitude': baseLocation.longitude - 0.004,
        'type': 'pharmacy',
        'address': 'Discount on bulk purchase of medicines',
        'phone': '+91 98765 43212',
        'hours': '9 AM - 9 PM',
        'distance': _calculateDistance(baseLocation, LatLng(
          baseLocation.latitude + 0.012,
          baseLocation.longitude - 0.004,
        )),
      },
    ];

    // NGOs
    _ngos = [
      {
        'name': 'HelpAge India',
        'latitude': baseLocation.latitude - 0.012,
        'longitude': baseLocation.longitude + 0.012,
        'type': 'ngo',
        'address': 'Medical aid and support for elderly citizens',
        'phone': '+91 98765 43213',
        'services': 'Free medicines for seniors, health camps',
        'distance': _calculateDistance(baseLocation, LatLng(
          baseLocation.latitude - 0.012,
          baseLocation.longitude + 0.012,
        )),
      },
      {
        'name': 'Red Cross Society',
        'latitude': baseLocation.latitude + 0.006,
        'longitude': baseLocation.longitude - 0.012,
        'type': 'ngo',
        'address': 'Emergency medical assistance and disaster relief',
        'phone': '+91 98765 43214',
        'services': 'Emergency medical kits, blood donation camps',
        'distance': _calculateDistance(baseLocation, LatLng(
          baseLocation.latitude + 0.006,
          baseLocation.longitude - 0.012,
        )),
      },
      {
        'name': 'Robin Hood Army',
        'latitude': baseLocation.latitude - 0.010,
        'longitude': baseLocation.longitude - 0.006,
        'type': 'ngo',
        'address': 'Food and medicine distribution to underprivileged',
        'phone': '+91 98765 43215',
        'services': 'Weekly medicine drives, community health programs',
        'distance': _calculateDistance(baseLocation, LatLng(
          baseLocation.latitude - 0.010,
          baseLocation.longitude - 0.006,
        )),
      },
    ];

    // Sort by distance
    _pharmacies.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    _ngos.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    if (mounted) {
      setState(() {});
    }
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double kmPerDegree = 111.0;
    final double latDiff = (end.latitude - start.latitude).abs();
    final double lonDiff = (end.longitude - start.longitude).abs();
    return (latDiff + lonDiff) * kmPerDegree;
  }

  String _formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).toStringAsFixed(0)}m';
    }
    return '${km.toStringAsFixed(1)}km';
  }

  void _centerOnUserLocation() {
    if (_userLocation != null) {
      _moveMapSafely(_userLocation!, 15.0);
    } else {
      _getCurrentLocation();
    }
  }

  void _refreshLocation() {
    _getCurrentLocation();
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Show on Map',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildFilterOption(
                  'Medicine Donations',
                  Icons.medication,
                  _showDonations,
                  (value) {
                    setModalState(() {
                      _showDonations = value;
                    });
                    setState(() {
                      _showDonations = value;
                    });
                  },
                ),
                _buildFilterOption(
                  'Pharmacies',
                  Icons.local_pharmacy,
                  _showPharmacies,
                  (value) {
                    setModalState(() {
                      _showPharmacies = value;
                    });
                    setState(() {
                      _showPharmacies = value;
                    });
                  },
                ),
                _buildFilterOption(
                  'NGOs',
                  Icons.people,
                  _showNgos,
                  (value) {
                    setModalState(() {
                      _showNgos = value;
                    });
                    setState(() {
                      _showNgos = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply Filters'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterOption(String label, IconData icon, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  void _showMedicineDetails(MedicineModel medicine) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.medication,
                    color: Colors.green,
                    size: 32,
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Available for Request',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.calendar_today, 'Expiry', medicine.expiry),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.numbers, 'Quantity', '${medicine.quantity} tablets/strips'),
            if (_userLocation != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.location_on,
                'Distance',
                _formatDistance(_calculateDistance(
                  _userLocation!,
                  LatLng(medicine.latitude, medicine.longitude),
                )),
              ),
            ],
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.verified,
              'Status',
              medicine.verified ? 'Verified' : 'Unverified',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Request sent for ${medicine.name}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Request This Medicine',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPharmacyDetails(Map<String, dynamic> pharmacy) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_pharmacy,
                    color: Colors.blue,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pharmacy['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pharmacy',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, 'Address', pharmacy['address']),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.phone, 'Phone', pharmacy['phone']),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.access_time, 'Hours', pharmacy['hours']),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.directions, 'Distance', 
              _formatDistance(pharmacy['distance'] as double)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Call pharmacy
                    },
                    child: const Text('Call'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Get directions
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Directions'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNgoDetails(Map<String, dynamic> ngo) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.people,
                    color: Colors.purple,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ngo['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Non-Profit Organization',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, 'Address', ngo['address']),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.phone, 'Contact', ngo['phone']),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.medical_services, 'Services', ngo['services']),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.directions, 'Distance', 
              _formatDistance(ngo['distance'] as double)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Contact NGO
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Contact NGO'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LatLng mapCenter = _userLocation ?? const LatLng(18.5204, 73.8567);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLocation,
            tooltip: 'Refresh location',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
            tooltip: 'Filter locations',
          ),
        ],
      ),
      body: _locationLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Getting your location...'),
                ],
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: mapCenter,
                    initialZoom: 13.0,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                    onMapReady: () {
                      setState(() {
                        _isMapReady = true;
                      });
                      print('Map is ready!');
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.med_donation_app',
                    ),
                    
                    // User location marker
                    if (_userLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 60,
                            height: 60,
                            point: _userLocation!,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withAlpha(150),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_pin_circle,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                        ],
                      ),
                    
                    // Medicine donations (GREEN)
                    if (_showDonations)
                      MarkerLayer(
                        markers: _donations.map((medicine) {
                          return Marker(
                            width: 45,
                            height: 45,
                            point: LatLng(medicine.latitude, medicine.longitude),
                            child: GestureDetector(
                              onTap: () => _showMedicineDetails(medicine),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(76),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.medication,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    
                    // Pharmacies (BLUE)
                    if (_showPharmacies)
                      MarkerLayer(
                        markers: _pharmacies.map((pharmacy) {
                          return Marker(
                            width: 45,
                            height: 45,
                            point: LatLng(pharmacy['latitude'], pharmacy['longitude']),
                            child: GestureDetector(
                              onTap: () => _showPharmacyDetails(pharmacy),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(76),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.local_pharmacy,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    
                    // NGOs (PURPLE)
                    if (_showNgos)
                      MarkerLayer(
                        markers: _ngos.map((ngo) {
                          return Marker(
                            width: 45,
                            height: 45,
                            point: LatLng(ngo['latitude'], ngo['longitude']),
                            child: GestureDetector(
                              onTap: () => _showNgoDetails(ngo),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.purple,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(76),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.people,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
                
                // Legend
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendItem('You', Colors.blue),
                        if (_showDonations) _buildLegendItem('Medicines', Colors.green),
                        if (_showPharmacies) _buildLegendItem('Pharmacies', Colors.blueAccent),
                        if (_showNgos) _buildLegendItem('NGOs', Colors.purple),
                      ],
                    ),
                  ),
                ),
                
                // Location error
                if (_locationError.isNotEmpty)
                  Positioned(
                    top: 16,
                    right: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.orange),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _locationError,
                              style: const TextStyle(color: Colors.orange),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              setState(() {
                                _locationError = '';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Center button
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: _centerOnUserLocation,
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.my_location, color: Colors.white),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}