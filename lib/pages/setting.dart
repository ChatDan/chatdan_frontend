import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('夜间模式'),
            value: _darkMode,
            onChanged: (select) {
              setState(() {
                _darkMode = select;
              });
            },
          ),
          ListTile(
            title: const Text('账号与安全'),
            onTap: () {},
          ),
          const Divider(),
          const ListTile(
            title: Text('关于我们'),
            subtitle: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'ChanDan 是一个基于 Flutter 开发的开源社区，提供了匿名墙、提问箱、表白墙、私聊、半匿名广场社区等功能。',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
