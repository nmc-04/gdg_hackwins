import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/donate/scan_medicine_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    LoginScreen.routeName: (_) => const LoginScreen(),
    RegisterScreen.routeName: (_) => const RegisterScreen(),
    HomeScreen.routeName: (_) => const HomeScreen(),
    ScanMedicineScreen.routeName: (_) => const ScanMedicineScreen(),
    MapScreen.routeName: (_) => const MapScreen(),
    ProfileScreen.routeName: (_) => const ProfileScreen(),
  };
}
