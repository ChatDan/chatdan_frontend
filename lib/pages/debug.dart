import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:flutter/material.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({Key? key}) : super(key: key);

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  final _accessTokenController = TextEditingController(text: ChatDanRepository().provider.accessToken);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Debug'),
        ),
        body: ListView(children: [
          ListTile(
            title: const Text('清除用户信息'),
            onTap: () async {
              await ChatDanRepository().provider.clear();
              print('清除用户信息');
              print('ChatDanProvider().accessToken: ${ChatDanRepository().provider.accessToken}');
              setState(() {});
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _accessTokenController,
              decoration: const InputDecoration(
                labelText: 'accessToken',
              ),
              onSubmitted: (value) {
                print('submit accessToken: $value');
                ChatDanRepository().provider.setAccessToken(value);
              },
            ),
          ),
        ]));
  }
}
