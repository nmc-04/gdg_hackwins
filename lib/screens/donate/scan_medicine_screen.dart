import 'package:flutter/material.dart';

class ScanMedicineScreen extends StatelessWidget {
  static const routeName = '/scan';
  const ScanMedicineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Medicine")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, size: 80, color: Colors.teal),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Scan Now"),
            )
          ],
        ),
      ),
    );
  }
}
