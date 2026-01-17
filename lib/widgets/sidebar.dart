// ============================================
// lib/widgets/sidebar.dart
// FIXED: Added width constraint to Container
// ============================================

import 'package:flutter/material.dart';

class SideBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final bool isCollapsed;
  final VoidCallback? onToggle;

  const SideBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    this.isCollapsed = false,
    this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // FIXED: Added width constraint
      width: isCollapsed ? 80 : 250,
      color: Colors.white,
      child: Column(
        children: [
          // Logo/Header Section
          Container(
            height: 150,
            color: Colors.blue.shade50,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                CircleAvatar(
                  radius: isCollapsed ? 20 : 40,
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    Icons.medical_services,
                    size: isCollapsed ? 24 : 40,
                    color: Colors.blue.shade800,
                  ),
                ),
                
                if (!isCollapsed) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'ShareMyMeds',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  index: 0,
                  isCollapsed: isCollapsed,
                ),
                _buildNavItem(
                  icon: Icons.add_circle,
                  label: 'Donate',
                  index: 1,
                  isCollapsed: isCollapsed,
                ),
                _buildNavItem(
                  icon: Icons.search,
                  label: 'Request',
                  index: 2,
                  isCollapsed: isCollapsed,
                ),
                _buildNavItem(
                  icon: Icons.map,
                  label: 'Map',
                  index: 3,
                  isCollapsed: isCollapsed,
                ),
                _buildNavItem(
                  icon: Icons.person,
                  label: 'Profile',
                  index: 4,
                  isCollapsed: isCollapsed,
                ),
              ],
            ),
          ),
          
          // Collapse/Expand Button
          if (onToggle != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: InkWell(
                onTap: onToggle,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                      color: Colors.grey.shade600,
                    ),
                    if (!isCollapsed) ...[
                      const SizedBox(width: 8),
                      const Text(
                        'Collapse',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isCollapsed,
  }) {
    final bool isSelected = selectedIndex == index;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: Colors.blue.shade200)
            : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
        ),
        title: isCollapsed
            ? null
            : Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.blue.shade800 : Colors.grey.shade800,
                ),
              ),
        trailing: isSelected && !isCollapsed
            ? Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.blue.shade700,
              )
            : null,
        onTap: () => onTap(index),
      ),
    );
  }
}