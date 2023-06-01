import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class CreateWallPage extends StatefulWidget {
  const CreateWallPage({super.key});

  @override
  State createState() => _CreateWallPageState();
}

class _CreateWallPageState extends State<CreateWallPage> {
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isAnonymous = false;

  void _uploadTopic() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final content = _contentController.text;
    try {
      SmartDialog.showLoading(msg: '发送中...');
      await ChatDanRepository().createAWall(content, _isAnonymous);
      if (mounted) {
        SmartDialog.showToast('发送成功', displayTime: const Duration(seconds: 1));
        Navigator.pop(context);
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
            title: const Text('发送表白墙'),
            actions: [IconButton(onPressed: _uploadTopic, icon: Icon(Icons.send_outlined))]),
        body: Form(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              SwitchListTile(
                  title: Text('匿名'),
                  value: _isAnonymous,
                  onChanged: (value) {
                    setState(() {
                      _isAnonymous = value;
                    });
                  }),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _contentController,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    hintText: '请输入内容',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '内容不能为空';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
