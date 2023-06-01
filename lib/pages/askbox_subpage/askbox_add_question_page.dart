import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:flutter/material.dart';

class AddQuestionPage extends StatefulWidget {
  final int messageBoxId;

  const AddQuestionPage(this.messageBoxId, {super.key});

  @override
  State<AddQuestionPage> createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  final _inputController = TextEditingController();
  bool _isPublic = false;
  bool _isAnonymous = false;

  void _togglePrivacy() {
    setState(() {
      _isPublic = !_isPublic;
    });
  }

  void _addQuestion() async {
    final question = _inputController.text;
    try {
      await ChatDanRepository().createAPost(
        messageBoxId: widget.messageBoxId,
        content: question,
        isAnonymous: _isAnonymous,
        isPublic: _isPublic,
      );
    } catch (e) {
      // do nothing
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
            icon: Icon(_isPublic ? Icons.lock : Icons.lock_open),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
                title: const Text('匿名'),
                value: _isAnonymous,
                onChanged: (value) {
                  setState(() {
                    _isAnonymous = value;
                  });
                }),
            TextFormField(
              controller: _inputController,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: '问题',
                border: OutlineInputBorder(),
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return '请输入问题';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: _addQuestion,
              child: const Text('提问'),
            ),
          ],
        ),
      ),
    );
  }
}
