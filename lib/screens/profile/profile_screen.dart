import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            SizedBox(height: 10),
            Text("User Name", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.medical_services),
              title: Text("My Donations"),
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text("My Requests"),
            )
          ],
        ),
      ),
    );
  }
}
