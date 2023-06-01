import 'package:chatdan_frontend/widgets/message_box.dart';
import 'package:chatdan_frontend/widgets/square.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const SquareWidget(),
    const MessageBoxListWidget(),
    const Placeholder(),
    const Placeholder(),
  ];

  AppBar _buildAppBar(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return AppBar(
          title: const Text('广场'),
        );
      case 1:
        return AppBar(
          title: const Text('提问箱'),
        );
      case 2:
        return AppBar(
          title: const Text('聊天'),
        );
      case 3:
        return AppBar(
          title: const Text('我的'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                context.push('/settings');
              },
            ),
          ],
        );
      default:
        return AppBar(
          title: const Text('广场'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: theme.primaryColor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.square_foot),
            label: '广场',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer),
            label: '提问箱',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '聊天',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: theme.primaryColorDark,
        unselectedItemColor: theme.primaryColorLight,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
