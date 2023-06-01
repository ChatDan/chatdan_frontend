import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';

import '../../repository/chatdan_repository.dart';
import '../../utils/errors.dart';

class AddQuestionPage extends StatefulWidget {
  final int messageBoxId;
  const AddQuestionPage(this.messageBoxId, {super.key});

  @override
  State<AddQuestionPage> createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  bool _isPrivate = false;
  final _inputController = TextEditingController();

  void _togglePrivacy() {
    setState(() {
      _isPrivate = !_isPrivate;
    });
  }

  void _addQuestion() async {
    final question = _inputController.text;
    try {
      await ChatDanRepository().createAPost(
          messageBoxId: widget.messageBoxId,
          content: question,
          isAnonymous: _isPrivate,
          isPublic: true,
      );
    } catch (e) {
      if (e is DioError && e.error is NotLoginError && mounted) {
        context.go('/login');
      } else {
        SmartDialog.showToast(e.toString());
      }
    }

    // 返回到上一个页面
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新问题'),
        actions: [
          IconButton(
            onPressed: _togglePrivacy,
            icon: Icon(_isPrivate ? Icons.lock : Icons.lock_open),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _inputController,
              decoration: const InputDecoration(labelText: '问题'),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return '请输入问题';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: _addQuestion,
              child: const Text('匿名提问'),
            ),
            ElevatedButton(
              onPressed: _addQuestion,
              child: const Text('普通提问'),
            ),
          ],
        ),
      ),
    );
  }
}