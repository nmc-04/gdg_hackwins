import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/medicine_model.dart';

class MapScreen extends StatefulWidget {
  static const routeName = '/map';

  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _center = LatLng(18.5204, 73.8567); // Pune

  final List<MedicineModel> _donations = [
    MedicineModel(
      id: '1',
      name: 'Paracetamol',
      expiry: '12/2026',
      quantity: 10,
    ),
    MedicineModel(
      id: '2',
      name: 'Insulin',
      expiry: '05/2025',
      quantity: 5,
    ),
  ];

  void _bookDonation(String id) {
    setState(() {
      _donations.removeWhere((m) => m.id == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Donation booked successfully!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Map'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _center,
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.med_donation_app',
          ),
          MarkerLayer(
            markers: _donations.map((medicine) {
              return Marker(
                width: 40,
                height: 40,
                point: LatLng(
                  _center.latitude + (_donations.indexOf(medicine) * 0.01),
                  _center.longitude + (_donations.indexOf(medicine) * 0.01),
                ),
                child: IconButton(
                  icon: const Icon(Icons.local_hospital,
                      color: Colors.red),
                  onPressed: () {
                    _showDonationDetails(medicine);
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showDonationDetails(MedicineModel medicine) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medicine.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Expiry: ${medicine.expiry}'),
            Text('Quantity: ${medicine.quantity}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _bookDonation(medicine.id);
              },
              child: const Text('Book Donation'),
            ),
          ],
        ),
      ),
    );
  }
}
