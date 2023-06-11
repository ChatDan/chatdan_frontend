import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:chatdan_frontend/utils/errors.dart';

class RenameAskboxPage extends StatefulWidget {
  final int askboxId;
  final String currentTitle;

  RenameAskboxPage({required this.askboxId, required this.currentTitle});

  @override
  _RenameAskboxPageState createState() => _RenameAskboxPageState();
}

class _RenameAskboxPageState extends State<RenameAskboxPage> {
  TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.currentTitle;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
  void _updateTitle() async {
    String newTitle = _titleController.text;
    if (newTitle.isNotEmpty) {
      try {
        await ChatDanRepository().updateAMessageBox(widget.askboxId, newTitle);
      } catch (e) {
        if (e is DioError && e.error is NotLoginError && mounted) {
          context.go('/login');
        } else {
          SmartDialog.showToast(e.toString());
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('标题不能为空'),
          content: const Text('请输入一个有效的标题'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    }
    if (mounted) Navigator.pop(context, newTitle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('重命名提问箱'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '新标题',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _updateTitle,
              child: const Text('更新'),
            ),
          ],
        ),
      ),
    );
  }
}
