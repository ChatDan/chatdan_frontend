import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:chatdan_frontend/bottom_bar.dart';
import 'package:chatdan_frontend/model/message_box.dart';
import 'package:chatdan_frontend/pages/askbox_subpage/create_ask_box_page.dart';
import 'package:chatdan_frontend/pages/askbox_subpage/askbox_detail_page.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';

import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:chatdan_frontend/utils/errors.dart';

class AskboxPage extends StatefulWidget {
  const AskboxPage(this.ownerId, {super.key});
  final int ownerId;
  // const AskboxPage({Key? key}) : super(key: key);

  @override
  _AskboxPageState createState() => _AskboxPageState();
}

class _AskboxPageState extends State<AskboxPage> {
  List<MessageBox> boxes = [];
  bool isLoading = false;

  // 获取提问箱
  Future<void> _fetchMessageBoxes() async {
    try {
      setState(() {
        isLoading = true;
      });

      final fetchedBoxes = await ChatDanRepository()
              .loadMessageBoxes(pageNum: 1, pageSize: 10) ??
          [];

      final userId = widget.ownerId;
      final filteredBoxes =
          fetchedBoxes.where((box) => box.ownerId == userId).toList();

      setState(() {
        boxes = filteredBoxes;
      });
    } catch (e) {
      if (e is DioError && e.error is NotLoginError && mounted) {
        context.go('/login');
      } else {
        SmartDialog.showToast(e.toString(),
            displayTime: const Duration(seconds: 1));
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMessageBoxes();
  }

  // 下拉刷新
  Future<void> _refreshMessageBoxes() async {
    await _fetchMessageBoxes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('提问箱'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMessageBoxes,
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : boxes.isEmpty
                ? const Center(
                    child: Text(
                      '该用户尚未开通提问箱',
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                : ListView.builder(
                    itemCount: boxes.length,
                    itemBuilder: (context, index) {
                      final box = boxes[index];
                      return GestureDetector(
                        onTap: () {
                          // 跳转到对应的提问箱内页
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AskboxDetailPage(box.title, box.id),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          margin:
                              const EdgeInsets.fromLTRB(10, 5, 10, 10), // 调整边距
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(box.title),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      bottomNavigationBar: const BottomBar(index: 2),
      floatingActionButton:
          widget.ownerId == ChatDanRepository().provider.userInfo!.id
              ? FloatingActionButton(
                  onPressed: () {
                    // 创建提问箱
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateAskboxPage(),
                      ),
                    );
                  },
                  child: const Icon(Icons.add),
                )
              : null,
    );
  }
}
