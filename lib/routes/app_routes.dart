// lib/routes/app_routes.dart
import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/donate/scan_medicine_screen.dart';
import '../screens/donate/add_medicine_screen.dart' as donate_screen;
import '../screens/donate/donate_success_screen.dart';
import '../screens/request/medicine_list_screen.dart';
import '../screens/request/medicine_detail_screen.dart';
import '../screens/request/request_status_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/profile/profile_screen.dart' as profile_screen;
import '../screens/profile/my_donations_screen.dart'; // Add this
import '../screens/profile/my_requests_screen.dart'; // Add this
import '../screens/profile/saved_items_screen.dart'; // Add this

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    LoginScreen.routeName: (_) => const LoginScreen(),
    RegisterScreen.routeName: (_) => const RegisterScreen(),
    HomeScreen.routeName: (_) => const HomeScreen(),
    ScanMedicineScreen.routeName: (_) => const ScanMedicineScreen(),
    // Use alias to resolve ambiguous import
    donate_screen.AddMedicineScreen.routeName: (_) => const donate_screen.AddMedicineScreen(),
    DonateSuccessScreen.routeName: (_) => const DonateSuccessScreen(),
    MedicineListScreen.routeName: (_) => const MedicineListScreen(),
    MedicineDetailScreen.routeName: (_) => const MedicineDetailScreen(),
    RequestStatusScreen.routeName: (_) => const RequestStatusScreen(),
    MapScreen.routeName: (_) => const MapScreen(),
    
    // Add profile section routes
    '/my_donations': (_) => const MyDonationsScreen(),
    '/my_requests': (_) => const MyRequestsScreen(),
    '/saved_items': (_) => const SavedItemsScreen(),
  };
}