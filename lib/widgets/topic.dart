import 'package:chatdan_frontend/model/topic.dart';
import 'package:chatdan_frontend/pages/account_subpage/profile.dart';
import 'package:chatdan_frontend/pages/square_subpage/create_comment_page.dart';
import 'package:chatdan_frontend/pages/square_subpage/topic_page.dart';
import 'package:flutter/material.dart';

import '../repository/chatdan_repository.dart';

class TopicWidget extends StatefulWidget {
  final Topic topic;
  final int type;

  const TopicWidget({
    Key? key,
    required this.type,
    required this.topic,
  }) : super(key: key);

  @override
  State<TopicWidget> createState() => _TopicWidgetState();
}

class _TopicWidgetState extends State<TopicWidget> {
  // final article = widget.topic;
  // String topicOwner;
  late final Topic article;
  late int topicId;
  late int _likeCount;
  late bool _isLiked;
  late int _commentCount;
  late int _favorCount;
  late bool _isfavored;

  @override
  void initState() {
    article = widget.topic;
    topicId = article.id;
    _likeCount = article.likeCount;
    _isLiked = article.liked;
    _commentCount = article.commentCount;
    _favorCount = article.favoriteCount;
    _isfavored = article.favored;
  }

  void _createCommentInSquare() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CreateCommentPage(
                  topicId: topicId,
                ))).then((value) {
      setState(() {
        _commentCount = _commentCount + 1;
      });
    });
  }

  void _likeTopic() {
    try {
      if (_isLiked == false) {
        // like a topic
        // ChatDanRepository().likeATopic(article.id).then((value) {
        //   setState(() {
        //     _likeCount += 1;
        //   });
        // });
        setState(() {
          _likeCount = _likeCount + 1;
          _isLiked = true;
        });
        ChatDanRepository().likeATopic(topicId);
      } else {
        // dislike a topic
        // ChatDanRepository().dislikeATopic(article.id).then((value) {
        //   setState(() {
        //     _likeCount -= 1;
        //   });
        // });
        ChatDanRepository().unlikeATopic(topicId);
        setState(() {
          _likeCount = _likeCount - 1;
          _isLiked = false;
        });
      }
    } catch (e) {
      // do nothing
    }
  }

  void _favorTopic() {
    try {
      if (_isfavored == false) {
        // like a topic
        // ChatDanRepository().likeATopic(article.id).then((value) {
        //   setState(() {
        //     _likeCount += 1;
        //   });
        // });
        ChatDanRepository().favorATopic(topicId);
        setState(() {
          _favorCount = _favorCount + 1;
          _isfavored = true;
        });
      } else {
        // dislike a topic
        // ChatDanRepository().dislikeATopic(article.id).then((value) {
        //   setState(() {
        //     _likeCount -= 1;
        //   });
        // });
        ChatDanRepository().unfavorATopic(topicId);
        setState(() {
          _favorCount = _favorCount - 1;
          _isfavored = false;
        });
      }
    } catch (e) {
      // do nothing
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == 1) {
      String topicOwner;
      // topicId = article.id;

      // get user name
      if (article.isAnonymous) {
        topicOwner = article.anonyname!;
      } else {
        topicOwner = article.poster!.username;
      }
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TopicPage(topic: article)));
        },
        child: Container(
            margin: const EdgeInsets.fromLTRB(10, 5, 10, 10),
            width: MediaQuery.of(context).size.width,
            // height: MediaQuery.of(context).size.height * 0.3,
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ], color: Colors.white, borderRadius: BorderRadius.circular((20))),
            child: Column(
              children: [
                // 用户ID展示（用户名称，是否匿名）
                Container(
                  child: ListTile(
                    title: Text(
                      article.title,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // FIXME: use a widget(icon + text) instead of simple text to show anony
                    // subtitle: Text(topicOwner),
                    subtitle: buildAnonyButton(article),
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
                      //   "${article["title"]}",
                      //   textAlign: TextAlign.left,
                      //   style: TextStyle(fontWeight: FontWeight.bold),
                      // ),
                      Text(
                        article.content,
                        textAlign: TextAlign.left,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),

                // tags
                Container(
                  alignment: Alignment(-1, 0),
                  padding: EdgeInsets.all(5),
                  child: Wrap(
                    spacing: 7,
                    children: article.tags
                            ?.map((e) => Chip(
                                  label: Text(e.name),
                                  // labelPadding: EdgeInsets.only(
                                  //     left: 2, right: 2, top: -5, bottom: -5),
                                ))
                            .toList() ??
                        [],
                  ),
                ),

                // 元信息（点赞数，收藏数，评论数）
                Container(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.all(3),
                    // height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildRowIconButton(
                            // FIXME: change the func into add like num
                            _likeTopic,
                            Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                              color: Colors.grey,
                              size: MediaQuery.of(context).size.height * 0.02,
                            ),
                            _likeCount.toString()),
                        buildRowIconButton(
                            // FIXME: direct comment
                            _createCommentInSquare,
                            Icon(
                              Icons.message,
                              color: Colors.grey,
                              size: MediaQuery.of(context).size.height * 0.02,
                            ),
                            _commentCount.toString()),
                        buildRowIconButton(
                            // FIXME: add favor num
                            _favorTopic,
                            Icon(
                              _isfavored ? Icons.star : Icons.star_border,
                              color: Colors.grey,
                              size: MediaQuery.of(context).size.height * 0.02,
                            ),
                            _favorCount.toString()),
                      ],
                    )),
              ],
            )),
      );
    } else {
      // get user name
      String? topicOwner;
      bool is_anonymous = article.isAnonymous;
      if (is_anonymous) {
        topicOwner = article.anonyname;
      } else {
        topicOwner = article.poster!.username;
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
                      article.title,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // subtitle: Text(topicOwner),
                    subtitle: buildTopicOwnerButton(article),
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
                        article.content,
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
                            _likeTopic,
                            Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                              color: Colors.grey,
                              size: MediaQuery.of(context).size.height * 0.02,
                            ),
                            _likeCount.toString()),
                        buildRowIconButton(
                            // FIXME: add favor num
                            () {},
                            Icon(
                              Icons.visibility,
                              color: Colors.grey,
                              size: MediaQuery.of(context).size.height * 0.02,
                            ),
                            article.viewCount.toString()),
                        buildRowIconButton(
                            // FIXME: add favor num
                            _favorTopic,
                            Icon(
                              _isfavored ? Icons.star : Icons.star_border,
                              color: Colors.grey,
                              size: MediaQuery.of(context).size.height * 0.02,
                            ),
                            _favorCount.toString()),
                      ],
                    )),
              ],
            )),
      );
    }
  }

  Widget buildAnonyButton(Topic article) {
    if (article.isAnonymous) {
      final text = article.anonyname!;
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
        ]),
      );
    }
  }

  // 图片文字
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
