import 'package:chatdan_frontend/pages/account_subpage/list_comment_page.dart';
import 'package:chatdan_frontend/pages/askbox_subpage/askbox_page.dart';
import 'package:chatdan_frontend/pages/chat_subpage/chat_page.dart';
import 'package:chatdan_frontend/pages/setting.dart';
import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:chatdan_frontend/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../model/user.dart';
import '../square_subpage/list_topics_page.dart';

class UserProfilePage extends StatefulWidget {
  final User user;

  const UserProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户信息'),
      ),
      body: UserProfileWidget(user: widget.user),
    );
  }
}

class UserProfileWidget extends StatefulWidget {
  final User user;

  const UserProfileWidget({
    super.key,
    required this.user,
  });

  @override
  State<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  late User user;
  late bool isMe;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    isMe = ChatDanRepository().provider.userInfo?.id == widget.user.id;
  }

  Widget _buildHeader() {
    return UserHeaderWidget(user);
  }

  Widget _buildBody() {
    if (ChatDanRepository().provider.userInfo == null) {
      return const SizedBox.shrink();
    }
    if (!isMe) {
      return Column(
        children: <Widget>[
          const Divider(),
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('发消息'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(user)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('查看他的提问箱'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AskboxPage(user.id),
                ),
              );
            },
          ),
        ],
      );
    }

    // 如果是自己
    return Column(
      children: <Widget>[
        const Divider(),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('我的发帖'),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ListTopicsWidget(
                          isMe: true,
                          isPage: true,
                        )));
          },
        ),
        ListTile(
          leading: const Icon(Icons.reply),
          title: const Text('我的评论'),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ListCommentPage(
                          userId: ChatDanRepository().provider.userInfo!.id,
                        )));
          },
        ),
        ListTile(
          leading: const Icon(Icons.favorite),
          title: const Text('我的收藏'),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ListTopicsWidget(
                          isFavorite: true,
                          isPage: true,
                        )));
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('设置'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingPage()));
          },
        ),
        const Divider(),
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(
              '退出登录',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              try {
                await ChatDanRepository().logout();
              } catch (e) {
                // do nothing
              }

              if (mounted) {
                GoRouter.of(context).go('/login');
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildHeader(),
        _buildBody(),
      ],
    );
  }
}
