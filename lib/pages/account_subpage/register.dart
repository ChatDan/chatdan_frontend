import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _submitForm() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    try {
      SmartDialog.showLoading(msg: '注册中...');
      await ChatDanRepository().register(username, password);

      if (mounted) {
        SmartDialog.showToast('注册成功', displayTime: const Duration(seconds: 3));
        context.go('/');
      }
    } catch (e) {
      // do nothing, toast in dio interceptor
    } finally {
      SmartDialog.dismiss(status: SmartStatus.loading);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('注册'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  labelText: '用户名',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.lock),
                  labelText: '密码',
                ),
                obscureText: true,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    _submitForm();
                  }
                },
                child: const Text('注册'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
