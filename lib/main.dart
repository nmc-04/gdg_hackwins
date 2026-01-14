import 'package:flutter/material.dart';

import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'home/home_screen.dart';

void main() {
  runApp(const ShareMyMedsApp());
}

class ShareMyMedsApp extends StatelessWidget {
  const ShareMyMedsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShareMyMeds',
      debugShowCheckedModeBanner: false,

      // 🔥 App theme (matches your logo colors)
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2EB67D), // green from logo
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        fontFamily: 'Roboto',
      ),

      // 👇 Home page when app opens
      initialRoute: '/home',

      // 👇 Navigation routes
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
      },
    );
  }
}
