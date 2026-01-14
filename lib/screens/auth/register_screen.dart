import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';
import '../../services/auth_service.dart';
import '../../core/utils.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final AuthService _auth = AuthService();
  bool _loading = false;

  void _onRegister() async {
    setState(() => _loading = true);
    final ok = await _auth.register(_name.text.trim(), _email.text.trim(), _password.text);
    setState(() => _loading = false);
    if (ok) {
      showSnack(context, 'Registered (prototype). Go to login.');
      Navigator.pop(context);
    } else {
      showSnack(context, 'Please enter valid details (prototype).');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Full name')),
            const SizedBox(height: 10),
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 10),
            TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 18),
            _loading ? const CircularProgressIndicator() : PrimaryButton(label: 'Register', onPressed: _onRegister),
          ],
        ),
      ),
    );
  }
}
