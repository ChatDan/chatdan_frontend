import 'package:chatdan_frontend/model/user.dart';
import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:flutter/material.dart';

class ProfileEditingPage extends StatefulWidget {
  final User user;

  const ProfileEditingPage(this.user, {Key? key}) : super(key: key);

  @override
  State createState() => _ProfileEditingPageState();
}

class _ProfileEditingPageState extends State<ProfileEditingPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _introductionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.user.username;
    _emailController.text = widget.user.email ?? '';
    _introductionController.text = widget.user.introduction ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑个人资料'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
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
                controller: _emailController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.email),
                  labelText: '邮箱',
                ),
              ),
              TextFormField(
                controller: _introductionController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.text_snippet),
                  labelText: '个性签名',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  try {
                    final user = await ChatDanRepository().modifyUserMe(
                      username: _usernameController.text,
                      email: _emailController.text,
                      introduction: _introductionController.text,
                    );

                    setState(() {
                      ChatDanRepository().provider.userInfo = user;
                    });
                  } catch (e) {
                    // do nothing
                  }
                },
                child: const Text('修改'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
