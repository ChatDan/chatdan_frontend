import 'package:chatdan_frontend/model/user.dart';
import 'package:chatdan_frontend/pages/account_subpage/profile.dart';
import 'package:chatdan_frontend/pages/account_subpage/profile_editing_page.dart';
import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:flutter/material.dart';

class UserWidget extends StatefulWidget {
  final User user;

  const UserWidget(this.user, {Key? key}) : super(key: key);

  @override
  State createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  late User user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.user.id == ChatDanRepository().provider.userInfo?.id;
    final avatar = widget.user.avatar == null
        ? const CircleAvatar(
            radius: 32.0,
            child: Icon(Icons.person),
          )
        : CircleAvatar(
            radius: 32.0,
            backgroundImage: NetworkImage(widget.user.avatar!),
          );

    return Column(
      children: [
        ListTile(
          leading: GestureDetector(
            onTap: null,
            child: avatar,
          ),
          title: Text(
            widget.user.username,
            style: const TextStyle(fontSize: 20.0),
          ),
          subtitle: Text(
            'ID: ${widget.user.id}',
            style: const TextStyle(fontSize: 14.0),
          ),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage(user: widget.user))).then((_) {
              if (isMe) {
                setState(() {
                  user = ChatDanRepository().provider.userInfo!;
                });
              }
            });
          },
          minVerticalPadding: 4,
        ),
        if (widget.user.introduction != null)
          Column(
            children: [
              const Divider(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                alignment: Alignment.centerLeft,
                child: SelectableText(
                  '个性签名：${widget.user.introduction!}',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class UserHeaderWidget extends StatefulWidget {
  final User user;

  const UserHeaderWidget(this.user, {Key? key}) : super(key: key);

  @override
  State<UserHeaderWidget> createState() => _UserHeaderWidgetState();
}

class _UserHeaderWidgetState extends State<UserHeaderWidget> {
  late User user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.user.id == ChatDanRepository().provider.userInfo?.id;
    final avatar = widget.user.avatar == null
        ? const CircleAvatar(
      radius: 32.0,
      child: Icon(Icons.person),
    )
        : CircleAvatar(
      radius: 32.0,
      backgroundImage: NetworkImage(widget.user.avatar!),
    );

    Function()? onTap;
    if (isMe) {
      onTap = () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileEditingPage(widget.user))).then((_) {
          if (isMe) {
            setState(() {
              user = ChatDanRepository().provider.userInfo!;
            });
          }
        });
      };
    }

    return Column(
      children: [
        ListTile(
          leading: GestureDetector(
            onTap: null,
            child: avatar,
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
          onTap: onTap,
          minVerticalPadding: 4,
        ),
        if (widget.user.introduction != null)
          Column(
            children: [
              const Divider(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                alignment: Alignment.centerLeft,
                child: SelectableText(
                  '个性签名：${widget.user.introduction!}',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
