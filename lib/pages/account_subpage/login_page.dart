import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.redirectFrom = '/',
  });

  final String redirectFrom;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
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
                    return '请输入用户名';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                    icon: const Icon(Icons.lock),
                    labelText: '密码',
                    suffixIcon: IconButton(
                      icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    )),
                obscureText: _showPassword,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return '请输入密码';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  final username = _usernameController.text;
                  final password = _passwordController.text;
                  try {
                    SmartDialog.showLoading(msg: '登录中...');
                    await ChatDanRepository().login(username, password);

                    if (mounted) {
                      SmartDialog.showToast('登录成功', displayTime: const Duration(seconds: 1));
                      context.go(widget.redirectFrom);
                    }
                  } catch (e) {
                    // do nothing
                  } finally {
                    SmartDialog.dismiss(status: SmartStatus.loading);
                  }
                },
                child: const Text('登录'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  context.push('/register');
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
