import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  static const routeName = '/map';
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nearby Collection Points")),
      body: const Center(
        child: Text("Map will be integrated here"),
      ),
    );
  }
}
