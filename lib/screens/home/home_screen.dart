// home_screen.dart - Mobile-Friendly Version with Drawer
import 'package:flutter/material.dart';
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
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = [
    const DashboardPage(),
    const AddMedicineScreen(),
    const MedicineListScreen(),
    const MapScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Close the drawer after selection
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: Icon(Icons.menu, color: AppTheme.lightTheme.primaryColor),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          _getTitle(_selectedIndex),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.lightTheme.primaryColor,
          ),
        ),
        actions: [
          Icon(Icons.notifications_none, color: Colors.grey[600]),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.lightTheme.primaryColor.withOpacity(0.1),
            child: Icon(
              Icons.person,
              size: 16,
              color: AppTheme.lightTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // Header Section
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.lightTheme.primaryColor,
                    AppTheme.lightTheme.primaryColor.withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.medical_services,
                      size: 40,
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ShareMyMeds',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mrunmai',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard,
                    label: 'Dashboard',
                    index: 0,
                  ),
                  _buildDrawerItem(
                    icon: Icons.add_circle,
                    label: 'Donate Medicine',
                    index: 1,
                  ),
                  _buildDrawerItem(
                    icon: Icons.search,
                    label: 'Request Medicine',
                    index: 2,
                  ),
                  _buildDrawerItem(
                    icon: Icons.map,
                    label: 'Medicine Map',
                    index: 3,
                  ),
                  _buildDrawerItem(
                    icon: Icons.person,
                    label: 'Profile',
                    index: 4,
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.settings, color: Colors.grey[700]),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.help_outline, color: Colors.grey[700]),
                    title: const Text('Help & Support'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.red[400]),
                    title: const Text('Logout'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.grey[50],
        child: _pages[_selectedIndex],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.lightTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.lightTheme.primaryColor : Colors.grey[700],
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppTheme.lightTheme.primaryColor : Colors.grey[800],
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppTheme.lightTheme.primaryColor,
              )
            : null,
        onTap: () => _onItemTapped(index),
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Donate Medicine';
      case 2:
        return 'Request Medicine';
      case 3:
        return 'Medicine Map';
      case 4:
        return 'Profile';
      default:
        return 'ShareMyMeds';
    }
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
          // Welcome Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.lightTheme.primaryColor.withOpacity(0.1),
                  Colors.blue.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back! 👋',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.lightTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'From shelf to help - Share your unused medicines with those in need',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Icon(
                    Icons.medical_services,
                    size: 60,
                    color: AppTheme.lightTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard(
                icon: Icons.medication,
                value: '12',
                label: 'Donated',
                color: Colors.green,
              ),
              _buildStatCard(
                icon: Icons.people,
                value: '6',
                label: 'Helped',
                color: Colors.blue,
              ),
              _buildStatCard(
                icon: Icons.request_page,
                value: '3',
                label: 'Requests',
                color: Colors.orange,
              ),
              _buildStatCard(
                icon: Icons.star,
                value: '150',
                label: 'Points',
                color: Colors.purple,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Emergency Alert
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        'Emergency Request',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.red[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Insulin needed urgently in Thane area',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {},
                      child: const Text('Respond to Request'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Recent Activity Section
          Text(
            'Recent Donations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),

          _buildDonationCard(
            medicine: 'Paracetamol 500mg',
            quantity: '2 strips',
            expiry: '12/2026',
            status: 'Completed',
            statusColor: Colors.green,
            iconColor: Colors.blue,
          ),

          const SizedBox(height: 8),

          _buildDonationCard(
            medicine: 'Vitamin C 500mg',
            quantity: '1 bottle',
            expiry: '06/2026',
            status: 'Pending',
            statusColor: Colors.orange,
            iconColor: Colors.orange,
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationCard({
    required String medicine,
    required String quantity,
    required String expiry,
    required String status,
    required Color statusColor,
    required Color iconColor,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.medication, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Qty: $quantity • Expires: $expiry',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}