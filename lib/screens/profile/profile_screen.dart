import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const CircleAvatar(radius: 34, child: Icon(Icons.person, size: 36)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('Mrunmai Dhoble', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('mrunmai@example.com'),
          ])
        ]),
        const SizedBox(height: 20),
        ListTile(leading: const Icon(Icons.history), title: const Text('My Donations')),
        ListTile(leading: const Icon(Icons.receipt_long), title: const Text('My Requests')),
        ListTile(leading: const Icon(Icons.logout), title: const Text('Logout')),
      ]),
    );
  }
}
