import 'package:chatdan_frontend/model/comment.dart';
import 'package:chatdan_frontend/model/topic.dart';
import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:chatdan_frontend/widgets/topic.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../widgets/comment.dart';
import '../account_subpage/profile.dart';

class ListCommentsWidget extends StatefulWidget {
  final Topic? topic;

  const ListCommentsWidget({this.topic, super.key});

  @override
  State<ListCommentsWidget> createState() => _ListCommentsWidgetState();
}

class _ListCommentsWidgetState extends State<ListCommentsWidget> {
  List<Comment> commentList = [];
  Topic? _topic;
  int _pageNum = 1;
  static const _pageSize = 10;
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();
  final PagingController<DateTime?, Comment> _pagingController =
      PagingController(firstPageKey: null);

  void _fetchComment() async {
    try {
      List<Comment>? newComments;
      newComments = await ChatDanRepository().loadComments(
          pageNum: _pageNum, pageSize: _pageSize, topicId: _topic!.id);
      newComments ??= [];
      setState(() {
        _pageNum++;
        commentList = newComments!;
      });

      // final isLastPage = newComments.length < _pageSize;
      // if (isLastPage) {
      //   _pagingController.appendLastPage(newComments);
      // } else {
      //   _pagingController.appendPage(newComments, newComments.last.createdAt);
      // }
    } catch (e) {
      _pagingController.error = e;
    }
  }

  Future<Null> _onRefresh() async {
    _pageNum = 1;
    _fetchComment();
  }

  Future _getMoreCommentList() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      List<Comment>? newComments;
      newComments = await ChatDanRepository().loadComments(
          pageNum: _pageNum, pageSize: _pageSize, topicId: _topic!.id);
      newComments ??= [];
      setState(() {
        _pageNum++;
        commentList..addAll(newComments!);
      });
      isLoading = false;
    }
  }

  void _deleteCommentById(int id) {
    // List<Comment>? deleteResultComments;

    for (var i = 0; i != commentList.length;) {
      if (commentList[i].id == id) {
        commentList.removeAt(i);
      } else {
        i++;
      }
    }
    setState(() {
      // commentList = deleteResultComments!;
    });
  }

  @override
  void initState() {
    _topic = widget.topic;
    _fetchComment();
    ChatDanRepository().viewATopic(_topic!.id);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreCommentList();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _onRefresh();
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: buildBodyWidget(context),
    );
  }

  Widget buildBodyWidget(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        buildTopic(context),
        buildComments(context),
      ],
    );
  }

  Widget buildComments(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (context, index) {
        Comment comment = commentList[index];
        // return buildCommentWidget(context, comment);
        return CommentWidget(
          comment: comment,
          deleteFunc: _deleteCommentById,
        );
      },
      childCount: commentList.length,
    ));
  }

  Widget buildTopic(BuildContext context) {
    // return buildTopicWidget(context);
    // return ListView.builder(
    //   itemCount: 1,
    //   itemBuilder: (context, index) {
    //     return buildTopicWidget(context);
    //   },
    // );
    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (context, index) {
        // return buildTopicWidget(context);
        return TopicWidget(
          topic: _topic!,
          type: 2,
        );
      },
      childCount: 1,
    ));
  }
}
