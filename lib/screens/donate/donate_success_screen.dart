import 'package:flutter/material.dart';

class DonateSuccessScreen extends StatelessWidget {
  static const routeName = '/donate_success';
  const DonateSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.check_circle, size: 64, color: Colors.green),
              const SizedBox(height: 12),
              const Text('Thank you!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Your medicine donation has been recorded.'),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/home')), child: const Text('Back to Home')),
            ]),
          ),
        ),
      ),
    );
  }
}
