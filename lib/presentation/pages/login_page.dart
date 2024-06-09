import 'package:flutter/material.dart';
import 'package:mystok/common/config_manager.dart';
import 'package:mystok/data/repositories/auth_repository.dart';
import 'package:mystok/presentation/widget/password_field.dart';

class LoginPage extends StatefulWidget {
  final AuthRepository authRepository;

  LoginPage({required this.authRepository});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // init value from config
  @override
  void initState() {
    super.initState();
    ConfigManager.getUsername()
        .then((value) => _emailController.text = value ?? '');
    ConfigManager.getPassword()
        .then((value) => _passwordController.text = value ?? '');
  }

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.authRepository
          .signIn(_emailController.text, _passwordController.text);
      Navigator.pushReplacementNamed(context, '/drugList');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            PasswordField(controller: _passwordController),
            if (_errorMessage != null) ...[
              SizedBox(height: 16),
              Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            ],
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
                  ),
            SizedBox(height: 16),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/apiConfig');
              },
            ),
          ],
        ),
      ),
    );
  }
}
