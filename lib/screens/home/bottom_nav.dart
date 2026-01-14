import 'package:flutter/material.dart';
import '../donate/scan_medicine_screen.dart';
import '../map/map_screen.dart';
import '../profile/profile_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int index = 0;

  final screens = const [
    HomeTab(),
    ScanMedicineScreen(),
    MapScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: Colors.teal,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Donate"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Nearby"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medicine Donation")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Your medicines can save lives ❤️",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: Icon(Icons.warning, color: Colors.red),
                title: Text("Emergency Request"),
                subtitle: Text("Insulin needed in Thane"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
