import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'pages/square_page.dart';
// import 'pages/askbox_page.dart';
// import 'pages/chat_page.dart';
// import 'pages/mine_page.dart';

class BottomBar extends StatefulWidget {
  final int index;
  const BottomBar({super.key, required this.index});

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;

  void _setInitIndex() {
    setState(() {
      _selectedIndex = widget.index;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      // print("tap ${index}");

      _selectedIndex = index;
      if (index == 0) {
        GoRouter.of(context).go('/home');
        // _selectedIndex = 0;
      }
      if (index == 1) {
        GoRouter.of(context).go('/wall');
        // _selectedIndex = 1;
      }
      if (index == 2) {
        GoRouter.of(context).go('/askbox');
        // _selectedIndex = 2;
      }
      if (index == 3) {
        GoRouter.of(context).go('/contact');
        // _selectedIndex = 3;
      }
      if (index == 4) {
        GoRouter.of(context).go('/mine');
        // _selectedIndex = 4;
      }
    });
  }

  // final List<Widget> _Pages = [];
  // final List<PreferredSizeWidget> _AppBars = [];

  @override
  void initState() {
    super.initState();
    _setInitIndex();
    // _Pages
    //   ..add(const SquarePage())
    //   ..add(const AskboxPage())
    //   ..add(const ChatPage())
    //   ..add(const MinePage());
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '广场'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '表白墙'),
        BottomNavigationBarItem(icon: Icon(Icons.mail), label: '提问箱'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: '聊天'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.teal,
      type: BottomNavigationBarType.fixed,
      onTap: _onItemTapped,
    );
    // return Scaffold(
    //   appBar: _AppBars[_selectedIndex],
    //   body: _Pages[_selectedIndex],
    //   bottomNavigationBar: BottomNavigationBar(
    //     items: const <BottomNavigationBarItem>[
    //       BottomNavigationBarItem(icon: Icon(Icons.home), label: '广场'),
    //       BottomNavigationBarItem(icon: Icon(Icons.mail), label: '提问箱'),
    //       BottomNavigationBarItem(icon: Icon(Icons.chat), label: '聊天'),
    //       BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
    //     ],
    //     // currentIndex: _selectedIndex,
    //     selectedItemColor: Colors.teal,
    //     type: BottomNavigationBarType.fixed,
    //     onTap: _onItemTapped,
    //   ),
    // );
  }
}
