import 'package:chatdan_frontend/pages/chat_subpage/chat_page.dart';
import 'package:chatdan_frontend/pages/setting.dart';
import 'package:chatdan_frontend/repository/chatdan_repository.dart';
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
        title: Text('用户信息'),
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
  Widget _buildHeader() {
    final avatar = widget.user.avatar == null
        ? const CircleAvatar(
            radius: 32.0,
            child: Icon(Icons.person),
          )
        : CircleAvatar(
            radius: 32.0,
            backgroundImage: NetworkImage(widget.user.avatar!),
          );

    return ListTile(
      leading: GestureDetector(
        child: avatar,
        onTap: () {},
      ),
      title: Text(
        widget.user.username,
        style: const TextStyle(fontSize: 22.0),
      ),
      subtitle: Text(
        'ID: ${widget.user.id}',
        style: const TextStyle(fontSize: 16.0),
      ),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () {},
      minVerticalPadding: 4,
    );
  }

  Widget _buildBody() {
    if (ChatDanRepository().provider.userInfo == null) {
      return const SizedBox.shrink();
    }
    if (widget.user.id != ChatDanRepository().provider.userInfo!.id) {
      return Column(
        children: <Widget>[
          Divider(),
          ListTile(
            leading: Icon(Icons.message),
            title: Text('发消息'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatPage(widget.user)));
            },
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('关注'),
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('查看他的提问箱'),
          )
        ],
      );
    }

    // 如果是自己
    return Column(
      children: <Widget>[
        Divider(),
        ListTile(
          leading: Icon(Icons.edit),
          title: Text('我的发帖'),
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
          leading: Icon(Icons.reply),
          title: Text('我的评论'),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.favorite),
          title: Text('我的收藏'),
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
        Divider(),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('设置'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingPage()));
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text(
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
