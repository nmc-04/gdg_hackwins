import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/ShareMyMeds.png',
              width: 300,
            ),

            const SizedBox(height: 20),

            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text("Login"),
            ),

            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: const Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
