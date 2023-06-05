import 'package:chatdan_frontend/model/comment.dart';
import 'package:flutter/material.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;

  const CommentWidget(this.comment, {Key? key}) : super(key: key);

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  late Comment comment;

  @override
  void initState() {
    comment = widget.comment;
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
                      TextButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          Icons.thumb_up,
                          color: Colors.grey,
                          size: MediaQuery.of(context).size.height * 0.02,
                        ),
                        label: Text(
                          comment.likeCount.toString(),
                          style: TextStyle(color: Colors.black),
                        ),
                      )
                    ],
                  )),
            ],
          )),
    );
  }
}
