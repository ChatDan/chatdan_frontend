import 'package:chatdan_frontend/model/division.dart';
import 'package:chatdan_frontend/pages/square_subpage/create_topic_page.dart';
import 'package:chatdan_frontend/pages/square_subpage/list_topics_page.dart';
import 'package:chatdan_frontend/repository/chatdan_repository.dart';
import 'package:flutter/material.dart';

import '../../bottom_bar.dart';

class SquarePage extends StatefulWidget {
  const SquarePage({super.key});

  @override
  State<SquarePage> createState() => _SquarePageState();
}

class _SquarePageState extends State<SquarePage> {
  List<Division> divisionList = [];
  int selectedDivision = 0;

  void loadDivisions() {
    try {
      ChatDanRepository().loadDivisions().then((value) {
        setState(() {
          divisionList = value ?? [];
        });
      });
    } catch (e) {
      // do nothing
    }
  }

  @override
  void initState() {
    super.initState();
    loadDivisions();
  }

  void _onCreateTopicButtonTapped() {
    Navigator.push(context,
            MaterialPageRoute(builder: (context) => const CreateTopicPage()))
        .then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        //导航栏的长度
        length: divisionList.length,
        child: Scaffold(
          appBar: buildAppBar(context),
          body: buildBodyWidget(context),
          bottomNavigationBar: const BottomBar(index: 0),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _onCreateTopicButtonTapped();
            },
            backgroundColor: Colors.teal,
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ));
  }

  // 顶部导航栏
  PreferredSizeWidget buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('广场'),
      backgroundColor: Colors.white,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {},
        )
      ],
      bottom: divisionList.isEmpty
          ? const PreferredSize(
              preferredSize: Size.fromHeight(10),
              child: SizedBox(
                height: 10,
              ))
          : TabBar(
              isScrollable: true,
              //可滚动
              indicatorColor: const Color.fromARGB(0, 0, 0, 0),
              //指示器的颜色
              labelColor: Colors.black,
              //选中文字颜色
              unselectedLabelColor: Colors.grey,
              //未选中文字颜色
              // indicatorSize: TabBarIndicatorSize.label, //指示器与文字等宽
              labelStyle: const TextStyle(fontSize: 15.0),
              unselectedLabelStyle: const TextStyle(fontSize: 12.0),
              onTap: (index) {
                setState(() {
                  selectedDivision = index;
                });
              },
              tabs: divisionList.map((e) => Tab(text: e.name)).toList(),
            ),
    );
  }

  // 主体
  Widget buildBodyWidget(BuildContext context) {
    return TabBarView(
      children:
          divisionList.map((e) => ListTopicsWidget(divisionId: e.id)).toList(),
    );
  }

//   Widget buildImageCard(String imgUrl) {
//     return Card(
//       shape: RoundedRectangleBorder(
//           borderRadius: BorderRadiusDirectional.circular(10)),
//       clipBehavior: Clip.antiAlias,
//       child: Image.network(
//         imgUrl,
//         width: 120,
//         height: 120,
//         fit: BoxFit.cover,
//       ),
//     );
//   }
}
