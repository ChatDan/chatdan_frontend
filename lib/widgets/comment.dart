import 'package:chatdan_frontend/model/comment.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

import '../pages/account_subpage/profile.dart';
import '../repository/chatdan_repository.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;
  final Function deleteFunc;

  const CommentWidget(
      {required this.comment, required this.deleteFunc, Key? key})
      : super(key: key);

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  late Comment comment;
  late int commentId;
  late int _favorCount;
  late bool _isfavored;
  static final provider = ChatDanRepository().provider;

  @override
  void initState() {
    comment = widget.comment;
    commentId = comment.id;
    _favorCount = comment.likeCount;
    _isfavored = comment.liked;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // get user name
    String commentOwner;
    bool is_anonymous = comment.isAnonymous;
    if (is_anonymous) {
      commentOwner = comment.anonyname!;
    } else {
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
              // 帖子内容展示
              Container(
                child: ListTile(
                  title: buildCommentOwnerButton(comment),
                  trailing: buildCommentMetaButton(comment),
                  subtitle: Text(formatDate(comment.createdAt,
                      [yyyy, '/', mm, '/', dd, ' ', HH, ':', nn, ':', ss])),
                ),
              ), // 元信息（点赞数）
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
                      comment.content,
                      textAlign: TextAlign.left,
                      // maxLines: 3,
                      // overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              ),
            ],
          )),
    );
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

  Widget buildCommentMetaButton(Comment comment) {
    if (!comment.isAnonymous && comment.poster?.id == provider.userInfo?.id) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // TODO: delete function
          IconButton(
            onPressed: _deleteCommentInTopic,
            icon: const Icon(Icons.delete_outline),
            iconSize: MediaQuery.of(context).size.height * 0.02,
          ),
          buildRowIconButton(
              // FIXME: change the func into add like num
              () {},
              Icon(
                Icons.favorite_border,
                color: Colors.grey,
                size: MediaQuery.of(context).size.height * 0.02,
              ),
              comment.likeCount.toString())
        ],
      );
    } else {
      return buildRowIconButton(
          // FIXME: change the func into add like num
          _favorCommentInTopic,
          Icon(
            Icons.favorite_border,
            color: Colors.grey,
            size: MediaQuery.of(context).size.height * 0.02,
          ),
          _favorCount.toString());
    }
  }

  Widget buildCommentOwnerButton(Comment comment) {
    if (comment.isAnonymous) {
      final text = comment.anonyname!;
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
      final poster = comment.poster!;
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

  void _favorCommentInTopic() {
    try {
      if (_isfavored == false) {
        ChatDanRepository().likeAComment(commentId);
        setState(() {
          _favorCount = _favorCount + 1;
          _isfavored = true;
        });
      } else {
        ChatDanRepository().unlikeAComment(commentId);
        setState(() {
          _favorCount = _favorCount - 1;
          _isfavored = false;
        });
      }
    } catch (e) {
      // do nothing
    }
  }

  void _deleteCommentInTopic() {
    try {
      ChatDanRepository().deleteAComment(commentId);
      // TODO:delete the topic in the super comment list
      widget.deleteFunc(commentId);
    } catch (e) {
      // do nothing
    }
  }
}
