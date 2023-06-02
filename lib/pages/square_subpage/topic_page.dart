import 'package:chatdan_frontend/model/comment.dart';
import 'package:chatdan_frontend/model/topic.dart';
import 'package:chatdan_frontend/pages/square_subpage/create_comment_page.dart';
import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class TopicPage extends StatefulWidget {
  final Topic topic;

  const TopicPage({required this.topic, super.key});

  @override
  State<TopicPage> createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage>
    with AutomaticKeepAliveClientMixin {
  List<Comment> commentList = [];
  Topic? _topic;
  static const _pageSize = 10;
  static const _pageNum = 1;
  final PagingController<DateTime?, Comment> _pagingController =
      PagingController(firstPageKey: null);
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;

  @override
  bool get wantKeepAlive => true;

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
    _fetchComment();
  }

  Future _getMorecommentList() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      // await Future.delayed(Duration(seconds: 1), () {
      setState(() async {
        // list.addAll(List.generate(5, (i) => '第$_page次上拉来的数据'));
        // TODO: get some new Comments

        List<Comment>? newComments;
        newComments = await ChatDanRepository().loadComments(
            pageNum: _pageNum, pageSize: _pageSize, topicId: _topic!.id);
        newComments ??= [];
        setState(() {
          commentList..addAll(newComments!);
        });
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    _topic = widget.topic;
    super.initState();
    _fetchComment();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // print("get more");
        _getMorecommentList();
      }
    });
  }

  void _onCreateCommentButtonTapped() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreateCommentPage(
                topicId: _topic!.id,
              )),
    ).then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // _getTopic(widget.topicId);
    return Scaffold(
        appBar: buildAppBar(context),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: buildBodyWidget(context),
        ),
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
    // TODO: get comment division
    // final commentName = testTopicJson[''];
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

  // 主体
  Widget buildBodyWidget(BuildContext context) {
    // return Form(
    //     child: ListView(
    //   padding: EdgeInsets.symmetric(horizontal: 20),
    //   children: <Widget>[
    //     buildTopic(context),
    //     buildComments(context),
    //   ],
    // ));
    return CustomScrollView(
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
        return buildCommentWidget(context, comment);
      },
      childCount: commentList.length,
    ));
  }

  Widget buildTopic(BuildContext context) {
    // FIXME: use Sliverlist
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

  Widget buildTopicWidget(BuildContext context) {
    // get user name
    String? topicOwner;
    bool is_anonymous = _topic!.isAnonymous;
    if (is_anonymous) {
      topicOwner = _topic!.anonyname;
    } else {
      // FIXME: get user name
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
          height: MediaQuery.of(context).size.height * 0.35,
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
                  // FIXME: use a widget(icon + text) instead of simple text to show anony
                  // subtitle: Text(topicOwner),
                  subtitle: buildAnonyButton(topicOwner!, is_anonymous),
                ),
              ),

              // 帖子内容展示
              Container(
                padding: EdgeInsets.only(left: 10),
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
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              ),

              // 图片
              // Container(
              //     padding: EdgeInsets.only(left: 10),
              //     width: MediaQuery.of(context).size.width,
              //     child: Wrap(
              //       // mainAxisAlignment: MainAxisAlignment.start,
              //       children: [
              //         buildImageCard("https://via.placeholder.com/150"),
              //         buildImageCard("https://via.placeholder.com/150"),
              //       ],
              //     )),

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
                            Icons.thumb_up,
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
                            Icons.star_purple500_outlined,
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

  // 回复元素
  Widget buildCommentWidget(BuildContext context, Comment comment) {
    // get user name
    String commentOwner;
    bool is_anonymous = comment.isAnonymous;
    if (is_anonymous) {
      commentOwner = comment.anonyname!;
    } else {
      // FIXME: get user name
      commentOwner = comment.poster!.username;
    }
    // // show anony info
    String anonyInfo = '';
    if (comment.isAnonymous) {
      anonyInfo = '匿名用户';
    }
    return GestureDetector(
      child: Container(
          margin: const EdgeInsets.fromLTRB(10, 5, 10, 10),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.35,
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
                  // title: Text(
                  //   "${comment["title"]}",
                  //   textAlign: TextAlign.left,
                  //   style: TextStyle(fontWeight: FontWeight.bold),
                  // ),
                  // // FIXME: use a widget(icon + text) instead of simple text to show anony
                  // // subtitle: Text(topicOwner),
                  // subtitle: buildAnonyButton(commentOwner, is_anonymous),
                  title: Text(
                    commentOwner,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(anonyInfo),
                ),
              ),

              // 帖子内容展示
              Container(
                padding: EdgeInsets.only(left: 10),
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
                      comment.content,
                      textAlign: TextAlign.left,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              ),

              // 图片
              // Container(
              //     padding: EdgeInsets.only(left: 10),
              //     width: MediaQuery.of(context).size.width,
              //     child: Wrap(
              //       // mainAxisAlignment: MainAxisAlignment.start,
              //       children: [
              //         buildImageCard("https://via.placeholder.com/150"),
              //         buildImageCard("https://via.placeholder.com/150"),
              //       ],
              //     )),

              // 元信息（点赞数）
              // TODO: 目前还没有回复的点赞数
              Container(
                  padding: EdgeInsets.all(3),
                  // height: MediaQuery.of(context).size.height * 0.05,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildRowIconButton(
                          // FIXME: change the func into add like num
                          () {},
                          Icon(
                            Icons.thumb_up,
                            color: Colors.grey,
                            size: MediaQuery.of(context).size.height * 0.02,
                          ),
                          comment.likeCount.toString()),
                    ],
                  )),
            ],
          )),
    );
  }

  // 图标+文字
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

  // 匿名用户展示
  Widget buildAnonyButton(String text, bool is_anonymous) {
    if (is_anonymous) {
      // return TextButton.icon(
      //   onPressed: () {},
      //   icon: Icon(
      //     Icons.remove_circle_outline,
      //     color: Colors.black,
      //   ),
      //   label: Text(
      //     text,
      //     style: TextStyle(color: Colors.black),
      //   ),
      // );
      return Row(children: <Widget>[
        Container(
          child: Icon(
            Icons.remove_circle_outline,
            color: Colors.black,
            size: 15,
          ),
        ),
        Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 22),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
      ]);
    } else {
      return Row(children: <Widget>[
        Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 22),
            child: Text(
              text,
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
      ]);
    }
  }

//   Widget buildImageCard(String imgUrl) {
//     return Card(
//       shape: RoundedRectangleBorder(
//           borderRadius: BorderRadiusDirectional.circular(10)),
//       clipBehavior: Clip.antiAlias,
//       child: Image.network(
//         imgUrl,
//         width: 120,
//         height: 120,
//         fit: BoxFit.cover,
//       ),
//     );
//   }
}
