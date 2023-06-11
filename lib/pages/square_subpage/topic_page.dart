import 'package:chatdan_frontend/model/comment.dart';
import 'package:chatdan_frontend/model/topic.dart';
import 'package:chatdan_frontend/pages/square_subpage/create_comment_page.dart';
import 'package:chatdan_frontend/pages/square_subpage/list_topic_and_comments_page.dart';
import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:date_format/date_format.dart';

import '../account_subpage/profile.dart';

class TopicPage extends StatefulWidget {
  final Topic topic;

  const TopicPage({required this.topic, super.key});

  @override
  State<TopicPage> createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage>
    with AutomaticKeepAliveClientMixin {
  Topic? _topic;
  bool isLoading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _topic = widget.topic;
    super.initState();
  }

  void _onCreateCommentButtonTapped() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreateCommentPage(
                topicId: _topic!.id,
              )),
    ).then((value) {
      if (value != null) {
        // TODO: refresh the inner page
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context),
        body: ListCommentsWidget(topic: _topic),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _onCreateCommentButtonTapped();
          },
          backgroundColor: Colors.teal,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ));
  }

  // 顶部导航栏
  PreferredSizeWidget buildAppBar(BuildContext context) {
    return AppBar(
      // title: const Text("AppBarDemoPage"),
      backgroundColor: Colors.white,
      elevation: 0,
      // centerTitle: true,
      // toolbarHeight: 35,
      title: Text(
        '#' + _topic!.id.toString(),
        style: TextStyle(height: 8),
      ),
      leading: IconButton(
          onPressed: () {
            GoRouter.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios_new)),
    );
  }
}
