import 'package:chatdan_frontend/model/comment.dart';
import 'package:chatdan_frontend/model/topic.dart';
import 'package:chatdan_frontend/repository/chatdan_repository.dart';
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
    // List Json = [];
    // // Json.add(testTopicJson);
    // for (var i = 1; i < 10; i++) {
    //   Json.add(testCommentJson);
    // }
    // setState(() {
    //   commentList = Json;
    // });
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
    List<Comment>? deleteResultComments;
    deleteResultComments = commentList.where((c) => c.id == id).toList();
    setState(() {
      commentList = deleteResultComments!;
    });
  }

  @override
  void initState() {
    _topic = widget.topic;
    super.initState();
    _fetchComment();
    ChatDanRepository().viewATopic(_topic!.id);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreCommentList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: buildBodyWidget(context),
    );
  }

  Widget buildBodyWidget(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
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
        return buildTopicWidget(context);
      },
      childCount: 1,
    ));
  }

  // TODO: after packaging the following part in topic.dart, delete following part
  Widget buildTopicWidget(BuildContext context) {
    // get user name
    String? topicOwner;
    bool is_anonymous = _topic!.isAnonymous;
    if (is_anonymous) {
      topicOwner = _topic!.anonyname;
    } else {
      topicOwner = _topic!.poster!.username;
    }
    // // show anony info
    // String anonyInfo = "";
    // if (comment['is_anonymous']) {
    //   anonyInfo = "匿名用户";
    // }
    return GestureDetector(
      onTap: () {
        // Map<String, dynamic> commentData = {
        //   'id': comment['id'],
        // };

        // Navigator.pushNamed(context, "/commentDetail",
        //     arguments: {"commentId": comment['id']});
      },
      child: Container(
          margin: const EdgeInsets.fromLTRB(10, 5, 10, 10),
          width: MediaQuery.of(context).size.width,
          // height: MediaQuery.of(context).size.height * 0.2,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ], color: Colors.white, borderRadius: BorderRadius.circular((20))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 用户ID展示（用户名称，是否匿名）
              Container(
                child: ListTile(
                  // leading: Card(
                  //   shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadiusDirectional.circular(10)),
                  //   clipBehavior: Clip.antiAlias,
                  //   child: Image.network(
                  //     'http://q2.qlogo.cn/headimg_dl?dst_uin=1019383856&spec=100',
                  //     width: 40,
                  //     height: 40,
                  //     fit: BoxFit.cover,
                  //   ),
                  // ),
                  title: Text(
                    _topic!.title,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // subtitle: Text(topicOwner),
                  subtitle: buildTopicOwnerButton(_topic!),
                ),
              ),

              // 帖子内容展示
              Container(
                padding: EdgeInsets.all(15),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Text(
                    //   "${comment["title"]}",
                    //   textAlign: TextAlign.left,
                    //   style: TextStyle(fontWeight: FontWeight.bold),
                    // ),
                    Text(
                      _topic!.content,
                      textAlign: TextAlign.left,
                      // maxLines: 3,
                      // overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              ),

              // 元信息（点赞数，收藏数，评论数）
              Container(
                  padding: EdgeInsets.all(3),
                  // height: MediaQuery.of(context).size.height * 0.05,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildRowIconButton(
                          // FIXME: change the func into add like num
                          _fetchComment,
                          Icon(
                            Icons.favorite_border,
                            color: Colors.grey,
                            size: MediaQuery.of(context).size.height * 0.02,
                          ),
                          _topic!.likeCount.toString()),
                      buildRowIconButton(
                          // FIXME: add favor num
                          _fetchComment,
                          Icon(
                            Icons.visibility,
                            color: Colors.grey,
                            size: MediaQuery.of(context).size.height * 0.02,
                          ),
                          _topic!.viewCount.toString()),
                      buildRowIconButton(
                          // FIXME: add favor num
                          _fetchComment,
                          Icon(
                            Icons.star_border,
                            color: Colors.grey,
                            size: MediaQuery.of(context).size.height * 0.02,
                          ),
                          _topic!.favoriteCount.toString()),
                    ],
                  )),
            ],
          )),
    );
  }

  Widget buildTopicOwnerButton(Topic article) {
    if (article.isAnonymous) {
      final text = article.anonyname!;
      return Row(children: <Widget>[
        const Icon(
          Icons.remove_circle_outline,
          color: Colors.black,
          size: 15,
        ),
        Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 22),
            padding: EdgeInsets.only(left: 5),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
      ]);
    } else {
      final poster = article.poster!;
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UserProfilePage(user: poster)));
        },
        child: Row(children: <Widget>[
          CircleAvatar(
            backgroundImage:
                poster.avatar == null ? null : NetworkImage(poster.avatar!),
            radius: 10,
          ),
          Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 22),
              padding: EdgeInsets.only(left: 5),
              child: Text(
                poster.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
          // Container(
          //   child: Icon(
          //     Icons.remove_circle_outline,
          //     color: Colors.white,
          //     size: 15,
          //   ),
          // ),
        ]),
      );
    }
  }

  Widget buildRowIconButton(Function func, Icon icon, String text) {
    return TextButton.icon(
      onPressed: () {
        func();
      },
      icon: icon,
      label: Text(
        text,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
