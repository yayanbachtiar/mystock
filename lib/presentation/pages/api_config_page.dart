import 'package:flutter/material.dart';
import 'package:mystok/common/config_manager.dart';
import 'package:mystok/presentation/widget/password_field.dart';

class ApiConfigPage extends StatefulWidget {
  const ApiConfigPage({super.key});

  @override
  ApiConfigPageState createState() => ApiConfigPageState();
}

class ApiConfigPageState extends State<ApiConfigPage> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ConfigManager.getApiUrl()
        .then((value) => {_urlController.text = value ?? ''});
    ConfigManager.getUsername()
        .then((value) => _usernameController.text = value ?? '');
    ConfigManager.getPassword()
        .then((value) => _passwordController.text = value ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Configuration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'API URL',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            PasswordField(controller: _passwordController),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                if (_urlController.text.isEmpty ||
                    _usernameController.text.isEmpty ||
                    _passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Harap isi semua kolom!')),
                  );
                } else {
                  await ConfigManager.setApiUrl(_urlController.text);
                  await ConfigManager.setUsername(_usernameController.text);
                  await ConfigManager.setPassword(_passwordController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('API URL berhasil disimpan!')),
                  );
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
