import 'package:flutter/material.dart';
import 'package:mystok/data/repositories/auth_repository.dart';
import 'package:mystok/presentation/pages/drug_list_page.dart';

class LoginPage extends StatefulWidget {
  final AuthRepository authRepository;

  LoginPage({required this.authRepository});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    try {
      print(_emailController.text);
      print(_passwordController.text);
      await widget.authRepository.signIn(
        _emailController.text,
        _passwordController.text,
      );
      // Navigate to the main page
      Navigator.pushReplacementNamed(context, '/drugList');
    } catch (e) {
      // Handle error
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
