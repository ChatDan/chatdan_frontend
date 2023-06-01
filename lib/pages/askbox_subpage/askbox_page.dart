import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_clipboard_manager/flutter_clipboard_manager.dart';

import 'package:chatdan_frontend/bottom_bar.dart';
import 'package:chatdan_frontend/model/message_box.dart';
import 'package:chatdan_frontend/pages/askbox_subpage/create_ask_box_page.dart';
import 'package:chatdan_frontend/pages/askbox_subpage/askbox_detail_page.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';

import '../../repository/chatdan_repository.dart';
import '../../utils/errors.dart';

class AskboxPage extends StatefulWidget {
  const AskboxPage({Key? key}) : super(key: key);

  @override
  _AskboxPageState createState() => _AskboxPageState();
}

class _AskboxPageState extends State<AskboxPage> {
  List<MessageBox> boxes = [];
  bool isLoading = false;

  void _shareAskboxLink() {
    // TODO:构建提问箱的链接
    // String askboxUrl = 'https://your-domain.com/askbox/${widget.askboxId}';

    // // 使用 url_launcher 打开链接
    // launch(askboxUrl);

    // // 复制链接到剪贴板
    // FlutterClipboardManager.copyToClipBoard(askboxUrl).then((result) {
    //   if (result) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('链接已复制到剪贴板')),
    //     );
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('复制链接失败')),
    //     );
    //   }
    // });
  }

  // 获取提问箱
  Future<void> _fetchMessageBoxes() async {
    try {
      setState(() {
        isLoading = true;
      });

      final fetchedBoxes = await ChatDanRepository()
              .loadMessageBoxes(pageNum: 1, pageSize: 10) ??
          [];

      final userId = ChatDanRepository().provider.userInfo!.id; // 替换为实际的用户ID
      final filteredBoxes =
          fetchedBoxes.where((box) => box.ownerId == userId).toList();

      setState(() {
        boxes = filteredBoxes;
      });
    } catch (e) {
      if (e is DioError && e.error is NotLoginError && mounted) {
        context.go('/login');
      } else {
        SmartDialog.showToast(e.toString(), displayTime: const Duration(seconds: 1));
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
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareAskboxLink,
          ),
        ],
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
      bottomNavigationBar: BottomBar(index: 2),
      floatingActionButton: FloatingActionButton(
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
      ),
    );
  }
}
