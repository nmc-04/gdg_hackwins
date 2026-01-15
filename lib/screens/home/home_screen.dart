import 'package:flutter/material.dart';
import '../../widgets/sidebar.dart';
import '../donate/add_medicine_screen.dart';
import '../request/medicine_list_screen.dart';
import '../map/map_screen.dart';
import '../profile/profile_screen.dart';
import '../../core/app_theme.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final List<Widget> _pages = [
    DashboardPage(),
    AddMedicineScreen(),
    MedicineListScreen(),
    MapScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideBar(selectedIndex: _index, onTap: (i) => setState(() => _index = i)),
          Expanded(
            child: Column(
              children: [
                // Top app bar with title and logo on right
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Text('ShareMyMeds', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.lightTheme.primaryColor)),
                      const Spacer(),
                      Image.asset('assets/images/logo.png', height: 44),
                    ],
                  ),
                ),
                Expanded(child: _pages[_index]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text('From shelf to help', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.warning, color: Colors.red),
              title: const Text('Emergency Request'),
              subtitle: const Text('Insulin needed in Thane'),
              trailing: ElevatedButton(onPressed: () {}, child: const Text('View')),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('12 Medicines Donated'),
              subtitle: const Text('You helped 6 patients'),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Recent Donations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          // Placeholders: you can replace with Firestore data
          const ListTile(leading: Icon(Icons.medication), title: Text('Paracetamol 500mg'), subtitle: Text('Qty 2 - Expires 12/2026')),
          const ListTile(leading: Icon(Icons.medication), title: Text('Vitamin C 500mg'), subtitle: Text('Qty 1 - Expires 06/2026')),
        ],
      ),
    );
  }
}
