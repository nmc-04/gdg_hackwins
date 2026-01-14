import 'package:flutter/material.dart';

class RequestStatusScreen extends StatelessWidget {
  static const routeName = '/request_status';

  const RequestStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Request Status Screen',
        style: TextStyle(fontSize: 22),
      ),
    );
  }
}

