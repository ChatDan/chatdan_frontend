import 'dart:async';

import 'package:chatdan_frontend/model/message.dart';
import 'package:chatdan_frontend/model/user.dart';
import 'package:chatdan_frontend/pages/account_subpage/profile.dart';
import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(this.toUser, {super.key});

  final User toUser;

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
    ChatDanRepository().loadMessagesOfAChat(widget.toUser.id, startTime, 10).then((value) {
      if (value?.isEmpty ?? true) {
        isEnd = true;
      } else {
        setState(() {
          messages.addAll(value!);
          startTime = messages.last.createdAt;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadMessageList();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1)).then((e) {
      setState(() {
        loadMessageList();
      });
    });
  }

  TextEditingController messageController = TextEditingController();

  void sendMessage(String message) {
    setState(() {
      final myUserId = ChatDanRepository().provider.userInfo!.id;
      Message newMessage = Message(
        id: 0,
        createdAt: DateTime.now(),
        fromUserId: myUserId,
        toUserId: widget.toUser.id,
        content: message,
        isMe: true,
      );
      messages = [newMessage, ...messages];
      messageController.clear();
      ChatDanRepository().sendAMessage(widget.toUser.id, message);
    });
  }

  Widget buildMessageBubble(BuildContext context, Message message) {
    final alignment = message.isMe ? Alignment.centerRight : Alignment.centerLeft;
    final color = message.isMe ? Colors.blue : Colors.green;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Wrap(
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.65, // 设置气泡最大宽度为页面宽度的一半
              ),
              padding: const EdgeInsets.all(12.0),
              child: Text(
                message.content,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildtoUserMessage(BuildContext context, Message message) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage(user: widget.toUser)));
            },
            child: CircleAvatar(
              child: Text(
                widget.toUser.username.substring(0, 2),
              ),
            ),
          ),
          buildMessageBubble(context, message)
        ],
      ),
    );
  }

  Widget buildmyMessage(BuildContext context, Message message) {
    final myUsername = ChatDanRepository().provider.userInfo!.username;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage(user: ChatDanRepository().provider.userInfo!)));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildMessageBubble(context, message),
            CircleAvatar(
              child: Text(myUsername.substring(0, 2)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.toUser.username),
      ),
      body: Column(
        children: [
          Expanded(
              child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: Align(
              alignment: Alignment.topCenter,
              child: ListView.builder(
                reverse: true,
                shrinkWrap: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return message.isMe ? buildmyMessage(context, message) : buildtoUserMessage(context, message);
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 2.0,
                        ),
                      ),
                      // hintText: 'Type a message...',
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    sendMessage(messageController.text);
                  },
                  child: const Text('发送'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
