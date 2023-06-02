import 'package:chatdan_frontend/utils/errors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';

import 'package:chatdan_frontend/repository/chatdan_repository.dart';


class CreateAskboxPage extends StatefulWidget {
  @override
  _CreateAskboxPageState createState() => _CreateAskboxPageState();
}

class _CreateAskboxPageState extends State<CreateAskboxPage> {
  final TextEditingController _askboxNameController = TextEditingController();

  @override
  void dispose() {
    _askboxNameController.dispose();
    super.dispose();
  }

  Future<void> _createAskbox() async {
    // 获取文本框内的提问箱名字
    String askboxName = _askboxNameController.text;

    // 创建新的提问箱
    try {
      await ChatDanRepository().createAMessageBox(askboxName);
    } catch (e) {
      if (e is DioError && e.error is NotLoginError && mounted) {
        context.go('/login');
      } else {
        SmartDialog.showToast(e.toString(), displayTime: const Duration(seconds: 1));
      }
    }

    // 返回到 AskboxPage 界面
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新建提问箱'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _askboxNameController,
              decoration: InputDecoration(
                labelText: '新提问箱名',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createAskbox,
              child: const Text('创建新提问箱'),
            ),
          ],
        ),
      ),
    );
  }
}
