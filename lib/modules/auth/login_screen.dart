import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final username = TextEditingController();
    final password = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(controller: username, hint: 'Username'),
            CustomTextField(controller: password, hint: 'Password'),
            const SizedBox(height: 12),
            CustomButton(label: 'Login', onPressed: () => Navigator.pushReplacementNamed(context, '/student'))
          ],
        ),
      ),
    );
  }
}
