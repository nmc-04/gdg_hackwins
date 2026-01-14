import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'core/app_theme.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const MedDonationApp());
}

class MedDonationApp extends StatelessWidget {
  const MedDonationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicine Donation',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: LoginScreen.routeName,
      routes: AppRoutes.routes,
    );
  }
}
