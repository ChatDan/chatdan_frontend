import 'package:chatdan_frontend/pages/account_subpage/profile.dart';
import 'package:flutter/material.dart';

import '../../bottom_bar.dart';
import '../../model/user.dart';
import '../../repository/chatdan_repository.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  @override
  Widget build(BuildContext context) {
    final user = ChatDanRepository().provider.userInfo ?? User.dummy();
    return Scaffold(
      appBar: AppBar(
        title: Text('我的'),
      ),
      body: UserProfileWidget(user: user),
      bottomNavigationBar: const BottomBar(index: 4),
    );
  }
}
