import 'package:flutter/material.dart';
import 'bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BottomNav();
  }
}
