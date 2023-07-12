import 'package:chatdan_frontend/model/message_box.dart';
import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:chatdan_frontend/model/post.dart';
import 'package:chatdan_frontend/pages/askbox_subpage/askbox_question_answer_detail_page.dart';
import 'package:chatdan_frontend/pages/askbox_subpage/askbox_add_question_page.dart';
import 'package:chatdan_frontend/pages/askbox_subpage/rename_askbox_page.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';

import 'package:chatdan_frontend/utils/errors.dart';

// share
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AskboxDetailPage extends StatefulWidget {
  final MessageBox messageBox;

  AskboxDetailPage(this.messageBox);

  @override
  _AskboxDetailPageState createState() => _AskboxDetailPageState();
}

class _AskboxDetailPageState extends State<AskboxDetailPage> {
  bool _isPublic = true;
  bool isLoading = false;
  List<Post> posts = [];

  Future<void> _fetchPosts() async {
    try {
      setState(() {
        isLoading = true;
      });
      final fetchedPosts = await ChatDanRepository().loadPosts(
          pageNum: 1, pageSize: 10, messageBoxId: widget.messageBox.id);
      setState(() {
        posts = fetchedPosts ?? [];
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
    _fetchPosts();
  }

  Future<void> _refreshPosts() async {
    await _fetchPosts();
  }

  // 是否私密
  void _togglePrivacy() {
    setState(() {
      _isPublic = !_isPublic;
    });
  }

  void _deleteAskbox() async {
    try {
      await ChatDanRepository().deleteAMessageBox(widget.messageBox.id);
      SmartDialog.showToast('提问箱删除成功');
      if (mounted) {
        context.pop(); // 退出
      }
    } catch (e) {
      if (e is DioError && e.error is NotLoginError && mounted) {
        context.go('/login');
      } else {
        SmartDialog.showToast('删除提问箱失败');
      }
    }
  }

  void _setAskbox() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RenameAskboxPage(
          askboxId: widget.messageBox.id,
          currentTitle: widget.messageBox.title,
        ),
      ),
    ).then((newTitle) {
      if (newTitle != null) {
        // 更新标题
        ChatDanRepository()
            .updateAMessageBox(widget.messageBox.id, newTitle)
            .then((updatedMessageBox) {
          // 刷新页面数据
          setState(() {
            widget.messageBox.title = updatedMessageBox.title;
          });
        }).catchError((error) {
          // 处理更新失败的情况
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('更新失败'),
              content: const Text('无法更新提问箱标题，请重试'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('确定'),
                ),
              ],
            ),
          );
        });
      }
    });
  }

  void _navigateToQuestionPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddQuestionPage(widget.messageBox)),
    );
  }

  void _navigateToQuestionAnswerDetail(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              QuestionAnswerDetailPage(post, widget.messageBox.ownerId)),
      // 传递 post 参数给 QuestionAnswerDetailPage
    );
  }

  void _shareAskboxLink() {
    String askboxUrl = 'https://chatdan.top/askbox/${widget.messageBox.id}';

    Clipboard.setData(ClipboardData(text: askboxUrl)).then((value) {
      Fluttertoast.showToast(msg: '链接已复制到剪贴板');
    }).catchError((error) {
      Fluttertoast.showToast(msg: '复制链接失败');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.messageBox.title),
        actions: [
          if (widget.messageBox.ownerId ==
              ChatDanRepository().provider.userInfo!.id)
            IconButton(
              onPressed: _togglePrivacy,
              icon: Icon(_isPublic ? Icons.lock_open : Icons.lock),
            ),
          if (widget.messageBox.ownerId ==
              ChatDanRepository().provider.userInfo!.id)
            IconButton(
              onPressed: _deleteAskbox,
              icon: const Icon(Icons.delete),
            ),
          if (widget.messageBox.ownerId ==
              ChatDanRepository().provider.userInfo!.id)
            IconButton(
              onPressed: _setAskbox,
              icon: const Icon(Icons.settings),
            ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareAskboxLink,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 120,
              margin: const EdgeInsets.fromLTRB(10, 5, 10, 10),
              // width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey,
                  width: 2,
                ),
              ),
              child: SizedBox(
                height: 120,
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.messageBox.ownerId ==
                        ChatDanRepository().provider.userInfo!.id)
                      SmartDialog.showToast('不能自己提问自己');
                    else
                      _navigateToQuestionPage();
                  },
                  style: ButtonStyle(
                    shape:
                    MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    )),
                    shadowColor: MaterialStateProperty.all(
                        Color.fromARGB(255, 185, 185, 185)),
                    minimumSize: MaterialStateProperty.all(Size(150, 0)),
                  ),
                  child:
                  const Text('向我提问！', style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (posts.isEmpty)
              const Center(child: Text('暂无内容'))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return GestureDetector(
                      onTap: () {
                        _navigateToQuestionAnswerDetail(post);
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        margin: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 1),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.isAnonymous
                                  ? '匿名用户'
                                  : post.poster!.username,
                              style:
                              TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              post.content,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Text(
                              post.channels?.first.content ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
