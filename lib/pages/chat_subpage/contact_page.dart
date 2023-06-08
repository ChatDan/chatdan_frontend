import 'package:chatdan_frontend/bottom_bar.dart';
import 'package:chatdan_frontend/model/chat.dart';
import 'package:chatdan_frontend/pages/chat_subpage/chat_page.dart';
import 'package:chatdan_frontend/pages/chat_subpage/contact_search_page.dart';
import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  ContactsPageState createState() => ContactsPageState();
}

class ContactsPageState extends State<ContactsPage> {
  final _pagingController = PagingController<int, Chat>(firstPageKey: 0);

  Future<void> _loadChat() async {
    try {
      final chats = await ChatDanRepository().loadChats() ?? [];
      _pagingController.appendLastPage(chats);
    } catch (e) {
      // do nothing
    }
  }

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) => _loadChat());
    // ChatList.add(tst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('聊天'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: ContactSearchDelegate());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => _pagingController.refresh()),
        child: PagedListView(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<Chat>(
              itemBuilder: (context, item, index) => buildChatMessage(context, item),
              noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('暂无数据')),
              noMoreItemsIndicatorBuilder: (context) => const Center(child: Text('没有更多了')),
              firstPageErrorIndicatorBuilder: (context) => const Center(child: Text('加载失败')),
              newPageErrorIndicatorBuilder: (context) => const Center(child: Text('加载失败')),
            )),
      ),
      bottomNavigationBar: BottomBar(index: 3),
    );
  }

  Widget buildChatMessage(BuildContext context, Chat chat) {
    DateTime time = chat.updatedAt;
    final days = DateTime.now().difference(time).inDays;
    final updateTime = days >= 1 ? DateFormat.Md().format(time) : DateFormat.Hm().format(time);

    return ListTile(
      title: Text(chat.anotherUser.username),
      subtitle: Text(
        chat.lastMessageContent,
        overflow: TextOverflow.ellipsis,
      ),
      leading: CircleAvatar(
        child: Text(
          chat.anotherUser.username.substring(0, 2),
        ),
      ),
      trailing: Text(
        updateTime,
        style: const TextStyle(fontSize: 10),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            // 传入的参数包括：聊天人id和用戶名,自己的id
            builder: (context) => ChatPage(chat.anotherUser),
          ),
        );
      },
    );
  }
}
