import 'package:chatdan_frontend/bottom_bar.dart';
import 'package:chatdan_frontend/model/chat.dart';
import 'package:chatdan_frontend/pages/chat_subpage/chat_page.dart';
import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';

import '../../utils/errors.dart';
import 'contact_search_page.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  ContactsPageState createState() => ContactsPageState();
}

class ContactsPageState extends State<ContactsPage> {
  Chat tst = Chat(
    id: 0,
    createdAt: DateTime.utc(1989, 11, 9),
    updatedAt: DateTime.now(),
    oneUserId: 1,
    anotherUserId: 2,
    lastMessageContent: '你好',
  );
  List<Chat> ChatList = [];

  // final Map<String, dynamic> testJson = {
  //   'myId': 0,
  //   'myUsername': 'MyName',
  //   'contactId': 1,
  //   'contactUsername': "Other's Name",
  //   'updated_at': DateTime.utc(1989, 11, 9),
  //   'lastMessage': 'Last Message',
  //   'read': false,
  // };

  void LoadChatList() {
    try {
      ChatDanRepository().loadChats().then((value) {
        setState(() {
          ChatList = value ?? [tst];
        });
      });
    } catch (e) {
      if (e is DioError && e.error is NotLoginError && mounted) {
        context.go('/login');
      } else {
        SmartDialog.showToast(e.toString(), displayTime: const Duration(seconds: 1));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    LoadChatList();
    // ChatList.add(tst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(children: [
          Text(
            '聊天',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          Container(
            height: 30,
            width: MediaQuery.of(context).size.width,
            decoration:
                BoxDecoration(color: Color.fromRGBO(200, 220, 210, 1.0), borderRadius: BorderRadius.circular(20)),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              child: Row(
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(left: 10, right: 10), child: Icon(Icons.search, color: Colors.teal)),
                  Text(
                    '搜索用户',
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  )
                ],
              ),
              onTap: () {
                showSearch(context: context, delegate: SearchPage());
              },
            ),
          ),
        ]),
        elevation: 0,
      ),
      body: Container(
        // child: ListView.builder(
        //   itemCount: ChatList.length,
        //   itemBuilder: (context, index) {
        //     final chat = ChatList[index];
        //     return buildChatMessage(context, chat);
        //   },
        // ),
        // color: Colors.teal,
        child: ChatList.isEmpty
            ? Center(
                child: Text(
                  '暂无联系人',
                  style: TextStyle(fontSize: 15),
                ),
              )
            : ListView.builder(
                itemCount: ChatList.length,
                itemBuilder: (context, index) {
                  final chat = ChatList[index];
                  return buildChatMessage(context, chat);
                },
              ),
      ),

      bottomNavigationBar: BottomBar(index: 3),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(
      //     Icons.add,
      //     color: Colors.white,
      //   ),
      //   onPressed: () {
      //     print("点击了 FloatingActionButton");
      //   },
      //   backgroundColor: Colors.deepPurple,
      //   foregroundColor: Colors.black,
      //   elevation: 0.0,
      //   highlightElevation: 20.0,
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget buildChatMessage(BuildContext context, Chat chat) {
    DateTime time = chat.updatedAt;
    DateTime now = DateTime.now();
    int hour = time.hour;
    int minute = time.minute;
    int day = time.day;
    int month = time.month;
    var days = now.difference(time).inDays;
    String updateTime = '';
    if (days >= 1) {
      updateTime = '$month月$day日';
    } else {
      updateTime = '$hour:$minute';
    }
    //未添加显示是否已读功能
    // Color isread;
    // if (chat. == false) {
    //   isread = Colors.red;
    // } else {
    //   isread = Colors.green;
    // }

    return ListTile(
      title: Row(
        children: [
          if (chat.anotherUser != null) Text(chat.anotherUser!.username) else Text('user'),
          Text(
            updateTime,
            style: TextStyle(fontSize: 10),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
      // subtitle: Container(
      //   color: Colors.white,
      //   alignment: Alignment.bottomLeft,
      //   height: 25,
      //   padding: const EdgeInsets.only(right: 5),
      //   child: Text(
      //     chat['lastMessage'],
      //     overflow: TextOverflow.ellipsis,
      //   ),
      // ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 5),
        // 每一个需要两个以上的组件构成的组件，都需要使用Row或者Column或者Flex的组件来实现
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Text(
                chat.lastMessageContent,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 小圆点显示是否已读
            // Container(
            //   width: 10,
            //   height: 10,
            //   decoration: BoxDecoration(
            //       color: isread, borderRadius: BorderRadius.circular(5)),
            // )
          ],
        ),
      ),
      //头像
      leading: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue,
        ),
        child: Text(
          chat.anotherUser != null ? chat.anotherUser!.username.substring(0, 2) : '用戶', //取前两个字符作为用户的头像
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            // 传入的参数包括：聊天人id和用戶名,自己的id
            builder: (context) => ChatPage(
                toUserId: chat.anotherUserId,
                MyUserId: chat.oneUserId,
                toUsername: chat.anotherUser?.username,
                myUsername: chat.oneUser?.username,
                createdAt: chat.createdAt),
          ),
        );
      },
    );
  }
}
