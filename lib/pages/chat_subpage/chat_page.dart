import 'dart:async';

import 'package:chatdan_frontend/model/message.dart';
import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  ChatPage(
      {super.key,
      required this.MyUserId,
      required this.toUserId,
      required this.toUsername,
      required this.createdAt,
      required this.myUsername});

  int MyUserId;
  int toUserId;
  String? toUsername;
  String? myUsername;
  DateTime createdAt;

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final _scrollController = ScrollController();
  List<Message> messages = [];
  bool isEnd = false;
  DateTime? startTime;

  void loadMessageList() {
    if (isEnd) {
      return;
    }
    ChatDanRepository().loadMessagesOfAChat(widget.toUserId, startTime, 10).then((value) {
      if (value?.isEmpty ?? true) {
        isEnd = true;
      } else {
        messages.addAll(value!);
        startTime = messages.last.createdAt;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadMessageList();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(Duration(seconds: 1)).then((e) {
      setState(() {
        loadMessageList();
      });
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   loadMessages();
  //   // var fromId = widget.thisContact.oneUserId;
  //   Message testJson = Message(
  //       id: 0,
  //       createdAt: DateTime.now(),
  //       updatedAt: DateTime.now(),
  //       fromUserId: widget.MyUserId,
  //       toUserId: widget.toUserId,
  //       isOwner: false);
  //   setState(() {
  //     List<Message> newJson = [];
  //     for (var i = 1; i < 10; i++) {
  //       Message testJson = Message(
  //           id: 0,
  //           createdAt: DateTime.now(),
  //           updatedAt: DateTime.now(),
  //           content: '你好,这是第${i}条消息',
  //           fromUserId: widget.MyUserId,
  //           toUserId: widget.toUserId,
  //           isOwner: i % 2 == 0);
  //       // testJson.content = '你好,这是第${i}条消息';
  //       // testJson.isOwner = i % 2 == 0;
  //       newJson.add(testJson);
  //     }
  //     messages.addAll(newJson);
  //   });
  // }

  // List<Message> messages = [
  //   'Hello!111111111111',
  //   'Hi there!',
  //   'How are you?',
  //   'I am good. Thanks for asking!',
  // ];

  TextEditingController messageController = TextEditingController();

  void sendMessage(String message) {
    setState(() {
      Message NewMessage = Message(
          id: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          fromUserId: widget.MyUserId,
          toUserId: widget.toUserId,
          content: message,
          isOwner: true);
      messages.add(NewMessage);
      messageController.clear();
      ChatDanRepository().sendAMessage(widget.toUserId, message);
    });
  }

  Widget buildMessageBubble(BuildContext context, Message message) {
    final alignment = message.isOwner ? Alignment.centerRight : Alignment.centerLeft;
    final color = message.isOwner ? Colors.blue : Colors.green;

    return Align(
      alignment: alignment,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Wrap(
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.5, // 设置气泡最大宽度为页面宽度的一半
              ),
              padding: EdgeInsets.all(12.0),
              child: Text(
                message.content,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildtoUserMessage(BuildContext context, Message message) {
    final color = message.isOwner ? Colors.blue : Colors.green;
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color,
        ),
        child: Text(
          widget.toUsername.toString().substring(0, 2), //取前两个字符作为用户的头像
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
      buildMessageBubble(context, message)
    ]);
  }

  Widget buildmyMessage(BuildContext context, Message message) {
    final color = message.isOwner ? Colors.blue : Colors.green;
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      buildMessageBubble(context, message),
      Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color,
        ),
        child: Text(
          widget.myUsername.toString().substring(0, 2), //取前两个字符作为用户的头像
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.toUsername != null ? Text(widget.toUsername.toString()) : const Text('用户'),
      ),
      body: Column(
        children: [
          Expanded(
              child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: Align(
              alignment: Alignment.topCenter,
              child: ListView.builder(
                // reverse: true,
                shrinkWrap: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return message.isOwner ? buildmyMessage(context, message) : buildtoUserMessage(context, message);
                },
                // padding: EdgeInsets.symmetric(vertical: 8.0),
                // children: messages.reversed.map((message) {
                //   final isSentByMe = messages.indexOf(message) % 2 ==
                //       0; // Just for demonstration purposes
                //   return buildMessageBubble(message, isSentByMe);
                // }).toList(),
              ),
            ),
          )),
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: OutlineInputBorder(
                        ///设置边框四个角的弧度
                        // borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 2.0,
                        ),
                      ),
                      // hintText: 'Type a message...',
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    sendMessage(messageController.text);
                  },
                  child: Text('发送'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
