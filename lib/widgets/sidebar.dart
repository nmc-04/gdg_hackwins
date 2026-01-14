import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class SideBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const SideBar({super.key, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 28),
          // Logo area
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Image.asset('assets/images/logo.png', height: 64),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _navItem(Icons.home_outlined, 'Home', 0),
          _navItem(Icons.volunteer_activism_outlined, 'Donate', 1),
          _navItem(Icons.list_alt_outlined, 'Requests', 2),
          _navItem(Icons.map_outlined, 'Map', 3),
          _navItem(Icons.person_outline, 'Profile', 4),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int idx) {
    final selected = idx == selectedIndex;
    return ListTile(
      leading: Icon(icon, color: selected ? AppTheme.lightTheme.primaryColor : Colors.grey[700]),
      title: Text(label, style: TextStyle(color: selected ? AppTheme.lightTheme.primaryColor : Colors.black)),
      selected: selected,
      onTap: () => onTap(idx),
    );
  }
}
