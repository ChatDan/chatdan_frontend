import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:chatdan_frontend/utils/errors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:chatdan_frontend/model/post.dart';
import 'package:chatdan_frontend/pages/askbox_subpage/askbox_question_answer_detail_page.dart';
import 'package:chatdan_frontend/pages/askbox_subpage/askbox_add_question_page.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';

class AskboxDetailPage extends StatefulWidget {
  final String title;
  final int id;

  AskboxDetailPage(this.title, this.id);

  @override
  _AskboxDetailPageState createState() => _AskboxDetailPageState();
}

class _AskboxDetailPageState extends State<AskboxDetailPage> {
  bool _isPrivate = false;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    fetchPosts().then((posts) {
      setState(() {
        this.posts = posts;
      });
    });
  }

  Future<List<Post>> fetchPosts() async {
    try {
      return await ChatDanRepository().loadPosts(pageNum: 1, pageSize: 10, messageBoxId: widget.id) ?? [];
    } catch (e) {
      if (e is DioError && e.error is NotLoginError && mounted) {
        context.go('/login');
      } else {
        SmartDialog.showToast(e.toString(), displayTime: const Duration(seconds: 1));
      }
    }
    return [];
  }

  // 是否私密
  void _togglePrivacy() {
    setState(() {
      _isPrivate = !_isPrivate;
    });
  }

  void _deleteAskbox() {
    // TODO:删除提问箱的逻辑
    // ..

    // 返回到上一个页面
    Navigator.pop(context);
  }

  void _navigateToQuestionPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddQuestionPage(widget.id)),
    );
  }

  void _navigateToQuestionAnswerDetail(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuestionAnswerDetailPage(post)),
      // 传递 post 参数给 QuestionAnswerDetailPage
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _togglePrivacy,
            icon: Icon(_isPrivate ? Icons.lock : Icons.lock_open),
          ),
          IconButton(
            onPressed: _deleteAskbox,
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: _navigateToQuestionPage,
            child: Text('向我提问！'),
          ),
          SizedBox(height: 16),
          if (posts.isEmpty)
            Center(
              child: Text('暂无回复')
            )
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
                    margin: EdgeInsets.symmetric(vertical: 8),
                    color: Colors.grey[200],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.isAnonymous ? '匿名用户' : post.anonyname ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold),
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
    );
  }
}
